import Vapor

struct MemberInput: Decodable {
    let apiKey: String
    let waniKaniStartDate: String
    let nativeLanguages: String?
}
