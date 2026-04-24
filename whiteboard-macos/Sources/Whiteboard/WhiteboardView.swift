import SwiftUI

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

            Button {
                model.undo()
            } label: { Image(systemName: "arrow.uturn.backward") }
            .help("Undo last command")

            Button {
                model.clear()
            } label: { Image(systemName: "trash") }
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
        GeometryReader { geo in
            Canvas { context, size in
                for command in model.commands {
                    render(command, in: &context, size: size)
                }
            }
            .background(model.background.color)
        }
    }

    private func render(_ command: DrawCommand, in context: inout GraphicsContext, size: CGSize) {
        switch command {
        case .stroke(_, let points, let color, let width, let coords):
            guard points.count > 1 else { return }
            var path = Path()
            path.move(to: resolve(points[0], size: size, coords: coords))
            for p in points.dropFirst() {
                path.addLine(to: resolve(p, size: size, coords: coords))
            }
            context.stroke(path, with: .color(color.color), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))

        case .rect(_, let origin, let dim, let color, let width, let filled, let coords):
            let o = resolve(origin, size: size, coords: coords)
            let s = resolveSize(dim, size: size, coords: coords)
            let rect = CGRect(x: o.x, y: o.y, width: s.width, height: s.height)
            let path = Path(rect)
            if filled { context.fill(path, with: .color(color.color)) }
            else { context.stroke(path, with: .color(color.color), lineWidth: width) }

        case .ellipse(_, let origin, let dim, let color, let width, let filled, let coords):
            let o = resolve(origin, size: size, coords: coords)
            let s = resolveSize(dim, size: size, coords: coords)
            let rect = CGRect(x: o.x, y: o.y, width: s.width, height: s.height)
            let path = Path(ellipseIn: rect)
            if filled { context.fill(path, with: .color(color.color)) }
            else { context.stroke(path, with: .color(color.color), lineWidth: width) }

        case .line(_, let from, let to, let color, let width, let coords):
            var path = Path()
            path.move(to: resolve(from, size: size, coords: coords))
            path.addLine(to: resolve(to, size: size, coords: coords))
            context.stroke(path, with: .color(color.color), style: StrokeStyle(lineWidth: width, lineCap: .round))

        case .text(_, let at, let text, let color, let fontSize, let coords):
            let point = resolve(at, size: size, coords: coords)
            let resolved = Text(text).font(.system(size: fontSize)).foregroundColor(color.color)
            context.draw(resolved, at: point, anchor: .topLeading)
        }
    }

    private func resolve(_ p: Point2D, size: CGSize, coords: CoordSpace) -> CGPoint {
        switch coords {
        case .normalized: return CGPoint(x: p.x * size.width, y: p.y * size.height)
        case .absolute:   return CGPoint(x: p.x, y: p.y)
        }
    }

    private func resolveSize(_ p: Point2D, size: CGSize, coords: CoordSpace) -> CGSize {
        switch coords {
        case .normalized: return CGSize(width: p.x * size.width, height: p.y * size.height)
        case .absolute:   return CGSize(width: p.x, height: p.y)
        }
    }
}
