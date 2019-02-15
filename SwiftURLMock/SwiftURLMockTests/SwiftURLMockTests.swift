//
//  SwiftURLMockTests.swift
//  SwiftURLMockTests
//
//  Created by Michael Chirico on 2/15/19.
//  Copyright © 2019 Michael Chirico. All rights reserved.
//

import XCTest
@testable import SwiftURLMock

class SwiftURLMockTests: XCTestCase {
  
  var expectation: XCTestExpectation!
  override func setUp() {
    expectation = XCTestExpectation(description: "networking")
  }
  
  override func tearDown() {
  }
  
  func testNetworkManager() {
    let network = NetworkManager()
    let url = URL(string: "https://httpbin.org/")!
    
    network.loadData(from: url) { result in
      switch result {
      case .success(let data):
        XCTAssertGreaterThan(data.count, 10)
      case .failure:
        XCTFail("❌ Error: testNetworkManager() ")
      }
      self.expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 10)
  }
  
  func testMock() {
    
    let session = NetworkSessionMock()
    let network = NetworkManager(session: session)
    
    let mockData = Data(bytes: [0, 1, 0, 1])
    session.data = mockData
    
    let url = URL(string: "blank")!
    network.loadData(from: url) { result in
      switch result {
      case .success(let data):
        XCTAssertEqual(data, mockData)
      case .failure:
        XCTFail()
      }
      self.expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10)
  }
  
  func testTimeout() {
    // This should timeout
    let sessionConfig = URLSessionConfiguration.default
    sessionConfig.timeoutIntervalForRequest = 0.1
    sessionConfig.timeoutIntervalForResource = 0.1
    
    let session = URLSession.init(configuration: sessionConfig)
    let network = NetworkManager(session: session)
    
    let url = URL(string: "https://httpbin.org/")!
    network.loadData(from: url) { result in
      switch result {
      case .success(let data):
        print("Data: \(data)")
        XCTFail("❌ Should have timed out")
      case .failure:
        print("✅ ✨Success✨")
      }
      self.expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10)
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
