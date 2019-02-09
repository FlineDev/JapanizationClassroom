import Vapor

struct Average: Encodable {
    let level: Double
    let apprentice: Double
    let guru: Double
    let master: Double
    let enlightened: Double
    let burned: Double

    let unlocksPerDay: Double

    var unlocked: Double {
        return apprentice + guru + master + enlightened + burned
    }
}
