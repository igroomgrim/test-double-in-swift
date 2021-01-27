//
//  PowderPuffStoreTests.swift
//  PowderPuffStoreTests
//
//  Created by iGROOMGRiM on 26/1/2564 BE.
//

import XCTest
@testable import PowderPuffStore

class PowderPuffStoreTests: XCTestCase {
  // Mocks
  class MockPowderAPIService: APIService {
    var checkGetPowderInStockeWasCalled = false

    func getPowderInStock() -> Result<[Powder], Error> {
      checkGetPowderInStockeWasCalled = true
      return .success([])
    }
  }

  class MockLineMessengerService: MessengerService {
    var checkSendMessageWasCalled = false
    var lineID = ""

    func sendMessage(to id: String) -> Result<Bool, Error> {
      checkSendMessageWasCalled = true
      lineID = id

      return .success(true)
    }
  }

  func testGetPowderInStockWasCalledWhenInitialSuccess() {
    let apiService = MockPowderAPIService()
    let lineService = MockLineMessengerService()
    let _ = PowderPuffStore(apiService, lineService: lineService)

    XCTAssertTrue(apiService.checkGetPowderInStockeWasCalled)
  }

  func testLineMessengerServiceSendMessageWasCalled() {
    let apiService = MockPowderAPIService()
    let lineService = MockLineMessengerService()
    let powderPuffStore = PowderPuffStore(apiService, lineService: lineService)

    let lineID = "igroomgrim"
    powderPuffStore?.sendMessage(to: lineID)

    XCTAssertTrue(lineService.checkSendMessageWasCalled)
    XCTAssertEqual(lineService.lineID, lineID)
  }

  // Stubs
  class StubPowderAPIService: APIService {
    func getPowderInStock() -> Result<[Powder], Error> {
      return .failure(PowderStoreError.apiServiceIsUnavailable)
    }
  }

  class StubLineMessengerService: MessengerService {
    func sendMessage(to id: String) -> Result<Bool, Error> {
      return .success(true)
    }
  }

  func testPowerPuffStoreInitailFailed() {
    let apiService = StubPowderAPIService()
    let lineService = StubLineMessengerService()
    let powderPuffStore = PowderPuffStore(apiService, lineService: lineService)

    XCTAssertNil(powderPuffStore)
  }

  // Dummy
  class DummyPowderAPIService: APIService {
    func getPowderInStock() -> Result<[Powder], Error> {
      return .success([])
    }
  }

  class DummyLineMessengerService: MessengerService {
    func sendMessage(to id: String) -> Result<Bool, Error> {
      return .failure(PowderStoreError.lineServiceIsUnavailable)
    }
  }

  func testPowderPuffStoreInitialSuccess() {
    let apiService = DummyPowderAPIService()
    let lineService = DummyLineMessengerService()
    let powderPuffStore = PowderPuffStore(apiService, lineService: lineService)

    XCTAssertNotNil(powderPuffStore)
  }

  // Spies
  class SpyPowderAPIService: APIService {
    var checkGetPowderInStockWasCalledCount = 0

    func getPowderInStock() -> Result<[Powder], Error> {
      checkGetPowderInStockWasCalledCount += 1
      return .success([])
    }
  }

  class SpyLineMessengerService: MessengerService {
    var checkSendMessageWasCalledCount = 0

    func sendMessage(to id: String) -> Result<Bool, Error> {
      checkSendMessageWasCalledCount += 1
      return .success(true)
    }
  }

  func testGetPowderInStockWasCalledOnceWhenInitialSuccess() {
    let apiService = SpyPowderAPIService()
    let lineService = SpyLineMessengerService()
    let _ = PowderPuffStore(apiService, lineService: lineService)

    XCTAssertEqual(apiService.checkGetPowderInStockWasCalledCount, 1)
  }

  func testLineMessengerServiceSendMessage() {
    let apiService = SpyPowderAPIService()
    let lineService = SpyLineMessengerService()
    let powderPuffStore = PowderPuffStore(apiService, lineService: lineService)

    powderPuffStore?.sendMessage(to: "1112")
    powderPuffStore?.sendMessage(to: "1234")

    XCTAssertEqual(lineService.checkSendMessageWasCalledCount, 2)
  }

  // Fake
  class FakePowderAPIService: APIService {
    func getPowderInStock() -> Result<[Powder], Error> {
      let powder = Powder(grade: .smooth, price: 100)
      return .success([powder])
    }
  }

  class FakePowerPuffStore: GoodsStore {
    var apiService: APIService
    var lineService: MessengerService
    var stocks: [Powder]

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

  func testAddAndRemovePowderInStore() {
    let apiService = FakePowderAPIService()
    let lineService = SpyLineMessengerService()
    let powderPuffStore = FakePowerPuffStore(apiService, lineService: lineService)

    // Check stock count after initial PowerPuffStore
    XCTAssertEqual(powderPuffStore?.getPowderInStocks().count, 1)

    // Add 3 powder to store
    powderPuffStore?.addPowder(Powder(grade: .smooth, price: 100))
    powderPuffStore?.addPowder(Powder(grade: .strong, price: 200))
    powderPuffStore?.addPowder(Powder(grade: .invisible, price: 300))

    // Check stock count after add 3 powder to store, powder in store count must be 4 in stock
    XCTAssertEqual(powderPuffStore?.getPowderInStocks().count, 4)

    // Remove 2 powder from store
    _ = powderPuffStore?.removePowder()
    _ = powderPuffStore?.removePowder()

    // Check stock count after remove 2 powder to store, powder in store count must be 2 in stock
    XCTAssertEqual(powderPuffStore?.getPowderInStocks().count, 2)
  }
}
