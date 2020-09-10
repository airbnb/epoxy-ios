// Created by noah_martin on 5/20/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

extension BarInstaller {
  public func willEndDragging(scrollView: UIScrollView, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    container?.coordinators.forEach { coordinator in
      (coordinator as? NavigationBarScrollEndCoordinating)?.willEndDragging(scrollView: scrollView, targetContentOffset: targetContentOffset)
    }
  }
}

public protocol NavigationBarScrollEndCoordinating {
  func willEndDragging(scrollView: UIScrollView, targetContentOffset: UnsafeMutablePointer<CGPoint>)
}
