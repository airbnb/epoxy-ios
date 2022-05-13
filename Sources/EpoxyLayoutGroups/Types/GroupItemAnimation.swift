// Created by lindsay_pond on 5/13/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Foundation

public enum GroupItemAnimation {
  case animation(SpringAnimationParameters)
  case noAnimation

  public var isAnimated: Bool {
    switch self {
    case .animation:
      return true
    case .noAnimation:
      return false
    }
  }

  public var parameters: SpringAnimationParameters? {
    guard case let .animation(parameters) = self else { return nil }
    return parameters
  }
}
