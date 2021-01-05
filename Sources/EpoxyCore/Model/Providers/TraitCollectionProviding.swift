// Created by eric_horacek on 12/16/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

/// The capability of providing a `UITraitCollection` instance.
public protocol TraitCollectionProviding {
  /// The `UITraitCollection` instance provided by this type.
  var traitCollection: UITraitCollection { get }
}
