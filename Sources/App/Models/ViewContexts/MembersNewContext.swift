import Vapor

struct MembersNewContext: Encodable {
    let todayDate: String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }()
}
