// Created by nick_miller on 8/15/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - CollectionViewVisibilityMetadata

/// Metadata about the sections and items that are visible in a `CollectionView`.
public struct CollectionViewVisibilityMetadata {

  public init(sections: [Section], collectionView: CollectionView) {
    self.sections = sections
    self.collectionView = collectionView
  }

  /// The visible sections, ordered by their index.
  public let sections: [Section]

  /// The collection view that the sections are contained within.
  public private(set) weak var collectionView: CollectionView?
}

// MARK: - CollectionViewVisibleMetadata.Section

extension CollectionViewVisibilityMetadata {
  /// Metadata about the items that are visible in a `CollectionView` section.
  public struct Section {

    public init(
      model: SectionModel,
      items: [Item],
      supplementaryItems: [String: [SupplementaryItem]])
    {
      self.model = model
      self.items = items
      self.supplementaryItems = supplementaryItems
    }

    /// The corresponding model for this visible section.
    public let model: SectionModel

    /// The visible items in this section, ordered by their index.
    public let items: [Item]

    /// The visible supplementary items in this section, keyed by their element kind and ordered by
    /// their index.
    public let supplementaryItems: [String: [SupplementaryItem]]
  }
}

// MARK: - CollectionViewVisibleMetadata.Item

extension CollectionViewVisibilityMetadata {
  /// Metadata about an item that's visible in a `CollectionView` section.
  public struct Item {

    public init(model: AnyItemModel, view: UIView?) {
      self.model = model
      self.view = view
    }

    /// The corresponding model for this visible item.
    public let model: AnyItemModel

    /// The corresponding view for this item.
    public private(set) weak var view: UIView?
  }
}

// MARK: - CollectionViewVisibleMetadata.SupplementaryItem

extension CollectionViewVisibilityMetadata {
  /// Metadata about a supplementary item that's visible in a `CollectionView` section.
  public struct SupplementaryItem {

    public init(model: AnySupplementaryItemModel, view: UIView?) {
      self.model = model
      self.view = view
    }

    /// The corresponding model for this visible item.
    public let model: AnySupplementaryItemModel

    /// The corresponding view for this item.
    public private(set) weak var view: UIView?
  }
}
