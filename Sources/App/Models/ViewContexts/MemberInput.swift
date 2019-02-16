import Vapor

struct MemberInput: Decodable {
    let username: String
    let waniKaniStartDate: String
    let nativeLanguages: String?
}
