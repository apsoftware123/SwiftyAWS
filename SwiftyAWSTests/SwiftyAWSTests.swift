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

//
// You can obtain a AWS identity by following this link https://console.aws.amazon.com/cognito/federated
// Follow the tutorial in this path https://docs.aws.amazon.com/aws-mobile/latest/developerguide/how-to-integrate-an-existing-bucket.html
// For an example on how to generate a cognito ID
import XCTest
@testable import SwiftyAWS

class SwiftyAWSTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUploadUsingSingleton() {
        
        let expected = expectation(description: "Should upload to S3")

        SwiftyAWS.main.bucketName = "crash-chat"
        SwiftyAWS.main.configure(type: .USEast1, identity: "xxxxx-xxxx--xxxxx-xxxx-xxxxx-xxxxx")
        
        let bundle = Bundle.init(for: SwiftyAWSTests.self)
        let image = UIImage(named: "cheetah.jpg", in: bundle, compatibleWith: nil)
        
        SwiftyAWS.main.upload(image: image, type: .png, name: .efficient, permission: .publicReadWrite) { (path, error) in
           
            if error != nil {
                print(error!)
                XCTAssertTrue(false)
            }
            
            XCTAssertTrue(true, path!)
            expected.fulfill()
        }

        waitForExpectations(timeout: 45) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            XCTAssert(true, "Successfully uploaded to AWS")
        }
    }
    
    func testUploadUsingSelf() {
        
        let expected = expectation(description: "Should upload to S3")
        
        SwiftyAWS.main.bucketName = "crash-chat"
        SwiftyAWS.main.configure(type: .USEast1, identity: "xxxxx-xxxx--xxxxx-xxxx-xxxxx-xxxxx")
        
        let bundle = Bundle.init(for: SwiftyAWSTests.self)
        let image = UIImage(named: "cheetah.jpg", in: bundle, compatibleWith: nil)
        
        image?.s3.upload(type: .png, name: .efficient, permission: .publicReadWrite, completionHandler: { (path, error) in
            if error != nil {
                print(error!)
                XCTAssertTrue(false)
            }
            
            XCTAssertTrue(true, path!)
            expected.fulfill()
        })
        
        waitForExpectations(timeout: 45) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            XCTAssert(true, "Successfully uploaded to AWS")
        }
    }
    
    func testDownloadUsingSingleton() {
        let expected = expectation(description: "Should download from S3")
        
        SwiftyAWS.main.bucketName = "crash-chat"
        SwiftyAWS.main.configure(type: .USEast1, identity: "xxxxx-xxxx--xxxxx-xxxx-xxxxx-xxxxx")
        
        let bundle = Bundle.init(for: SwiftyAWSTests.self)
        
        // Change imageName string to the image name that was uploaded to S3 when you ran the upload test
        SwiftyAWS.main.download(imageName: "d133eb68a94328d5f56febe461663b8b642970e5c38fb71385fc88118ce3efd9", imageExtension: .png) { (image, path, error) in
            if error != nil {
                print(error!)
                XCTAssertTrue(false)
            }
            
            XCTAssertTrue(true, path!)
            expected.fulfill()
        }

        waitForExpectations(timeout: 45) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            XCTAssert(true, "Successfully downloaded from AWS")
        }

    }
    
    func testDownloadUsingSelf() {
        let expected = expectation(description: "Should download from S3")
        
        SwiftyAWS.main.bucketName = "crash-chat"
        SwiftyAWS.main.configure(type: .USEast1, identity: "xxxxx-xxxx--xxxxx-xxxx-xxxxx-xxxxx")
        
        let bundle = Bundle.init(for: SwiftyAWSTests.self)
        
        //Change this string to the image name that was uploaded to S3 when you ran the upload test
        "d133eb68a94328d5f56febe461663b8b642970e5c38fb71385fc88118ce3efd9".s3.download(imageExtension: .png) { (image, path, error) in
            if error != nil {
                print(error!)
                XCTAssert(false)
            }
            
            XCTAssertTrue(true, path!)
            expected.fulfill()
        }
        
        waitForExpectations(timeout: 45) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            XCTAssert(true, "Successfully downloaded from AWS")
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
