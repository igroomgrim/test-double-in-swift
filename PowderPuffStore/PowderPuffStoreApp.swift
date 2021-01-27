//
//  PowderPuffStoreApp.swift
//  PowderPuffStore
//
//  Created by iGROOMGRiM on 26/1/2564 BE.
//

import SwiftUI

@main
struct PowderPuffStoreApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

enum Grade {
  case smooth
  case strong
  case invisible
}

struct Powder {
  let grade: Grade
  let price: Int
}

protocol APIService {
  func getPowderInStock() -> Result<[Powder], Error>
}

protocol MessengerService {
  func sendMessage(to id: String) -> Result<Bool, Error>
}

protocol GoodsStore {
  var apiService: APIService { get }
  var lineService: MessengerService { get }
  var stocks: [Powder] { get set }

  init?(_ apiService: APIService, lineService: MessengerService)
  func getPowderInStocks() -> [Powder]
  func addPowder(_ powder: Powder)
  func removePowder() -> Powder?
  func sendMessage(to lineID: String)
}

class PowderAPIService: APIService {
  func getPowderInStock() -> Result<[Powder], Error> {
    let powder1 = Powder(grade: .smooth, price: 100)
    let powder2 = Powder(grade: .strong, price: 200)
    let powder3 = Powder(grade: .invisible, price: 300)

    return .success([powder1, powder2, powder3])
  }
}

class LineMessengerService: MessengerService {
  func sendMessage(to groupID: String) -> Result<Bool, Error> {
    // Call some api for send message
    return .success(true)
  }
}

enum PowderStoreError: Error {
  case apiServiceIsUnavailable
  case lineServiceIsUnavailable
}

class PowderPuffStore: GoodsStore {
  let apiService: APIService
  let lineService: MessengerService
  var stocks: [Powder] = []

  required init?(_ apiService: APIService, lineService: MessengerService) {
    self.apiService = apiService
    self.lineService = lineService

    let getStocksResult = apiService.getPowderInStock()
    switch getStocksResult {
    case .success(let stocks):
      self.stocks = stocks
    case .failure(let error):
      // Handle error here
      return nil
    }
  }

  func getPowderInStocks() -> [Powder] {
    return stocks
  }

  func addPowder(_ powder: Powder) {
    stocks.append(powder)
  }

  func removePowder() -> Powder? {
    return stocks.removeFirst()
  }

  func sendMessage(to lineID: String) {
    let sendMessageResult = lineService.sendMessage(to: lineID)
    switch sendMessageResult {
    case .success(_):
      print("Send message to lineID: \(lineID) success")
    case .failure(let error):
      print(error.localizedDescription)
    }
  }
}
