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

  func test_reuseIDByRegistering_withSameViewTypeSameStyleID_returnSameReuseID() {
    let viewDifferentiator1 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let viewDifferentiator2 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let firstReuseID = reuseIDStore.reuseID(byRegistering: viewDifferentiator1)
    let secondReuseID = reuseIDStore.reuseID(byRegistering: viewDifferentiator2)
    XCTAssertEqual(firstReuseID, secondReuseID)
  }

  func test_reuseIDByRegistering_withDifferentViewTypeSameStyleID_returnDifferentReuseID() {
    let viewDifferentiator1 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let viewDifferentiator2 = ViewDifferentiator(
      viewType: MySecondView.self,
      styleID: "red")
    let firstReuseID = reuseIDStore.reuseID(byRegistering: viewDifferentiator1)
    let secondReuseID = reuseIDStore.reuseID(byRegistering: viewDifferentiator2)
    XCTAssertNotEqual(firstReuseID, secondReuseID)
  }

  func test_reuseIDByRegistering_withSameViewTypeDifferentStyleID_returnDifferentReuseID() {
    let viewDifferentiator1 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let viewDifferentiator2 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "blue")
    let firstReuseID = reuseIDStore.reuseID(byRegistering: viewDifferentiator1)
    let secondReuseID = reuseIDStore.reuseID(byRegistering: viewDifferentiator2)
    XCTAssertNotEqual(firstReuseID, secondReuseID)
  }

  func test_registeredReuseIDFor_withSameViewTypeSameStyleID_returnSameReuseID() {
    let viewDifferentiator1 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let viewDifferentiator2 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let reuseIDByRegistering = reuseIDStore.reuseID(byRegistering: viewDifferentiator1)
    let registeredReuseIDFor = reuseIDStore.registeredReuseID(for: viewDifferentiator2)
    XCTAssertEqual(reuseIDByRegistering, registeredReuseIDFor)
  }

  func test_registeredReuseIDFor_whenNotRegistered_returnsNil() {
    let viewDifferentiator = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let reuseID = reuseIDStore.registeredReuseID(for: viewDifferentiator)
    XCTAssertNil(reuseID)
  }

  func test_registeredReuseIDFor_whenNotRegistered_asserts() {
    let viewDifferentiator = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    XCTAssertTrue(assertionFailures.isEmpty)
    _ = reuseIDStore.registeredReuseID(for: viewDifferentiator)
    XCTAssertFalse(assertionFailures.isEmpty)
  }

  func test_registeredReuseIDFor_withSameViewTypeDifferentStyleID_returnsFallbackReuseID() {
    let viewDifferentiator1 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let viewDifferentiator2 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "blue")
    let reuseIDByRegistering = reuseIDStore.reuseID(byRegistering: viewDifferentiator1)
    let registeredReuseIDFor = reuseIDStore.registeredReuseID(for: viewDifferentiator2)
    XCTAssertEqual(reuseIDByRegistering, registeredReuseIDFor)
  }

  func test_registeredReuseIDFor_afterSubsequentRegisterWithDifferentStyleID_returnsSameFallbackReuseID() {
    let viewDifferentiator1 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let viewDifferentiator2 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "green")
    let viewDifferentiator3 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "blue")
    _ = reuseIDStore.reuseID(byRegistering: viewDifferentiator1)
    let registeredReuseIDFor1 = reuseIDStore.registeredReuseID(for: viewDifferentiator3)

    _ = reuseIDStore.reuseID(byRegistering: viewDifferentiator2)
    let registeredReuseIDFor2 = reuseIDStore.registeredReuseID(for: viewDifferentiator3)

    XCTAssertEqual(registeredReuseIDFor1, registeredReuseIDFor2)
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
