// Created by Benjamin Scazzero on 7/17/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - SafeAreaLayoutMarginsBarView

/// Describes how the view's original layout margins and safe area should interact.
public protocol SafeAreaLayoutMarginsBarView: UIView {
  var preferredSafeAreaLayoutMarginsBehavior: SafeAreaLayoutMarginsBehavior { get }
}

// MARK: - SafeAreaLayoutMarginsBehavior

public enum SafeAreaLayoutMarginsBehavior {
  /// The bar's layout margins are set to the max of the safe area and its original layout margins.
  case max
  /// The bar's layout margins are set to the sum of the safe area and its original layout margins.
  case sum
}
