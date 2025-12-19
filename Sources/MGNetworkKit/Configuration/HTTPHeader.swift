import Foundation

/// 자주 사용되는 HTTP 헤더 키
///
/// 표준 HTTP 헤더 필드명을 상수로 제공합니다.
public enum HTTPHeader {
    /// Content-Type 헤더
    public static let contentType = "Content-Type"
    
    /// Authorization 헤더
    public static let authorization = "Authorization"
    
    /// Accept 헤더
    public static let accept = "Accept"
    
    /// User-Agent 헤더
    public static let userAgent = "User-Agent"
    
    /// Accept-Language 헤더
    public static let acceptLanguage = "Accept-Language"
}

/// 자주 사용되는 Content-Type 값
public enum ContentType {
    /// application/json
    public static let json = "application/json"
    
    /// application/x-www-form-urlencoded
    public static let formURLEncoded = "application/x-www-form-urlencoded"
    
    /// multipart/form-data
    public static let multipartFormData = "multipart/form-data"
    
    /// text/plain
    public static let textPlain = "text/plain"
}

