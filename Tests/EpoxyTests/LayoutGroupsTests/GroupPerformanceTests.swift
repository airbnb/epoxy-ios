// Created by Tyler Hedrick on 11/12/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyLayoutGroups
import XCTest

class GroupPerformanceTests: XCTestCase {

  let window = UIWindow(frame: .init(x: 0, y: 0, width: 375, height: 667))
  var view: UIView!

  override func setUp() {
    view = UIView(frame: .init(x: 0, y: 0, width: 350, height: 400))
    view.translatesAutoresizingMaskIntoConstraints = false
    window.addSubview(view)
  }

  // tests that VGroup performance is at least as good as UIStackView's performance
  func testPerformanceOfVGroupAgainstUIStackView() {
    let vGroupItems: [GroupItemModeling] = (0...10).map { _ in
      let label = UILabel.example
      return GroupItem(dataID: UUID()) { label }
    }
    // we use `measureAverageTime` instead of the built-in `measure` so we can
    // compare the results of the layout operation
    let vGroupPerformance = measureAverageTime {
      let group = VGroup(spacing: 8, items: vGroupItems)
      group.install(in: view)
      group.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
      group.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
      view.layoutIfNeeded()
    }

    let stackViewItems = (0...100).map { _ in UILabel.example }
    let stackViewPerformance = measureAverageTime {
      let stackView = UIStackView(arrangedSubviews: stackViewItems)
      stackView.translatesAutoresizingMaskIntoConstraints = false
      stackView.axis = .vertical
      stackView.spacing = 8
      view.addSubview(stackView)
      stackView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
      stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
      view.layoutIfNeeded()
    }

    // allow a half-frame worth of difference to account for flakiness
    let epsilon = 1.0 / 120.0
    XCTAssertLessThanOrEqual(vGroupPerformance, stackViewPerformance + epsilon)
  }

  func testPerformanceOfHGroupAgainstUIStackView() {
    let hGroupItems: [GroupItemModeling] = (0...10).map { _ in
      let label = UILabel.example
      return GroupItem(dataID: UUID()) { label }
    }
    // we use `measureAverageTime` instead of the built-in `measure` so we can
    // compare the results of the layout operation
    let hGroupPerformance = measureAverageTime {
      let group = HGroup(spacing: 8, items: hGroupItems)
      group.install(in: view)
      group.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
      group.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
      view.layoutIfNeeded()
    }

    let stackViewItems = (0...100).map { _ in UILabel.example }
    let stackViewPerformance = measureAverageTime {
      let stackView = UIStackView(arrangedSubviews: stackViewItems)
      stackView.translatesAutoresizingMaskIntoConstraints = false
      stackView.axis = .horizontal
      stackView.spacing = 8
      view.addSubview(stackView)
      stackView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
      stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
      view.layoutIfNeeded()
    }

    // allow a half-frame worth of difference to account for flakiness
    let epsilon = 1.0 / 120.0
    XCTAssertLessThanOrEqual(hGroupPerformance, stackViewPerformance + epsilon)
  }

}
