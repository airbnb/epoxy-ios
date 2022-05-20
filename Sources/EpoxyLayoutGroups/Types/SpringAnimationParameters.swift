// Created by lindsay_pond on 5/13/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import UIKit

/// Provides parameter values, which can be passed to customize the animation on an Group's animated update (`_setItems(::)`).
public struct LayoutGroupUpdateAnimation {
  public init(id: AnyHashable, animate: @escaping GroupAnimationClosure) {
    self.id = id
    self.animate = animate

  }
  public var id: AnyHashable
  public var animate: GroupAnimationClosure
}

extension LayoutGroupUpdateAnimation {

  // Creates a spring style `LayoutGroupUpdateAnimation` instance with default or custom values
  /// - Parameters:
  ///   - duration: a static TimeInterval for animation duration, with a default value of `0.5`
  ///   - delay: a static TimeInterval for animation duration, with a default value of `0.0`
  ///   - dampingRatio: a static value for spring damping ratio, with a default value of `1.0`
  ///   - initialSpringVelocity: a static value for initial spring velocity, wiht a default value of `0.0`
  public static func spring(
    duration: TimeInterval = 0.5,
    delay: TimeInterval = 0.0,
    dampingRatio: CGFloat = 1.0,
    initialSpringVelocity: CGFloat = 0.0)
  -> LayoutGroupUpdateAnimation
  {
    .init(id: AnimationID.spring) { animations, completion in
      UIView.animate(
          withDuration: duration,
          delay: delay,
          usingSpringWithDamping: dampingRatio,
          initialSpringVelocity: initialSpringVelocity,
          options: [.beginFromCurrentState, .allowUserInteraction],
          animations: animations,
          completion: completion)
    }
  }
}



extension LayoutGroupUpdateAnimation: Hashable {
  public static func == (lhs: LayoutGroupUpdateAnimation, rhs: LayoutGroupUpdateAnimation) -> Bool {
    return lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(id)
  }
}

private enum AnimationID: String {
  case spring
}

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
