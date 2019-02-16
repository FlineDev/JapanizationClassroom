import Vapor

enum RoundTagError: Error {
    case invalidNumberOfParameters
    case invalidTypeOfParameters
}

final class RoundTag: TagRenderer {
    init() { }

    func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        switch tag.parameters.count {
        case 2:
            guard let doubleValue = tag.parameters[0].double, let maxFractionDigits = tag.parameters[1].int else {
                throw RoundTagError.invalidTypeOfParameters
            }

            let numberFormatter = NumberFormatter()
            numberFormatter.minimumIntegerDigits = 1
            numberFormatter.maximumFractionDigits = maxFractionDigits
            numberFormatter.locale = Locale(identifier: "en")

            let number = NSNumber(value: doubleValue)
            let roundedStringData = TemplateData.string(numberFormatter.string(from: number)!)

            return tag.future(roundedStringData)

        default:
            throw RoundTagError.invalidNumberOfParameters
        }
    }
}

