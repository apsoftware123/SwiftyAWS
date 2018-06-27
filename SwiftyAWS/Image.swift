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
    
    private func nameToUse(_ imageName: String?) -> String? {
        if directName != nil {
            return directName!
        } else if imageName != nil {
            return imageName!
        } else {
            print("Improper use of the API: This method must contain a string reference")
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
            completionHandler(nil, nil, .errorNaming(ErrorHandlingMessages.errorNaming))
            return
        }
        
        guard let fileURL = temporaryDirectoryPath?.appendingPathComponent(fileName) else {
            completionHandler(nil, nil, .errorCreatingTempDir(ErrorHandlingMessages.errorCreatingTempDir))
            return
        }

        let imageData = imageToUse.imageRepresentation(fileType: type)
        guard let _ = try? imageData?.write(to: fileURL, options: Data.WritingOptions.atomic) else {
            completionHandler(nil, nil, .errorWritingToFile(ErrorHandlingMessages.errorWritingToFile))
            return
        }
        
        self.upload(withKey: fileName, body: fileURL, acl: permission, completionHandler: completionHandler)
    }
    
    func upload(withKey key: String, body: URL, acl: PermissionType, completionHandler: @escaping UIImage.UploadToS3CompletionHanndler)  {
        DispatchQueue.global(qos: .background).async {
            guard let request = AWSS3TransferManagerUploadRequest() else { return }
            guard let bucket = self.bucketName else { completionHandler(nil, nil, .improperUse(ErrorHandlingMessages.improperUse)); return }
            request.bucket = bucket
            request.key = key
            request.body = body
            request.acl = acl
            
            let transferManager = AWSS3TransferManager.default()
            let uploadRequest = transferManager.upload(request)
            uploadRequest.continueWith { (task) -> Any? in
                if let _ = task.error {
                    completionHandler(nil, nil, .errorUploading(ErrorHandlingMessages.errorUploading))
                    self.directImage = nil
                    return nil
                }
                
                if task.result != nil {
                    guard let url = self.endpointURL else { return nil }
                    let pathURL = url.appendingPathComponent(bucket).appendingPathComponent(key).absoluteString
                    completionHandler(pathURL, key, nil)
                    self.directImage = nil
                    return nil
                }
                
                return nil
            }
        }
    }
    
    open func download(imageName: String? = nil,
                       imageExtension: ImageType,
                       completionHandler: @escaping ImageDownloadHandler) {
        
        guard let nameToUse = nameToUse(imageName) else { return  }
        download(imageName: nameToUse, imageExtension: imageExtension, completionHandler: completionHandler)

    }
    
    func download(imageName: String,
                  imageExtension: ImageType,
                  completionHandler: @escaping String.DownloadFromS3CompletionHanndler) {
        
        guard let request = AWSS3TransferManagerDownloadRequest() else { return }
        guard let bucket = bucketName else { completionHandler(nil, nil, ErrorHandling.improperUse(ErrorHandlingMessages.improperUse)); return }
        
        let fileTypeExtension = imageExtension.rawValue
        
        let filename = imageName.appending(fileTypeExtension)
        
        
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        
        
        let transferManager = AWSS3TransferManager.default()
        
        
        request.bucket = bucket
        request.key = filename
        request.downloadingFileURL = downloadingFileURL
        
        
        transferManager.download(request).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error downloading1: \(request.key) Error: \(error)")
                    }
                } else {
                    print("Error downloading: \(request.key) Error: \(error)")
                }
                
                completionHandler(nil, nil, .errorDownloading(ErrorHandlingMessages.errorDownloading))
                return nil
            }
            print("Download complete for: \(request.key)")
            
            if task.result != nil {
                //Construct the image here
                guard let image = UIImage(contentsOfFile: downloadingFileURL.path) else { return nil }
                
                completionHandler(image, downloadingFileURL.path, nil)
                self.directName = nil
                return nil
            }
            return nil
        })
        
    }
}
