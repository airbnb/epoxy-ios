// Created by nick_miller on 10/22/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Foundation

public protocol EpoxyLogging {

  /// A settable block that allows custom logging before an assert is fired
  var logAssertionMessageBlock: ((String) -> Void)? { get }
}

extension EpoxyLogging {

  /// Epoxy wrapper around `assert(_ condition: Bool, _ message: String)`.
  /// This method will broadcast the message to all logging subscribers if the condition is false.
  public func epoxyAssert(_ condition: Bool, _ message: String) {
    if !condition {
      logAssertionMessageBlock?(message)
    }
    assert(condition, message)
  }

  /// Epoxy wrapper around `assertionFailure(_ message: String)`.
  /// This method will broadcast the message to all logging subscribers.
  public func epoxyAssertionFailure(_ message: String) {
    logAssertionMessageBlock?(message)
    assertionFailure(message)
  }
}

public class DefaultEpoxyLogger: EpoxyLogging {

  // MARK: Lifecycle

  public init() {}

  // MARK: Public
  
  public var logAssertionMessageBlock: ((String) -> Void)? = nil
}
