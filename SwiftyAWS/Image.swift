//
//  Image.swift
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

extension SwiftyAWS {
    
    private func imageToUse(_ image: UIImage?) -> UIImage? {
        if directImage != nil {
            return directImage!
        } else if image != nil {
            return image!
        } else {
            print("Improper use of the API: This method must contain a UIImage reference")
            return nil
        }
    }
    
    open func upload(image: UIImage? = nil,
                     type: ImageType,
                     name: FileExtension,
                     permission: PermissionType,
                     completionHandler: @escaping ImageUploadHandler) {
        
        guard let imageToUse = imageToUse(image) else { return }
        
        let fileTypeExtension = type.rawValue
        guard let fileName = imageToUse.convertToBase64(fileType: type)?.sha256().appending(fileTypeExtension) else {
            completionHandler(nil, .errorNaming)
            return
        }
        
        guard let fileURL = imageToUse.temporaryDirectoryPath?.appendingPathComponent(fileName) else {
            completionHandler(nil, .errorCreatingTempDir)
            return
        }
        
        let imageData = imageToUse.imageRepresentation(fileType: type)
        guard let _ = try? imageData?.write(to: fileURL, options: Data.WritingOptions.atomic) else {
            completionHandler(nil, .errorWritingToFile)
            return
        }
        
        upload(withKey: fileName, body: fileURL, acl: permission, completionHandler: completionHandler)
    }
    
    func upload(withKey key: String, body: URL, acl: PermissionType,completionHandler: @escaping UIImage.UploadToS3CompletionHanndler)  {
        
        guard let request = AWSS3TransferManagerUploadRequest() else { return }
        guard let bucket = bucketName else { completionHandler(nil, .improperUse); return }
        request.bucket = bucket
        request.key = key
        request.body = body
        request.acl = acl
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(request).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
            if let _ = task.error {
                completionHandler(nil, .errorUploading)
                self.directImage = nil
                return nil
            }
            
            if task.result != nil {
                let pathURL = self.endpointURL.appendingPathComponent(bucket).appendingPathComponent(key).absoluteString
                completionHandler(pathURL, nil)
                self.directImage = nil
                return nil
            }
            
            return nil
        }
    }
}
