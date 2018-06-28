
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
//

import Foundation
import AWSCognito
import AWSS3
import UIKit

public enum ImageType: String {
    case png = ".png"
    case jpeg = ".jpeg"
}

public enum FileNamingConvetion {
    case efficient
    case custom(String)
}

struct ErrorHandlingMessages {
    static var errorUploading = "-- We weren't able to upload the file to S3 bucket."
    static var errorNaming = "-- Encountered error with the naming convensation."
    static var errorCreatingTempDir = "-- Error creating temporary directory."
    static var errorWritingToFile = "-- Writing to file failed."
    static var improperUse = "-- Bucket name cannot be nil when uploading file."
    static var errorDownloading = "-- We weren't able to download the file from S3 bucket."
}

public enum ErrorHandling: Error {
    case errorUploading(String)
    case errorNaming(String)
    case errorCreatingTempDir(String)
    case errorWritingToFile(String)
    case improperUse(String)
    case errorDownloading(String)
}

public class SwiftyAWS {
//    let test = CommonCrypto()
    
    public typealias PermissionType = AWSS3ObjectCannedACL
    public typealias FileExtension = FileNamingConvetion
    public typealias ImageUploadHandler = UIImage.UploadToS3CompletionHanndler
    public typealias ImageDownloadHandler = String.DownloadFromS3CompletionHanndler
    
    public var bucketName: String?
    
    var directImage: UIImage?
    var directName: String?
    
    open var endpointURL: URL?
    
    var temporaryDirectoryPath: URL? {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("upload")
    }
    
    public static var main = SwiftyAWS()

    public func configure(type: AWSRegionType, identity: String)  {
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: type,
                                                                identityPoolId: identity)
        
        let configuration = AWSServiceConfiguration(region: type, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        endpointURL = AWSS3.default().configuration.endpoint.url

        createTemporaryDirectory()
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
