import SwiftUI
import WhiteboardCore

struct WhiteboardView: View {
    @ObservedObject var model: DrawingModel
    @State private var isListening = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            WhiteboardCanvas(model: model)
            Toolbar(model: model, isListening: $isListening)
                .padding(12)
        }
        .ignoresSafeArea()
    }
}

private struct Toolbar: View {
    @ObservedObject var model: DrawingModel
    @Binding var isListening: Bool

    var body: some View {
        HStack(spacing: 8) {
            Button {
                isListening.toggle()
                VoiceController.shared.setListening(isListening)
            } label: {
                Image(systemName: isListening ? "mic.fill" : "mic")
                    .foregroundStyle(isListening ? .red : .primary)
            }
            .help("Toggle voice input")

            Button { model.apply(.undo) } label: { Image(systemName: "arrow.uturn.backward") }
                .help("Undo last command")

            Button { model.apply(.clear) } label: { Image(systemName: "trash") }
                .help("Clear canvas")

            Button {
                NSApp.keyWindow?.toggleFullScreen(nil)
            } label: { Image(systemName: "arrow.up.left.and.arrow.down.right") }
            .help("Toggle fullscreen")
        }
        .buttonStyle(.borderless)
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct WhiteboardCanvas: View {
    @ObservedObject var model: DrawingModel

    var body: some View {
        Canvas { context, size in
            for command in model.commands {
                render(command, into: &context, size: size)
            }
        }
        .background(model.background.color)
    }

    private func render(_ command: DrawCommand, into context: inout GraphicsContext, size: CGSize) {
        let coords = command.coords
        switch command.kind {
        case .stroke(let points, let color, let width):
            guard points.count > 1 else { return }
            var path = Path()
            path.move(to: points[0].resolve(in: size, coords: coords))
            for p in points.dropFirst() {
                path.addLine(to: p.resolve(in: size, coords: coords))
            }
            context.stroke(
                path,
                with: .color(color.color),
                style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round)
            )

        case .line(let from, let to, let color, let width):
            var path = Path()
            path.move(to: from.resolve(in: size, coords: coords))
            path.addLine(to: to.resolve(in: size, coords: coords))
            context.stroke(path, with: .color(color.color), style: StrokeStyle(lineWidth: width, lineCap: .round))

        case .rect(let origin, let dim, let color, let width, let filled):
            let rect = CGRect(
                origin: origin.resolve(in: size, coords: coords),
                size: dim.resolve(in: size, coords: coords)
            )
            let path = Path(rect)
            if filled { context.fill(path, with: .color(color.color)) }
            else { context.stroke(path, with: .color(color.color), lineWidth: width) }

        case .ellipse(let origin, let dim, let color, let width, let filled):
            let rect = CGRect(
                origin: origin.resolve(in: size, coords: coords),
                size: dim.resolve(in: size, coords: coords)
            )
            let path = Path(ellipseIn: rect)
            if filled { context.fill(path, with: .color(color.color)) }
            else { context.stroke(path, with: .color(color.color), lineWidth: width) }

        case .text(let at, let text, let color, let fontSize):
            let point = at.resolve(in: size, coords: coords)
            let resolved = Text(text).font(.system(size: fontSize)).foregroundColor(color.color)
            context.draw(resolved, at: point, anchor: .topLeading)
        }
    }
}

// MARK: - Geometry helpers

private extension Point2D {
    func resolve(in size: CGSize, coords: CoordSpace) -> CGPoint {
        switch coords {
        case .normalized: return CGPoint(x: x * size.width, y: y * size.height)
        case .absolute:   return CGPoint(x: x, y: y)
        }
    }
}

private extension Size2D {
    func resolve(in size: CGSize, coords: CoordSpace) -> CGSize {
        switch coords {
        case .normalized: return CGSize(width: width * size.width, height: height * size.height)
        case .absolute:   return CGSize(width: width, height: height)
        }
    }
}

private extension RGBA {
    var color: Color { Color(.sRGB, red: r, green: g, blue: b, opacity: a) }
}
