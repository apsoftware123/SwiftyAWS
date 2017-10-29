//
//  SwiftyAWSTests.swift
//  SwiftyAWSTests
//
//  Created by Andres Peguero on 10/28/17.
//  Copyright © 2017 Andres. All rights reserved.
//

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
        SwiftyAWS.main.configure(type: .USEast1, identity: "us-east-1:6a386b3c-11f5-4fba-b427-2cf6b9a00cf1")
        
        let bundle = Bundle.init(for: SwiftyAWSTests.self)
        let image = UIImage(named: "cheetah.jpg", in: bundle, compatibleWith: nil)
        
        SwiftyAWS.main.upload(image: image, type: .png, name: .effient, permission: .publicReadWrite) { (path, error) in
           
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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
