// Created by nick_fox on 7/31/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCollectionView
import EpoxyCore
import XCTest

// MARK: - ReuseIDStoreTests

final class ReuseIDStoreTests: XCTestCase {

  // MARK: Internal

  // MARK: Setup/Teardown

  override func setUp() {
    reuseIDStore = ReuseIDStore()
    assertionFailures = []
    EpoxyLogger.shared = .init(
      assert: { (_, _, _, _) in },
      assertionFailure: { [weak self] (message, fileID, line) in
        self?.assertionFailures.append((message(), fileID, line))
      }, warn: { (_, _, _) in })
  }

  override func tearDown() {
    reuseIDStore = nil
    EpoxyLogger.shared = EpoxyLogger()
  }

  // MARK: Tests

  func test_registerReuseID_withSameViewTypeSameStyleID_returnSameReuseID() {
    let viewDifferentiator1 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let viewDifferentiator2 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let firstReuseID = reuseIDStore.registerReuseID(for: viewDifferentiator1)
    let secondReuseID = reuseIDStore.registerReuseID(for: viewDifferentiator2)
    XCTAssertEqual(firstReuseID, secondReuseID)
  }

  func test_registerReuseID_withDifferentViewTypeSameStyleID_returnDifferentReuseID() {
    let viewDifferentiator1 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let viewDifferentiator2 = ViewDifferentiator(
      viewType: MySecondView.self,
      styleID: "red")
    let firstReuseID = reuseIDStore.registerReuseID(for: viewDifferentiator1)
    let secondReuseID = reuseIDStore.registerReuseID(for: viewDifferentiator2)
    XCTAssertNotEqual(firstReuseID, secondReuseID)
  }

  func test_registerReuseID_withSameViewTypeDifferentStyleID_returnDifferentReuseID() {
    let viewDifferentiator1 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let viewDifferentiator2 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "blue")
    let firstReuseID = reuseIDStore.registerReuseID(for: viewDifferentiator1)
    let secondReuseID = reuseIDStore.registerReuseID(for: viewDifferentiator2)
    XCTAssertNotEqual(firstReuseID, secondReuseID)
  }

  func test_dequeueReuseID_withSameViewTypeSameStyleID_returnSameReuseID() {
    let viewDifferentiator1 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let viewDifferentiator2 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let registerReuseID = reuseIDStore.registerReuseID(for: viewDifferentiator1)
    let dequeueReuseID = reuseIDStore.dequeueReuseID(for: viewDifferentiator2)
    XCTAssertEqual(registerReuseID, dequeueReuseID)
  }

  func test_dequeueReuseID_whenNotRegistered_returnsNil() {
    let viewDifferentiator = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let reuseID = reuseIDStore.dequeueReuseID(for: viewDifferentiator)
    XCTAssertNil(reuseID)
  }

  func test_dequeueReuseID_whenNotRegistered_asserts() {
    let viewDifferentiator = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    XCTAssertTrue(assertionFailures.isEmpty)
    _ = reuseIDStore.dequeueReuseID(for: viewDifferentiator)
    XCTAssertFalse(assertionFailures.isEmpty)
  }

  func test_dequeueReuseID_withSameViewTypeDifferentStyleID_returnsFallbackReuseID() {
    let viewDifferentiator1 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let viewDifferentiator2 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "blue")
    let registerReuseID = reuseIDStore.registerReuseID(for: viewDifferentiator1)
    let dequeueReuseID = reuseIDStore.dequeueReuseID(for: viewDifferentiator2)
    XCTAssertEqual(registerReuseID, dequeueReuseID)
  }

  func test_dequeueReuseID_afterSubsequentRegisterWithDifferentStyleID_returnsSameFallbackReuseID() {
    let viewDifferentiator1 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let viewDifferentiator2 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "green")
    let viewDifferentiator3 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "blue")
    _ = reuseIDStore.registerReuseID(for: viewDifferentiator1)
    let dequeueReuseID1 = reuseIDStore.dequeueReuseID(for: viewDifferentiator3)

    _ = reuseIDStore.registerReuseID(for: viewDifferentiator2)
    let dequeueReuseID2 = reuseIDStore.dequeueReuseID(for: viewDifferentiator3)

    XCTAssertEqual(dequeueReuseID1, dequeueReuseID2)
  }

  // MARK: Private

  private var reuseIDStore: ReuseIDStore!
  private var assertionFailures: [(String, StaticString, UInt)]!
}

// MARK: - MyFirstView

private class MyFirstView {
  init() {}
}

// MARK: - MySecondView

private class MySecondView {
  init() {}
}
