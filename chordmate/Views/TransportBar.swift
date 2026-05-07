import SwiftUI

struct TransportBar: View {
    @Environment(AppState.self) private var state

    var body: some View {
        @Bindable var state = state

        VStack(spacing: 20) {
            HStack {
                Text("\(Int(state.progression.bpm)) BPM")
                    .font(.headline.monospacedDigit())
                    .frame(width: 90, alignment: .leading)
                Slider(
                    value: Binding(
                        get: { state.progression.bpm },
                        set: { state.setBpm($0) }
                    ),
                    in: 60...200,
                    step: 1
                )
            }

            Button {
                state.togglePlayback()
            } label: {
                Image(systemName: state.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(state.progression.chords.isEmpty ? Color.gray : Color.accentColor)
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
            .disabled(state.progression.chords.isEmpty)
        }
    }
}
