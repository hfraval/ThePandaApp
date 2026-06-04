import Foundation

enum ResponseValidator {
    static func validate(
        _ response: URLResponse?,
        acceptable: ClosedRange<Int>
    ) -> NetworkError? {
        guard let http = response as? HTTPURLResponse else {
            return .unknown
        }
        return acceptable.contains(http.statusCode)
            ? nil
            : .serverError(statusCode: http.statusCode, message: nil)
    }
}
