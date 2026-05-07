import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var state

    enum SheetTarget: Identifiable {
        case add
        case edit(Chord)

        var id: String {
            switch self {
            case .add: "add"
            case .edit(let c): c.id.uuidString
            }
        }
    }

    @State private var sheet: SheetTarget?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                chordRow
                Spacer()
                TransportBar()
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
            .padding(.top)
            .navigationTitle("Chordmate")
            .background(Color(.systemBackground))
            .sheet(item: $sheet) { target in
                editor(for: target)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private var chordRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(state.progression.chords.enumerated()), id: \.element.id) { idx, chord in
                    ChordChipView(chord: chord, isPlaying: state.playingIndex == idx)
                        .onTapGesture { sheet = .edit(chord) }
                }
                AddChordButton { sheet = .add }
            }
            .padding(.horizontal)
        }
        .frame(height: 120)
    }

    @ViewBuilder
    private func editor(for target: SheetTarget) -> some View {
        switch target {
        case .add:
            ChordEditorSheet(
                chord: Chord(root: .c, quality: .major),
                mode: .add
            ) { outcome in
                if case .save(let new) = outcome { state.add(new) }
                sheet = nil
            }
        case .edit(let chord):
            ChordEditorSheet(chord: chord, mode: .edit) { outcome in
                switch outcome {
                case .save(let updated): state.update(updated)
                case .delete(let id):    state.remove(id: id)
                case .cancel:            break
                }
                sheet = nil
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
