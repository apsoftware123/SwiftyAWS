//
//  SwiftyAWS.swift
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

open class SwiftyAWS {
    
    open var bucketName: String?
    
    open var endpointURL: URL = AWSS3.default().configuration.endpoint.url
    
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
    
    func upload(withKey key: String, body: URL, completionHandler: @escaping UIImage.UploadToS3CompletionHanndler)  {
        
        guard let request = AWSS3TransferManagerUploadRequest() else { return }
        guard let bucket = bucketName else { return }
        request.bucket = bucket
        request.key = key
        request.body = body
        request.acl = .publicReadWrite
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(request).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
            if let _ = task.error {
                completionHandler(nil, .errorUploading)
                return nil
            }
            
            if task.result != nil {
                let pathURL = self.endpointURL.appendingPathComponent(bucket).appendingPathComponent(key).absoluteString
                completionHandler(pathURL, nil)
                return nil
            }
            
            return nil
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
    
    public typealias UploadToS3CompletionHanndler = (_ path: ImagePath?, _ error: ErrorHandling?) -> Void
    public typealias ImagePath = String
    
    open var s3: SwiftyAWS {
        return SwiftyAWS.main
    }
    
    open func upload(type: ImageType, name: FileNamingConvetion, completionHandler: @escaping UploadToS3CompletionHanndler) {
        
        let fileTypeExtension = type.rawValue
        guard let fileName = self.convertToBase64(fileType: type)?.sha256().appending(fileTypeExtension) else {
            completionHandler(nil, .errorNaming)
            return
        }
        
        guard let fileURL = s3.temporaryDirectoryPath?.appendingPathComponent(fileName) else {
            completionHandler(nil, .errorCreatingTempDir)
            return
        }
        
        let imageData = self.imageRepresentation(fileType: type)
        guard let _ = try? imageData?.write(to: fileURL, options: Data.WritingOptions.atomic) else {
            completionHandler(nil, .errorWritingToFile)
            return
        }
        
        s3.upload(withKey: fileName, body: fileURL, completionHandler: completionHandler)
    }
    
    func imageRepresentation(fileType: ImageType) -> Data? {
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
