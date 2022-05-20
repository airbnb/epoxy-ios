// Created by lindsay_pond on 5/13/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Foundation


public typealias GroupAnimationClosure = (_ animations: @escaping () -> Void, _ completion: @escaping (_ completed: Bool) -> Void) -> Void
public enum GroupAnimationStyle {
  case animation(LayoutGroupUpdateAnimation)
  case noAnimation

  public var isAnimated: Bool {
    switch self {
    case .animation:
      return true
    case .noAnimation:
      return false
    }
  }

  public var animate: GroupAnimationClosure? {
    guard case let .animation(animation) = self else { return nil }
    return animation.animate
  }
}



