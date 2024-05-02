//
//  URL+Extensions.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 7/14/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

internal extension URL {
    func open(needSanitise: Bool = true) {
        let refinedURL = needSanitise ? self.sanitise : self
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
    
    var isFileSizeUploadable: Bool {
        if let fileResourceValues = try? self.resourceValues(forKeys: [.fileSizeKey]) {
            if let fileSize = fileResourceValues.fileSize {
                if fileSize > SBUAvailable.uploadSizeLimitBytes {
                    SBULog.error(SBUStringSet.FileUpload.Error.exceededSizeLimit)
                    return false
                }
            } else {
                SBULog.error("Can't read file size.")
            }
        }
        
        return true
    }
}
