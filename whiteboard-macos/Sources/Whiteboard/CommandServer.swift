import Foundation
import Network

/// Minimal loopback HTTP server that accepts JSON drawing commands and applies
/// them to a ``DrawingModel``.
///
/// The protocol is intentionally tiny: `POST /command` with a JSON body
/// matching ``IncomingCommand``. Anything unknown returns 400.
final class CommandServer {
    enum ServerError: Error { case alreadyRunning }

    private let model: DrawingModel
    private let port: NWEndpoint.Port
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "whiteboard.command-server")

    init(model: DrawingModel, port: UInt16) {
        self.model = model
        self.port = NWEndpoint.Port(rawValue: port)!
    }

    func start() throws {
        guard listener == nil else { throw ServerError.alreadyRunning }
        let params = NWParameters.tcp
        params.acceptLocalOnly = true
        params.allowLocalEndpointReuse = true
        let listener = try NWListener(using: params, on: port)
        listener.newConnectionHandler = { [weak self] conn in self?.handle(conn) }
        listener.start(queue: queue)
        self.listener = listener
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    private func handle(_ connection: NWConnection) {
        connection.start(queue: queue)
        receive(connection, buffer: Data())
    }

    private func receive(_ connection: NWConnection, buffer: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { [weak self] data, _, isComplete, error in
            guard let self else { return }
            var buffer = buffer
            if let data, !data.isEmpty { buffer.append(data) }
            if let request = HTTPRequest.parse(buffer) {
                self.handleRequest(request, on: connection)
                return
            }
            if error != nil || isComplete {
                connection.cancel()
                return
            }
            self.receive(connection, buffer: buffer)
        }
    }

    private func handleRequest(_ request: HTTPRequest, on connection: NWConnection) {
        let response: HTTPResponse
        switch (request.method, request.path) {
        case ("GET", "/health"):
            response = .json(status: 200, body: ["ok": true])
        case ("POST", "/command"):
            response = applyCommand(body: request.body)
        case ("POST", "/commands"):
            response = applyCommandBatch(body: request.body)
        default:
            response = .json(status: 404, body: ["error": "not found"])
        }
        send(response, on: connection)
    }

    private func applyCommand(body: Data) -> HTTPResponse {
        guard let incoming = try? JSONDecoder().decode(IncomingCommand.self, from: body) else {
            return .json(status: 400, body: ["error": "invalid command json"])
        }
        do {
            try apply(incoming)
            return .json(status: 200, body: ["ok": true])
        } catch {
            return .json(status: 400, body: ["error": "\(error)"])
        }
    }

    private func applyCommandBatch(body: Data) -> HTTPResponse {
        guard let batch = try? JSONDecoder().decode([IncomingCommand].self, from: body) else {
            return .json(status: 400, body: ["error": "invalid command-batch json"])
        }
        do {
            for command in batch { try apply(command) }
            return .json(status: 200, body: ["ok": true, "applied": batch.count])
        } catch {
            return .json(status: 400, body: ["error": "\(error)"])
        }
    }

    private func apply(_ incoming: IncomingCommand) throws {
        switch try incoming.resolved() {
        case .clear:
            model.clear()
        case .undo:
            model.undo()
        case .background(let color):
            model.setBackground(color)
        case .draw(let command):
            model.append(command)
        }
    }

    private func send(_ response: HTTPResponse, on connection: NWConnection) {
        connection.send(content: response.serialize(), completion: .contentProcessed { _ in
            connection.cancel()
        })
    }
}
