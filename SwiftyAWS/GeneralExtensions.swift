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
//import CommonCrypto
import CryptoSwift


extension UIImage {
    
    public typealias UploadToS3CompletionHanndler = (_ path: ImagePath?, _ key:String?, _ error: ErrorHandling?) -> Void
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
    
    func MD5() -> String {
        let messageData = self.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))

        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        let md5Hex = digestData.map { String(format: "%02hhx", $0) }.joined()

        return md5Hex
    }
    
//    func sha256(data: Data) -> Data {
//        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
//        data.withUnsafeBytes {
//            _ = CC_SHA256($0, CC_LONG(data.count), &hash)
//        }
//        return Data(bytes: hash)
//    }
    
    // MARK: - SHA256
//    func sha256() -> String {
//        guard let data = self.data(using: .utf8) else {
//            print("Data not available")
//            return ""
//        }
//        return getHexString(fromData: digest(input: data as NSData))
//    }
//    
//    private func digest(input : NSData) -> NSData {
//        
//        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
//        var hashValue = [UInt8](repeating: 0, count: digestLength)
//        CC_SHA256(input.bytes, UInt32(input.length), &hashValue)
//        return NSData(bytes: hashValue, length: digestLength)
//    }
//    
//    private  func getHexString(fromData data: NSData) -> String {
//        var bytes = [UInt8](repeating: 0, count: data.length)
//        data.getBytes(&bytes, length: data.length)
//        
//        var hexString = ""
//        for byte in bytes {
//            hexString += String(format:"%02x", UInt8(byte))
//        }
//        return hexString
//    }
}
