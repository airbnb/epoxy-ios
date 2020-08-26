// Created by Noah Martin on 8/20/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

extension BarInstaller {
  public func willBeginDragging(scrollView: UIScrollView) {
    container?.coordinators.forEach { coordinator in
      (coordinator as? NavigationBarScrollBeginCoordinating)?.willBeginDragging(scrollView: scrollView)
    }
  }
}

public protocol NavigationBarScrollBeginCoordinating {
  func willBeginDragging(scrollView: UIScrollView)
}
