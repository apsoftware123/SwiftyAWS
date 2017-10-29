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

public enum ImageType: String {
    case png = ".png"
    case jpeg = ".jpeg"
}

public enum FileNamingConvetion {
    case effient
    case custom(String)
}

struct ErrorHandlingMessages {
    static var errorUploading = "-- We weren't able to upload the file to S3 bucket."
    static var errorNaming = "-- Encountered error with the naming convensation."
    static var errorCreatingTempDir = "-- Error creating temporary directory."
    static var errorWritingToFile = "-- Writing to file failed."
    static var improperUse = "-- Bucket name cannot be nil when uploading file."
}

public enum ErrorHandling: Error {
    case errorUploading(String)
    case errorNaming(String)
    case errorCreatingTempDir(String)
    case errorWritingToFile(String)
    case improperUse(String)
}

public class SwiftyAWS {
    
    public typealias PermissionType = AWSS3ObjectCannedACL
    public typealias FileExtension = FileNamingConvetion
    public typealias ImageUploadHandler = UIImage.UploadToS3CompletionHanndler
    
    public var bucketName: String?
    
    var directImage: UIImage?
    
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
