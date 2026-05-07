import SwiftUI

struct ChordEditorSheet: View {
    enum Mode { case add, edit }
    enum Outcome { case save(Chord), delete(UUID), cancel }

    let mode: Mode
    let onComplete: (Outcome) -> Void

    @State private var root: Note
    @State private var quality: Quality
    private let chordId: UUID

    init(chord: Chord, mode: Mode, onComplete: @escaping (Outcome) -> Void) {
        self.mode = mode
        self.onComplete = onComplete
        self.chordId = chord.id
        self._root = State(initialValue: chord.root)
        self._quality = State(initialValue: chord.quality)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(Chord(id: chordId, root: root, quality: quality).displayName)
                        .font(.system(size: 48, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                }

                Section("Root") {
                    Picker("Root", selection: $root) {
                        ForEach(Note.allCases, id: \.self) { note in
                            Text(note.displayName).tag(note)
                        }
                    }
                    .pickerStyle(.wheel)
                }

                Section("Quality") {
                    Picker("Quality", selection: $quality) {
                        ForEach(Quality.allCases, id: \.self) { q in
                            Text(label(for: q)).tag(q)
                        }
                    }
                    .pickerStyle(.wheel)
                }

                if mode == .edit {
                    Section {
                        Button("Delete chord", role: .destructive) {
                            onComplete(.delete(chordId))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle(mode == .add ? "Add chord" : "Edit chord")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onComplete(.cancel) }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onComplete(.save(Chord(id: chordId, root: root, quality: quality)))
                    }
                }
            }
        }
    }

    private func label(for quality: Quality) -> String {
        switch quality {
        case .major:      "major"
        case .minor:      "minor"
        case .dominant7:  "7  (dominant 7)"
        case .minor7:     "m7  (minor 7)"
        case .major7:     "maj7"
        case .diminished: "dim"
        case .suspended4: "sus4"
        }
    }
}
