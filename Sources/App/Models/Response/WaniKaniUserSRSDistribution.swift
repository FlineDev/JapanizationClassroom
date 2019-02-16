import Vapor

struct WaniKaniUserSRSDistribution: Decodable {
    struct UserInformation: Decodable {
        let username: String
        let level: Int
    }

    struct RequestedInformation: Decodable {
        struct SRSInfo: Decodable {
            let radicals: Int
            let kanji: Int
            let vocabulary: Int
            let total: Int
        }

        let apprentice: SRSInfo
        let guru: SRSInfo
        let master: SRSInfo
        let enlighten: SRSInfo
        let burned: SRSInfo
    }

    let userInformation: UserInformation
    let requestedInformation: RequestedInformation
}
