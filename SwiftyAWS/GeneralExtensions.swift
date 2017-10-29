//
//  GeneralExtensions.swift
//  SwiftyAWS
//
//  Created by Andres Peguero on 10/28/17.
//  Copyright © 2017 Andres. All rights reserved.
//

import Foundation
import AWSCognito
import AWSS3
import UIKit
import CryptoSwift

extension UIImage {
    
    public typealias UploadToS3CompletionHanndler = (_ path: ImagePath?, _ error: ErrorHandling?) -> Void
    public typealias ImagePath = String
    
    open var s3: SwiftyAWS {
        SwiftyAWS.main.directImage = self
        return SwiftyAWS.main
    }
    
    public func imageRepresentation(fileType: ImageType) -> Data? {
        switch fileType {
        case .png:
            guard let png = UIImagePNGRepresentation(self) else {
                return nil
            }
            return png
        default:
            guard let jpeg = UIImageJPEGRepresentation(self, 1.0) else {
                return nil
            }
            return jpeg
        }
    }
    
    public func convertToBase64(fileType: ImageType) -> String? {
        switch fileType {
        case .png:
            guard let png = UIImagePNGRepresentation(self) else {
                return nil
            }
            return png.base64EncodedString()
        default:
            guard let jpeg = UIImageJPEGRepresentation(self, 1.0) else {
                return nil
            }
            return jpeg.base64EncodedString()
        }
    }
    
}
