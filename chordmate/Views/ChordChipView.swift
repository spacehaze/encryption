import SwiftUI

struct ChordChipView: View {
    let chord: Chord
    let isPlaying: Bool

    var body: some View {
        Text(chord.displayName)
            .font(.system(size: 28, weight: .semibold, design: .rounded))
            .frame(width: 100, height: 96)
            .background(background)
            .foregroundStyle(isPlaying ? Color.white : Color.primary)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.accentColor, lineWidth: isPlaying ? 3 : 0)
            )
            .scaleEffect(isPlaying ? 1.05 : 1.0)
            .animation(.easeOut(duration: 0.15), value: isPlaying)
    }

    private var background: Color {
        isPlaying ? .accentColor : Color(.secondarySystemBackground)
    }
}

struct AddChordButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title)
                .frame(width: 100, height: 96)
                .background(Color(.tertiarySystemBackground))
                .foregroundStyle(Color.secondary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                        .foregroundStyle(Color.secondary.opacity(0.5))
                )
        }
        .buttonStyle(.plain)
    }
}
