import Foundation
#if canImport(Combine)
import Combine
#endif

/// Ordered list of commands plus the current background color.
///
/// The model is the single source of truth for what the canvas renders.
/// Mutations from network callers are forwarded to the main queue via
/// ``MainDispatcher`` so SwiftUI observes them on the right thread.
public final class DrawingModel: ObservableObject {
    @Published public private(set) var commands: [DrawCommand] = []
    @Published public var background: RGBA = .white

    private let dispatcher: MainDispatcher

    public init(dispatcher: MainDispatcher = .live) {
        self.dispatcher = dispatcher
    }

    public func apply(_ command: ResolvedCommand) {
        dispatcher.run { [self] in
            switch command {
            case .clear: commands.removeAll()
            case .undo:
                if !commands.isEmpty { commands.removeLast() }
            case .background(let color): background = color
            case .draw(let draw): commands.append(draw)
            }
        }
    }

    public func apply<S: Sequence>(_ sequence: S) where S.Element == ResolvedCommand {
        for command in sequence { apply(command) }
    }
}

/// Thin indirection over `DispatchQueue.main.async` so tests can run
/// synchronously without pulling in AppKit or a real run loop.
public struct MainDispatcher: Sendable {
    public let run: @Sendable (@escaping () -> Void) -> Void

    public init(run: @escaping @Sendable (@escaping () -> Void) -> Void) {
        self.run = run
    }

    /// Runs work on `DispatchQueue.main`, or inline if already there.
    public static let live = MainDispatcher { block in
        if Thread.isMainThread { block() }
        else { DispatchQueue.main.async(execute: block) }
    }

    /// Runs work inline on the calling thread. Useful in tests.
    public static let immediate = MainDispatcher { $0() }
}
