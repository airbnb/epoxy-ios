// Created by Cal Stephens on 8/23/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import UIKit

// A `UIWindow` subclass that can provide safe area insets
// to simulate default device safe area insets (e.g. from the status bar)
final class SafeAreaWindow: UIWindow {

  // MARK: Lifecycle

  init(
    frame: CGRect,
    safeAreaInsets: UIEdgeInsets)
  {
    customSafeAreaInsets = safeAreaInsets
    super.init(frame: frame)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override var safeAreaInsets: UIEdgeInsets {
    customSafeAreaInsets
  }

  // MARK: Private

  private let customSafeAreaInsets: UIEdgeInsets

}
