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
  
  func testFixtureFile() {
    if let url = Bundle.main.url(forResource: "sample", withExtension: "json") {
      
      do {
        let data = try Data(contentsOf: url)
        let stringData = String(data: data, encoding: .utf8)
        
        print("StringData: \(String(describing: stringData))")
        
      } catch {
        print("Error:", error.localizedDescription)
        XCTFail()
      }
    }
  }
  
  func testReadFile() {
    let readFile = ReadFile()
    readFile.Read(forResource: "sample", withExtension: "json")
    XCTAssertGreaterThan(readFile.data?.count ?? 0, 10)
    XCTAssertGreaterThan(readFile.stringData?.count ?? 0, 10)
  }
  
  func testNetworkSessionFixtureMock() {
    let session = NetworkSessionFixtureMock(forResource: "sample",
                                            withExtension: "json")

    let network = NetworkManager(session: session)
    
    let readFile = ReadFile()
    readFile.Read(forResource: "sample", withExtension: "json")
    
    let mockData = readFile.data!
    
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
  
  func testGetData() {
    let readFile = ReadFile()
    readFile.GetData(contentsOf: URL(string: "blank")!)
    let expected = """
The file “blank” couldn’t be opened.
"""
    let result = String(describing: readFile.error)
    XCTAssert(result.contains(expected), "❌ Not throwing error in GetData")
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
