//
//  GoogleOAuthController.swift
//  Schedule_B
//
//  Created by Shin on 2/20/21.
//

import Foundation
import WebKit
import AuthenticationServices

struct OAuthGather {
    private let handShakePromise: Promise<Data>
    private let config: GoogleOAuthConfig
    let tokenPromise: Future<OAuthGather.OAuthToken>
    
    init(with config: GoogleOAuthConfig, drawTo presentationContextProvider: ASWebAuthenticationPresentationContextProviding, errorHandling: @escaping (Error) -> Void) {
        let promise = Promise<Data>()
        let session = ASWebAuthenticationSession(url: config.handShakeUrl, callbackURLScheme: config.callbackURLScheme) {callbackURL, error in
            guard error == nil, let callbackURL = callbackURL else {
                print("error with request OAuth: \(error!.localizedDescription)")
                    errorHandling(error!)
                return
            }
            guard let state = URLComponents(string: callbackURL.absoluteString)?.queryItems?.first(
                    where: { $0.name == "state"} )?.value, config.checkStateIsValid(state) else {
                fatalError("Received state is not valid")
            }
            guard let code = URLComponents(string: callbackURL.absoluteString)?.queryItems?.first(where: { $0.name == "code"
            })?.value else {
                let error = NSError(domain: ASWebAuthenticationSessionError.errorDomain,
                                    code: 1, userInfo: nil)
                errorHandling(error)
                return
            }
            let request = config.makeRequest(by: code)
            _ = request.sendWithPromise(promise)
        }
        self.config = config
        
        self.handShakePromise = promise
        let tokenPromise = Promise<OAuthGather.OAuthToken>()
        self.tokenPromise = tokenPromise
        promise.observe { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    tokenPromise.resolve(with: try decoder.decode(OAuthGather.OAuthToken.self, from: data))
                }catch {
                    errorHandling(error)
                }
            case .failure(let error):
                errorHandling(error)
            }
        }
        session.presentationContextProvider = presentationContextProvider
        session.prefersEphemeralWebBrowserSession = true
        session.start()
    }
    
    struct OAuthToken: Codable {
        
        let expires_at: Date
        let refresh_token: String
        let access_token: String
        let token_type: String
        let scope: String
        
    }
}



extension OAuthGather.OAuthToken {
    // JSON encode & decode
    enum CodingKeys: String, CodingKey {
        case access_token
        case refresh_token
        case scope
        case token_type
        case expires_in
        case expires_at
    }
    init(access_token: String, refresh_token: String, scope: String, token_type: String, expires_at: Date) {
        self.access_token = access_token
        self.refresh_token = refresh_token
        self.scope = scope
        self.token_type = token_type
        self.expires_at = expires_at
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    
        try container.encode(access_token, forKey: .access_token)
        try container.encode(refresh_token, forKey: .refresh_token)
        try container.encode(token_type, forKey: .token_type)
        try container.encode(scope, forKey: .scope)
        try container.encode(expires_at, forKey: .expires_at)
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let access_token = try container.decode(String.self, forKey: .access_token)
        let refresh_token = try container.decode(String.self, forKey: .refresh_token)
        let scope = try container.decode(String.self, forKey: .scope)
        let token_type = try container.decode(String.self, forKey: .token_type)
        let expires_at: Date
        if let expires_in = try? container.decode(Int.self, forKey: .expires_in) {
            expires_at = Calendar.current.date(byAdding: .second, value: expires_in, to: Date()) ?? Date()
        }else {
            expires_at = try container.decode(Date.self, forKey: .expires_at)
        }
        self = OAuthGather.OAuthToken(
            access_token: access_token,
            refresh_token: refresh_token,
            scope: scope,
            token_type: token_type,
            expires_at: expires_at)
    }
    // Save in keychain
    static let keyChainAccountForGoogleOAuth = "GoolgeOAuthToken"
    func saveInKeyChain(for account: String) -> OSStatus{
        guard let data = try? JSONEncoder().encode(self) else {
            return errSecConversionError
        }
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: Bundle.main.bundleIdentifier!,
            kSecAttrAccount: account,
            kSecValueData: data]
        SecItemDelete(query as CFDictionary)
        
        return SecItemAdd(query as CFDictionary, nil)
    }
    static func readInKeyChain(for account: String) -> OAuthGather.OAuthToken?{
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: Bundle.main.bundleIdentifier!,
            kSecAttrAccount: account,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnAttributes: true,
            kSecReturnData: true
        ]
        var item: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &item) != errSecSuccess{
            return nil
        }
        if let foundItem = item as? [String: Any],
           let data = foundItem[kSecValueData as String] as? Data {
            return try? JSONDecoder().decode(OAuthGather.OAuthToken.self, from: data)
        }else {
            return nil
        }
    }
}
