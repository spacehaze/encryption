import Foundation

/// Pure routing logic: map an HTTP request to the response we would send,
/// applying any resulting commands to the supplied ``DrawingModel``.
///
/// Kept free of `Network.framework` so tests can exercise every route
/// without opening a socket.
public struct CommandRouter {
    public let model: DrawingModel
    public let decoder: JSONDecoder

    public init(model: DrawingModel, decoder: JSONDecoder = JSONDecoder()) {
        self.model = model
        self.decoder = decoder
    }

    public func handle(_ request: HTTPRequest) -> HTTPResponse {
        switch (request.method, request.path) {
        case ("GET", "/health"):
            return .json(status: 200, body: ["ok": true])
        case ("POST", "/command"):
            return applyBatch(body: request.body, expectArray: false)
        case ("POST", "/commands"):
            return applyBatch(body: request.body, expectArray: true)
        default:
            return .json(status: 404, body: ["error": "not found"])
        }
    }

    /// Decode and apply either a single command or a batch, depending on
    /// `expectArray`. Folding both paths through one function avoids the
    /// duplicated try/catch ladders we had before.
    private func applyBatch(body: Data, expectArray: Bool) -> HTTPResponse {
        let commands: [IncomingCommand]
        do {
            if expectArray {
                commands = try decoder.decode([IncomingCommand].self, from: body)
            } else {
                commands = [try decoder.decode(IncomingCommand.self, from: body)]
            }
        } catch {
            return .json(status: 400, body: ["error": "invalid command json"])
        }

        do {
            let resolved = try commands.map { try $0.resolved() }
            model.apply(resolved)
            return .json(status: 200, body: ["ok": true, "applied": resolved.count])
        } catch {
            return .json(status: 400, body: ["error": "\(error)"])
        }
    }
}
