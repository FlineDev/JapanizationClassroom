import Vapor

enum WaniKaniFetchError: Error {
    case badRequest
    case internalServerError
}

final class WaniKaniFetchService {
    func fetchUserSRSDistribution(on connectable: DatabaseConnectable, apiKey: String) throws -> Future<WaniKaniUserSRSDistribution> {
        let url = URL(string: "https://www.wanikani.com/api/user/\(apiKey)/srs-distribution")!
        let (data, httpResponse) = try URLSession.shared.data(with: URLRequest(url: url))

        switch httpResponse.statusCode {
        case 200 ..< 300:
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            let srsDistribution = try jsonDecoder.decode(WaniKaniUserSRSDistribution.self, from: data)
            return connectable.future(srsDistribution)

        case 400 ..< 500:
            throw WaniKaniFetchError.badRequest

        case 500 ..< 600:
            throw WaniKaniFetchError.internalServerError

        default:
            fatalError("Something went horribly wrong.")
        }
    }
}
