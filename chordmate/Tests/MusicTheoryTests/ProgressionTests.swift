import XCTest
@testable import MusicTheory

final class ProgressionTests: XCTestCase {

    func testSecondsPerChordAt100BPM() {
        let p = Progression(chords: [], bpm: 100, beatsPerChord: 4)
        // 4 beats * 60s / 100 BPM = 2.4s
        XCTAssertEqual(p.secondsPerChord, 2.4, accuracy: 1e-9)
    }

    func testSecondsPerChordAt120BPM() {
        let p = Progression(chords: [], bpm: 120, beatsPerChord: 4)
        XCTAssertEqual(p.secondsPerChord, 2.0, accuracy: 1e-9)
    }

    func testLoopDurationScalesWithChordCount() {
        let p = Progression.demo // 4 chords @ 100 BPM, 4 beats each
        XCTAssertEqual(p.chords.count, 4)
        XCTAssertEqual(p.loopDuration, 9.6, accuracy: 1e-9)
    }

    func testEmptyProgressionLoopIsZero() {
        let p = Progression(chords: [], bpm: 120, beatsPerChord: 4)
        XCTAssertEqual(p.loopDuration, 0)
    }

    func testDemoProgressionIsCAmFG() {
        let names = Progression.demo.chords.map(\.displayName)
        XCTAssertEqual(names, ["C", "Am", "F", "G"])
    }
}
