import XCTest
@testable import MusicTheory

final class NoteTests: XCTestCase {
    func testMiddleCIsMidi60() {
        XCTAssertEqual(Note.c.midi(octave: 4), 60)
    }

    func testA4IsMidi69() {
        XCTAssertEqual(Note.a.midi(octave: 4), 69)
    }

    func testOctavesShiftBy12() {
        XCTAssertEqual(Note.c.midi(octave: 3), 48)
        XCTAssertEqual(Note.c.midi(octave: 5), 72)
    }

    func testAllPitchClassesInOctave4() {
        let expected: [UInt8] = [60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71]
        let actual = Note.allCases.map { $0.midi(octave: 4) }
        XCTAssertEqual(actual, expected)
    }

    func testDisplayNameUsesSharps() {
        XCTAssertEqual(Note.cSharp.displayName, "C♯")
        XCTAssertEqual(Note.fSharp.displayName, "F♯")
    }
}
