//
//  SwiftyAWS.swift
//  SwiftyAWS
//
//  Created by Andres Peguero on 10/28/17.
//  Copyright © 2017 Andres. All rights reserved.
//

import Foundation
import AWSCognito
import UIKit
import CryptoSwift

open class SwiftyAWS {
    
    var bucketName: String?
    
    open static var main = SwiftyAWS()

    func configure(type: AWSRegionType, identity: String)  {
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: type,
                                                                identityPoolId: identity)
        
        let configuration = AWSServiceConfiguration(region: type, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    var temporaryDirectoryPath: URL? {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("upload")
    }
    
    func createTemporaryDirectory() {
        do {
            let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("upload")
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Creating 'upload' directory failed. Error: \(error)")
        }
    }
}

public enum ImageType: String {
    case png = ".png"
    case jpeg = ".jpeg"
}

public enum FileNamingConvetion {
    case effient
    case custom(String)
}

public enum ErrorHandling: Error {
    case errorUploading
    case errorNaming
    case errorCreatingTempDir
    case errorWritingToFile
}

extension UIImage {
    
    public typealias UploadToS3CompletionHanndler = (_ success: String?, _ error: ErrorHandling?) -> Void
    
    open var s3: SwiftyAWS {
        return SwiftyAWS.main
    }
    
    open func upload(type: ImageType, name: FileNamingConvetion, completionHandler: UploadToS3CompletionHanndler) {
        guard let fileName = self.convertToBase64(fileType: type)?.sha256().appending(".png") else {
            completionHandler(nil, .errorNaming)
            return
        }
        
        guard let fileURL = s3.temporaryDirectoryPath?.appendingPathComponent(fileName) else {
            completionHandler(nil, .errorCreatingTempDir)
            return
        }
        
        let imageData = UIImagePNGRepresentation(self)
        guard let _ = try? imageData?.write(to: fileURL, options: Data.WritingOptions.atomic) else {
            completionHandler(nil, .errorWritingToFile)
            return
        }
    }
    
    func convertToBase64(fileType: ImageType) -> String? {
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
