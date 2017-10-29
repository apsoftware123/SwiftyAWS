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

public enum ErrorHandling: Error {
    case errorUploading
    case errorNaming
    case errorCreatingTempDir
    case errorWritingToFile
    case improperUse
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
