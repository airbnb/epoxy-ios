// Created by eric_horacek on 12/2/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - IsMovableProviding

/// The capability of an item being movable within a `CollectionView` using the legacy drag/drop
/// system.
///
/// - Note: Corresponds to the legacy `UICollectionViewDataSource.collectionView(_:canMoveItemAt:)`
/// drag/drop system, not the modern `UICollectionViewDragDelegate`/`UICollectionViewDropDelegate`
/// system.
///
/// - SeeAlso: `CollectionViewReorderingDelegate`
public protocol IsMovableProviding {
  /// A legacy property to allow interactive reordering of items within a collection view,
  /// defaults to `false`, but you can configure it to be `true` to enable reordering.
  var isMovable: Bool { get }
}

// MARK: - EpoxyModeled

extension EpoxyModeled where Self: IsMovableProviding {

  // MARK: Public

  public var isMovable: Bool {
    get { self[isMovableProperty] }
    set { self[isMovableProperty] = newValue }
  }

  /// Returns a copy of this model with the current `isMovable` value replaced with the provided
  /// `value`.
  public func isMovable(_ value: Bool) -> Self {
    copy(updating: isMovableProperty, to: value)
  }

  // MARK: Private

  private var isMovableProperty: EpoxyModelProperty<Bool> {
    .init(keyPath: \IsMovableProviding.isMovable, defaultValue: false, updateStrategy: .replace)
  }
}
