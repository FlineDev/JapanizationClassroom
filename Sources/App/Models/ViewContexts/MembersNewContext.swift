import Vapor

struct MembersNewContext: Encodable {
    let browserSupportsDateInput: Bool
    let todayDate: String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }()
}
