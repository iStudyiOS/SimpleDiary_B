//
//  ViewControllerExtension.swift
//  Schedule_B
//
//  Created by Shin on 2/20/21.
//

import UIKit
import AuthenticationServices

extension UIViewController: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
}
