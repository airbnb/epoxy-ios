// Created by Tyler Hedrick on 5/21/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

@testable import Epoxy
import XCTest

class TableViewTests: XCTestCase {

  var tableView: TableView!

  // state flags
  var willDisplayBlockCalled: Bool = false
  var didEndDisplayingBlockCalled: Bool = false
  var didSelectBlockCalled: Bool = false

  override func setUp() {
    tableView = TableView()

    let model = BaseEpoxyModelBuilder(data: "", dataID: "dataID")
      .with(selectionHandler: { [weak self] _, _, _ in
        self?.didSelectBlockCalled = true
      })
      .withWillDisplay { [weak self] _, _ in
        self?.willDisplayBlockCalled = true
      }
      .withDidEndDisplaying { [weak self] _, _ in
        self?.didEndDisplayingBlockCalled = true
      }
      .build()

    tableView.setSections([EpoxySection(items: [model])], animated: false)
  }

  override func tearDown() {
    willDisplayBlockCalled = false
    didEndDisplayingBlockCalled = false
    didSelectBlockCalled = false
  }

  func testWillDisplayBlocksAreCalledWhenTheCellAppears() {
    tableView.delegate?.tableView?(
      tableView,
      willDisplay: UITableViewCell(style: .default, reuseIdentifier: "UIView"),
      forRowAt: IndexPath(row: 0, section: 0))
    XCTAssertTrue(willDisplayBlockCalled)
  }

  func testDidEndDisplayingBlocksAreCalledWhenTheCellDisappears() {
    tableView.delegate?.tableView?(
      tableView,
      didEndDisplaying: UITableViewCell(style: .default, reuseIdentifier: "UIView"),
      forRowAt: IndexPath(row: 0, section: 0))
    XCTAssertTrue(didEndDisplayingBlockCalled)
  }

  func testDidSelectBlocksAreCalledWhenTheCellIsSelected() {
    tableView.delegate?.tableView?(
      tableView,
      didSelectRowAt: IndexPath(row: 0, section: 0))
    XCTAssertTrue(didSelectBlockCalled)
  }

}
