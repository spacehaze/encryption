import XCTest
@testable import MusicTheory

final class ChordTests: XCTestCase {

    // MARK: - Triads

    func testCMajor() {
        let chord = Chord(root: .c, quality: .major)
        XCTAssertEqual(chord.midiNotes(octave: 4), [60, 64, 67])
        XCTAssertEqual(chord.displayName, "C")
    }

    func testAMinor() {
        let chord = Chord(root: .a, quality: .minor)
        XCTAssertEqual(chord.midiNotes(octave: 4), [69, 72, 76])
        XCTAssertEqual(chord.displayName, "Am")
    }

    func testBDiminished() {
        let chord = Chord(root: .b, quality: .diminished)
        // B4 = 71, +3 = 74 (D5), +6 = 77 (F5)
        XCTAssertEqual(chord.midiNotes(octave: 4), [71, 74, 77])
        XCTAssertEqual(chord.displayName, "Bdim")
    }

    func testCSus4() {
        let chord = Chord(root: .c, quality: .suspended4)
        XCTAssertEqual(chord.midiNotes(octave: 4), [60, 65, 67])
        XCTAssertEqual(chord.displayName, "Csus4")
    }

    // MARK: - Sevenths

    func testGDominant7() {
        let chord = Chord(root: .g, quality: .dominant7)
        // G4 = 67, +4 = 71, +7 = 74, +10 = 77
        XCTAssertEqual(chord.midiNotes(octave: 4), [67, 71, 74, 77])
        XCTAssertEqual(chord.displayName, "G7")
    }

    func testCMinor7() {
        let chord = Chord(root: .c, quality: .minor7)
        XCTAssertEqual(chord.midiNotes(octave: 4), [60, 63, 67, 70])
        XCTAssertEqual(chord.displayName, "Cm7")
    }

    func testCMajor7() {
        let chord = Chord(root: .c, quality: .major7)
        XCTAssertEqual(chord.midiNotes(octave: 4), [60, 64, 67, 71])
        XCTAssertEqual(chord.displayName, "Cmaj7")
    }

    // MARK: - Voicing register

    func testOctaveShiftsAllVoices() {
        let chord = Chord(root: .c, quality: .major)
        XCTAssertEqual(chord.midiNotes(octave: 3), [48, 52, 55])
        XCTAssertEqual(chord.midiNotes(octave: 5), [72, 76, 79])
    }

    // MARK: - Identity

    func testEqualityIgnoresIdentityWhenIdsDiffer() {
        let a = Chord(root: .c, quality: .major)
        let b = Chord(root: .c, quality: .major)
        // Distinct ids → not equal. This is intentional: the id makes each
        // chord-on-the-timeline addressable for SwiftUI list diffing.
        XCTAssertNotEqual(a, b)
    }

    func testSameIdEqualWhenContentMatches() {
        let id = UUID()
        let a = Chord(id: id, root: .c, quality: .major)
        let b = Chord(id: id, root: .c, quality: .major)
        XCTAssertEqual(a, b)
    }
}
