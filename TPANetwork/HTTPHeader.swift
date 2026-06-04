import Foundation

public enum HTTPHeader {
    public static let accept = "Accept"
    public static let contentType = "Content-Type"
    public static let authorization = "Authorization"
    public static let apiKey = "X-Api-Key"
    public static let userAgent = "User-Agent"
}

public enum HTTPHeaderValue {
    public static let applicationJSON = "application/json"
    public static let bearerPrefix = "Bearer "
}
