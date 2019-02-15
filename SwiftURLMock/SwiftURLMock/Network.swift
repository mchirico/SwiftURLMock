//
//  Network.swift
//  SwiftURLMock
//
//  Created by Michael Chirico on 2/15/19.
//  Copyright © 2019 Michael Chirico. All rights reserved.
//

import Foundation

enum NetworkResult {
  case success(Data)
  case failure(Error?)
}

protocol NetworkSession {
  func loadData(from url: URL, completionHandler: @escaping (Data?, Error?) -> Void)
}

extension URLSession: NetworkSession {
  func loadData(from url: URL, completionHandler: @escaping (Data?, Error?) -> Void) {
    let task = dataTask(with: url) { (data, _, error) in
      completionHandler(data, error)
    }
    
    task.resume()
  }
}

class NetworkSessionMock: NetworkSession {
  var data: Data?
  var error: Error?
  
  func loadData(from url: URL, completionHandler: @escaping (Data?, Error?) -> Void) {
    completionHandler(data, error)
  }
}

class NetworkManager {
  private let session: NetworkSession
  
  init(session: NetworkSession = URLSession.shared) {
    self.session = session
  }
  
  func loadData(from url: URL, completionHandler: @escaping(NetworkResult) -> Void) {
    session.loadData(from: url) { (data, error) in
      let result = data.map(NetworkResult.success) ?? NetworkResult.failure(error)
      completionHandler(result)
    }
  }
}
