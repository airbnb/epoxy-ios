// Created by tyler_hedrick on 9/26/18.
// Copyright © 2018 Airbnb. All rights reserved.

import UIKit

/// A view with customized accessibility behavior within a `CollectionView`.
///
/// If a view conforms to this protocol, its `UIAccessibility` values (e.g.
/// `accessibilityElementsHidden`) override the `CollectionView` default.
///
/// For now, this just supports ``accessibilityElementsHidden`.
public protocol AccessibilityCustomizedView: UIView {}
