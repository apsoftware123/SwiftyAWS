//
// Copyright 2010-2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at
//
// http://aws.amazon.com/apache2.0
//
// or in the "license" file accompanying this file. This file is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing
// permissions and limitations under the License.
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

extension String {
    public typealias DownloadFromS3CompletionHanndler = (_ image: UIImage?, _ path: String?, _ error: ErrorHandling?) -> Void
    public typealias ImageData = String
    
    public var s3: SwiftyAWS {
        SwiftyAWS.main.directName = self
        return SwiftyAWS.main
    }

}
