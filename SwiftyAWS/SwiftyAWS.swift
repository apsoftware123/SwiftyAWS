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

open class SwiftyAWS {
    
    public typealias FileExtension = FileNamingConvetion
    public typealias ImageUploadHandler = UIImage.UploadToS3CompletionHanndler
    
    open var bucketName: String?
    
    var directImage: UIImage?
    
    open var endpointURL: URL = AWSS3.default().configuration.endpoint.url
    
    open static var main = SwiftyAWS()

    open func configure(type: AWSRegionType, identity: String)  {
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: type,
                                                                identityPoolId: identity)
        
        let configuration = AWSServiceConfiguration(region: type, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
}
