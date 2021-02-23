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
    let tokenPromise: Future<TokenData>
    
    init(with config: GoogleOAuthConfig, drawTo presentationContextProvider: ASWebAuthenticationPresentationContextProviding, errorHandling: @escaping (Error) -> Void) {
        let promise = Promise<Data>()
        let session = ASWebAuthenticationSession(url: config.handShakeUrl, callbackURLScheme: config.callbackURLScheme) {callbackURL, error in
            guard error == nil, let callbackURL = callbackURL else {
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
                DispatchQueue.main.sync {
                    errorHandling(error)
                }
                return
            }
            let request = config.makeRequest(by: code)
            _ = request.sendWithPromise(promise)
        }
        self.config = config
        
        self.handShakePromise = promise
        let tokenPromise = Promise<TokenData>()
        self.tokenPromise = tokenPromise
        promise.observe { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    tokenPromise.resolve(with: try decoder.decode(TokenData.self, from: data))
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
    
    struct TokenData: Codable {
        let recievedAt = Date()
        let expires_in: Int
        let refresh_token: String
        let access_token: String
        let token_type: String
        let scope: String
    }
}


