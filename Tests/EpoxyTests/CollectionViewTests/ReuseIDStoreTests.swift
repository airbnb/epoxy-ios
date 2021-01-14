// Created by nick_fox on 7/31/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCollectionView
import EpoxyCore
import XCTest

final class ReuseIDStoreTests: XCTestCase {

  // MARK: Setup/Teardown

  override func setUp() {
    reuseIDStore = ReuseIDStore()
  }

  override func tearDown() {
    reuseIDStore = nil
  }

  // MARK: Tests

  func testSameViewTypeSameStyleIDReturnSameReuseID() {
    let viewDifferentiator1 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let viewDifferentiator2 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let firstReuseID = reuseIDStore.reuseID(for: viewDifferentiator1)
    let secondReuseID = reuseIDStore.reuseID(for: viewDifferentiator2)
    XCTAssertEqual(firstReuseID, secondReuseID)
  }

  func testDifferentViewTypeSameStyleIDReturnDifferentReuseID() {
    let viewDifferentiator1 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let viewDifferentiator2 = ViewDifferentiator(
      viewType: MySecondView.self,
      styleID: "red")
    let firstReuseID = reuseIDStore.reuseID(for: viewDifferentiator1)
    let secondReuseID = reuseIDStore.reuseID(for: viewDifferentiator2)
    XCTAssertNotEqual(firstReuseID, secondReuseID)
  }

  func testSameViewTypeDifferentStyleIDReturnDifferentReuseID() {
    let viewDifferentiator1 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "red")
    let viewDifferentiator2 = ViewDifferentiator(
      viewType: MyFirstView.self,
      styleID: "blue")
    let firstReuseID = reuseIDStore.reuseID(for: viewDifferentiator1)
    let secondReuseID = reuseIDStore.reuseID(for: viewDifferentiator2)
    XCTAssertNotEqual(firstReuseID, secondReuseID)
  }

  // MARK: Private

  private var reuseIDStore: ReuseIDStore!
}

// MARK: Test Helpers

private class MyFirstView {
  init() {}
}

private class MySecondView {
  init() {}
}

