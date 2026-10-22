// Created by andy_bartholomew on 10/19/26.
// Copyright © 2026 Airbnb Inc. All rights reserved.

import EpoxyCore
import XCTest

// MARK: - SetBehaviorsTests

final class SetBehaviorsTests: XCTestCase {
  @MainActor
  func testChainingNilCallbacks() async {
    let strategy: EpoxyModelProperty<(@MainActor (Int) -> Void)?>.UpdateStrategy = .chainMainActor()
    XCTAssertNil(strategy.update(nil, nil))
  }

  @MainActor
  func testChainingKeepsOldCallbackWhenNewIsNil() async {
    let strategy: EpoxyModelProperty<(@MainActor (Int) -> Void)?>.UpdateStrategy = .chainMainActor()
    var received: Int?
    let old: @MainActor (Int) -> Void = { received = $0 }
    strategy.update(old, nil)?(1)
    XCTAssertEqual(received, 1)
  }

  @MainActor
  func testChainingKeepsNewCallbackWhenOldIsNil() async {
    let strategy: EpoxyModelProperty<(@MainActor (Int) -> Void)?>.UpdateStrategy = .chainMainActor()
    var received: Int?
    let new: @MainActor (Int) -> Void = { received = $0 }
    strategy.update(nil, new)?(2)
    XCTAssertEqual(received, 2)
  }

  @MainActor
  func testChainingCallsOldBeforeNewWithSameArgument() async {
    let strategy: EpoxyModelProperty<(@MainActor (Int) -> Void)?>.UpdateStrategy = .chainMainActor()
    var events = [String]()
    let old: @MainActor (Int) -> Void = { events.append("old:\($0)") }
    let new: @MainActor (Int) -> Void = { events.append("new:\($0)") }
    strategy.update(old, new)?(3)
    XCTAssertEqual(events, ["old:3", "new:3"])
  }

  @MainActor
  func testModelCopyAndMergePreserveCallbackOrder() async {
    var events = [String]()
    let original = BehaviorModel().setBehaviors { events.append("old:\($0)") }
    let copy = original.setBehaviors { events.append("copy:\($0)") }.setBehaviors(nil)
    let merged = copy.merging(BehaviorModel().setBehaviors { events.append("merged:\($0)") })

    original.setBehaviors?(1)
    copy.setBehaviors?(2)
    merged.setBehaviors?(3)

    XCTAssertEqual(events, ["old:1", "old:2", "copy:2", "old:3", "copy:3", "merged:3"])
  }
}

// MARK: - BehaviorModel

private struct BehaviorModel: CallbackContextEpoxyModeled, SetBehaviorsProviding {
  typealias CallbackContext = Int
  var storage = EpoxyModelStorage()
}
