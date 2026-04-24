import Foundation
import Network
import WhiteboardCore

/// Loopback HTTP listener that feeds ``CommandRouter``.
///
/// This file deliberately owns *only* the socket plumbing — parsing,
/// routing, and model mutation live in ``WhiteboardCore`` so they can be
/// unit-tested without a live TCP socket.
final class CommandServer {
    enum ServerError: Error { case alreadyRunning }

    private let router: CommandRouter
    private let port: NWEndpoint.Port
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "whiteboard.command-server")

    init(model: DrawingModel, port: UInt16) {
        self.router = CommandRouter(model: model)
        self.port = NWEndpoint.Port(rawValue: port)!
    }

    func start() throws {
        guard listener == nil else { throw ServerError.alreadyRunning }
        let params = NWParameters.tcp
        params.acceptLocalOnly = true
        params.allowLocalEndpointReuse = true
        let listener = try NWListener(using: params, on: port)
        listener.newConnectionHandler = { [weak self] conn in self?.accept(conn) }
        listener.start(queue: queue)
        self.listener = listener
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    private func accept(_ connection: NWConnection) {
        connection.start(queue: queue)
        read(connection, buffer: Data())
    }

    private func read(_ connection: NWConnection, buffer: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { [weak self] data, _, isComplete, error in
            guard let self else { return }
            var next = buffer
            if let data, !data.isEmpty { next.append(data) }

            if let request = HTTPRequest.parse(next) {
                let response = self.router.handle(request)
                connection.send(content: response.serialize(), completion: .contentProcessed { _ in
                    connection.cancel()
                })
                return
            }

            if error != nil || isComplete {
                connection.cancel()
                return
            }
            self.read(connection, buffer: next)
        }
    }
}
