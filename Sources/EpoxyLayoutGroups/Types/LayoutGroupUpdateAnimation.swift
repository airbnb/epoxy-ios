// Created by lindsay_pond on 5/13/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import UIKit

public typealias GroupAnimationClosure = (_ animations: @escaping () -> Void, _ completion: @escaping (_ completed: Bool) -> Void) -> Void

/// Provides parameter values, which can be passed to the initializer of a Group's style.
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
  ///   - duration: a TimeInterval for animation duration, with a default value of `0.5`
  ///   - delay: a TimeInterval for animation duration, with a default value of `0.0`
  ///   - dampingRatio: a value for spring damping ratio, with a default value of `1.0`
  ///   - initialSpringVelocity: a value for initial spring velocity, wiht a default value of `0.0`
  public static func spring(
    duration: TimeInterval = 0.5,
    delay: TimeInterval = 0.0,
    dampingRatio: CGFloat = 1.0,
    initialSpringVelocity: CGFloat = 0.0)
  -> LayoutGroupUpdateAnimation
  {
    .init(id: SpringAnimationParameters(
      duration: duration,
      delay: delay,
      dampingRatio: dampingRatio,
      initialSpringVelocity: initialSpringVelocity)) { animations, completion in
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
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

private struct SpringAnimationParameters: Hashable {
  let duration: TimeInterval
  let delay: TimeInterval
  let dampingRatio: CGFloat
  let initialSpringVelocity: CGFloat
}
