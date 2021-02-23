//
//  GoogleOAuth.swift
//  Schedule_B
//
//  Created by Shin on 2/19/21.
//

import Foundation
import CommonCrypto

struct GoogleOAuthConfig {
    let requestScope: CalendarAPIScope
    private let clientID = "285345924946-19dlip45paennomcrq6o82m194codj8p.apps.googleusercontent.com"
    let callbackURLScheme = "com.googleusercontent.apps.285345924946-19dlip45paennomcrq6o82m194codj8p"
    private var redirectURI: String {
        callbackURLScheme + ":/oauth2redirect"
    }
    private let pkce = PKCE()
    func checkStateIsValid(_ state: String) -> Bool {
        state == pkce.state
    }
    var handShakeUrl: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "accounts.google.com"
        components.path = "/o/oauth2/v2/auth"
        components.queryItems = [
            "scope": requestScope.url,
            "response_type": "code",
            "redirect_uri": redirectURI,
            "code_challenge": pkce.codeChallenage,
            "code_challenge_method": pkce.codeChallengeMethod,
            "state": pkce.state,
            "client_id": clientID
        ].map { URLQueryItem(name: $0, value: $1)}
        return components.url!
    }
    func makeRequest(by code: String)-> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "oauth2.googleapis.com"
        components.path = "/token"
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let parameters = [
            "code": code,
            "client_id": clientID,
            "code_verifier": pkce.codeVerifier,
            "redirect_uri": redirectURI,
            "grant_type": "authorization_code",
        ]
        guard let body = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            fatalError("Fail to make http request \n \(parameters)")
        }
        request.httpBody = body
        request.setValue("Host", forHTTPHeaderField: "oauth2.googleapis.com")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    init(for scope: CalendarAPIScope) {
        requestScope = scope
    }
    
    enum CalendarAPIScope: Int {
        case calendarReadAndWrite
        case calendarReadOnly
        case eventReadAndWrite
        case eventReadOnly
        
        var url: String {
            switch self {
            case .calendarReadAndWrite:
                return "https://www.googleapis.com/auth/calendar"
            case .calendarReadOnly:
                return "https://www.googleapis.com/auth/calendar.readonly"
            case .eventReadAndWrite:
                return "https://www.googleapis.com/auth/calendar.events"
            case .eventReadOnly:
                return "https://www.googleapis.com/auth/calendar.events.readonly"
            }
        }
    }
    
    private struct PKCE {
        let codeVerifier: String
        let codeChallenage: String
        let codeChallengeMethod = "S256"
        let state: String
        static func trim(_ str: String) -> String {
            str.replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
                .trimmingCharacters(in: .whitespaces)
        }
        init() {
            var buffer = [UInt8](repeating: 0, count: 32)

            _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)

            codeVerifier = PKCE.trim(Data(buffer).base64EncodedString())
            guard let data = codeVerifier.data(using: .ascii) else { fatalError("Fail to create PKCE instance") }
            buffer = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            data.withUnsafeBytes {
                _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &buffer)
            }
            let hash = Data(buffer)
            codeChallenage = PKCE.trim(hash.base64EncodedString())
            buffer = [UInt8](repeating: 0, count: 32)
            _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
            state = PKCE.trim(Data(buffer).base64EncodedString())
        }
    }
}
