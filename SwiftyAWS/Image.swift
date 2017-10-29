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
            completionHandler(nil, .errorNaming(ErrorHandlingMessages.errorNaming))
            return
        }
        
        guard let fileURL = temporaryDirectoryPath?.appendingPathComponent(fileName) else {
            completionHandler(nil, .errorCreatingTempDir(ErrorHandlingMessages.errorCreatingTempDir))
            return
        }
        
        let imageData = imageToUse.imageRepresentation(fileType: type)
        guard let _ = try? imageData?.write(to: fileURL, options: Data.WritingOptions.atomic) else {
            completionHandler(nil, .errorWritingToFile(ErrorHandlingMessages.errorWritingToFile))
            return
        }
        
        upload(withKey: fileName, body: fileURL, acl: permission, completionHandler: completionHandler)
    }
    
    func upload(withKey key: String, body: URL, acl: PermissionType, completionHandler: @escaping UIImage.UploadToS3CompletionHanndler)  {
        guard let request = AWSS3TransferManagerUploadRequest() else { return }
        guard let bucket = bucketName else { completionHandler(nil, .improperUse(ErrorHandlingMessages.improperUse)); return }
        request.bucket = bucket
        request.key = key
        request.body = body
        request.acl = acl
        
        let transferManager = AWSS3TransferManager.default()
        let uploadRequest = transferManager.upload(request)
        uploadRequest.continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
            if let _ = task.error {
                completionHandler(nil, .errorUploading(ErrorHandlingMessages.errorUploading))
                self.directImage = nil
                return nil
            }
            
            if task.result != nil {
                guard let url = self.endpointURL else { return nil }
                let pathURL = url.appendingPathComponent(bucket).appendingPathComponent(key).absoluteString
                completionHandler(pathURL, nil)
                self.directImage = nil
                return nil
            }
            
            return nil
        }
    }
}
