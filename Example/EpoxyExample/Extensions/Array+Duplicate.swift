// Created by Tyler Hedrick on 2/2/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Foundation

extension Array {
  func duplicate(_ numberOfTimes: Int) -> Array {
    if numberOfTimes == 0 {
      return self
    }
    if numberOfTimes == 1 {
      return self + self
    }
    return self + duplicate(numberOfTimes - 1)
  }
}
