// Created by lindsay_pond on 5/13/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import UIKit

public struct SpringAnimationParameters: Hashable {
  let duration: TimeInterval
  let delay: TimeInterval
  let dampingRatio: CGFloat
  let initialSpringVelocity: CGFloat

  public init(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, dampingRatio: CGFloat = 1.0, initialSpringVelocity: CGFloat = 0.0) {
    self.duration = duration
    self.delay = delay
    self.dampingRatio = dampingRatio
    self.initialSpringVelocity = initialSpringVelocity
  }
}
