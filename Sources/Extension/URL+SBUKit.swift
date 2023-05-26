//
//  URL+Extensions.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 7/14/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

internal extension URL {
    func open() {
        let refinedURL = self.sanitise
        UIApplication.shared.open(refinedURL, options: [.universalLinksOnly: true]) { (success) in
            if !success {
                // open normally
                UIApplication.shared.open(refinedURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    var sanitise: URL {
        if var components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
          if components.scheme == nil {
            components.scheme = "https"
          }

          return components.url ?? self
        }

        return self
      }
}
