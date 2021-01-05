// Created by eric_horacek on 12/16/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

/// The capability of providing a flag indicating whether an operation should be animated.
public protocol AnimatedProviding {
  /// Whether this operation should be animated.
  var animated: Bool { get }
}
