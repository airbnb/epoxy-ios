// Created by Tyler Hedrick on 1/20/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - UICollectionViewFlowLayoutItemSizeProvider

public protocol UICollectionViewFlowLayoutItemSizeProvider {
  var flowLayoutItemSize: CGSize? { get }
}

extension EpoxyModeled where Self: UICollectionViewFlowLayoutItemSizeProvider {

  // MARK: Public

  public var flowLayoutItemSize: CGSize? {
    get { self[flowLayoutItemSizeProperty] }
    set { self[flowLayoutItemSizeProperty] = newValue }
  }

  public func flowLayoutItemSize(_ itemSize: CGSize?) -> Self {
    copy(updating: flowLayoutItemSizeProperty, to: itemSize)
  }

  // MARK: Private

  private var flowLayoutItemSizeProperty: EpoxyModelProperty<CGSize?> {
    .init(
      keyPath: \UICollectionViewFlowLayoutItemSizeProvider.flowLayoutItemSize,
      defaultValue: nil,
      updateStrategy: .replace)
  }

}

// MARK: - ItemModel + UICollectionViewFlowLayoutItemSizeProvider

extension ItemModel: UICollectionViewFlowLayoutItemSizeProvider { }

// MARK: - AnyItemModel + UICollectionViewFlowLayoutItemSizeProvider

extension AnyItemModel: UICollectionViewFlowLayoutItemSizeProvider { }

// MARK: - SectionModel + UICollectionViewFlowLayoutItemSizeProvider

extension SectionModel: UICollectionViewFlowLayoutItemSizeProvider { }

// MARK: - UICollectionViewFlowLayoutSectionInsetProvider

public protocol UICollectionViewFlowLayoutSectionInsetProvider {
  var flowLayoutSectionInset: UIEdgeInsets? { get }
}

extension EpoxyModeled where Self: UICollectionViewFlowLayoutSectionInsetProvider {

  // MARK: Public

  public var flowLayoutSectionInset: UIEdgeInsets? {
    get { self[flowLayoutSectionInsetProperty] }
    set { self[flowLayoutSectionInsetProperty] = newValue }
  }

  public func flowLayoutSectionInset(_ sectionInset: UIEdgeInsets?) -> Self {
    copy(updating: flowLayoutSectionInsetProperty, to: sectionInset)
  }

  // MARK: Private

  private var flowLayoutSectionInsetProperty: EpoxyModelProperty<UIEdgeInsets?> {
    .init(
      keyPath: \UICollectionViewFlowLayoutSectionInsetProvider.flowLayoutSectionInset,
      defaultValue: nil,
      updateStrategy: .replace)
  }

}

// MARK: - SectionModel + UICollectionViewFlowLayoutSectionInsetProvider

extension SectionModel: UICollectionViewFlowLayoutSectionInsetProvider { }

// MARK: - UICollectionViewFlowLayoutMinimumLineSpacingProvider

public protocol UICollectionViewFlowLayoutMinimumLineSpacingProvider {
  var flowLayoutMinimumLineSpacing: CGFloat? { get }
}

extension EpoxyModeled where Self: UICollectionViewFlowLayoutMinimumLineSpacingProvider {

  // MARK: Public

  public var flowLayoutMinimumLineSpacing: CGFloat? {
    get { self[flowLayoutMinimumLineSpacingProperty] }
    set { self[flowLayoutMinimumLineSpacingProperty] = newValue }
  }

  public func flowLayoutMinimumLineSpacing(_ lineSpacing: CGFloat?) -> Self {
    copy(updating: flowLayoutMinimumLineSpacingProperty, to: lineSpacing)
  }

  // MARK: Private

  private var flowLayoutMinimumLineSpacingProperty: EpoxyModelProperty<CGFloat?> {
    .init(
      keyPath: \UICollectionViewFlowLayoutMinimumLineSpacingProvider.flowLayoutMinimumLineSpacing,
      defaultValue: nil,
      updateStrategy: .replace)
  }

}

// MARK: - SectionModel + UICollectionViewFlowLayoutMinimumLineSpacingProvider

extension SectionModel: UICollectionViewFlowLayoutMinimumLineSpacingProvider { }

// MARK: - UICollectionViewFlowLayoutMinimumInteritemSpacing

public protocol UICollectionViewFlowLayoutMinimumInteritemSpacing {
  var flowLayoutMinimumInteritemSpacing: CGFloat? { get }
}

extension EpoxyModeled where Self: UICollectionViewFlowLayoutMinimumInteritemSpacing {

  // MARK: Public

  public var flowLayoutMinimumInteritemSpacing: CGFloat? {
    get { self[flowLayoutMinimumInteritemSpacingProperty] }
    set { self[flowLayoutMinimumInteritemSpacingProperty] = newValue }
  }

  public func flowLayoutMinimumInteritemSpacing(_ interitemSpacing: CGFloat?) -> Self {
    copy(updating: flowLayoutMinimumInteritemSpacingProperty, to: interitemSpacing)
  }

  // MARK: Private

  private var flowLayoutMinimumInteritemSpacingProperty: EpoxyModelProperty<CGFloat?> {
    .init(
      keyPath: \UICollectionViewFlowLayoutMinimumInteritemSpacing.flowLayoutMinimumInteritemSpacing,
      defaultValue: nil,
      updateStrategy: .replace)
  }

}

// MARK: - SectionModel + UICollectionViewFlowLayoutMinimumInteritemSpacing

extension SectionModel: UICollectionViewFlowLayoutMinimumInteritemSpacing { }

// MARK: - UICollectionViewFlowLayoutHeaderReferenceSizeProvider

public protocol UICollectionViewFlowLayoutHeaderReferenceSizeProvider {
  var flowLayoutHeaderReferenceSize: CGSize? { get }
}

extension EpoxyModeled where Self: UICollectionViewFlowLayoutHeaderReferenceSizeProvider {

  // MARK: Public

  public var flowLayoutHeaderReferenceSize: CGSize? {
    get { self[flowLayoutHeaderReferenceSizeProperty] }
    set { self[flowLayoutHeaderReferenceSizeProperty] = newValue }
  }

  public func flowLayoutHeaderReferenceSize(_ size: CGSize?) -> Self {
    copy(updating: flowLayoutHeaderReferenceSizeProperty, to: size)
  }

  // MARK: Private

  private var flowLayoutHeaderReferenceSizeProperty: EpoxyModelProperty<CGSize?> {
    .init(
      keyPath: \UICollectionViewFlowLayoutHeaderReferenceSizeProvider.flowLayoutHeaderReferenceSize,
      defaultValue: nil,
      updateStrategy: .replace)
  }

}

// MARK: - SectionModel + UICollectionViewFlowLayoutHeaderReferenceSizeProvider

extension SectionModel: UICollectionViewFlowLayoutHeaderReferenceSizeProvider { }

// MARK: - UICollectionViewFlowLayoutFooterReferenceSizeProvider

public protocol UICollectionViewFlowLayoutFooterReferenceSizeProvider {
  var flowLayoutFooterReferenceSize: CGSize? { get }
}

extension EpoxyModeled where Self: UICollectionViewFlowLayoutFooterReferenceSizeProvider {

  // MARK: Public

  public var flowLayoutFooterReferenceSize: CGSize? {
    get { self[flowLayoutFooterReferenceSizeProperty] }
    set { self[flowLayoutFooterReferenceSizeProperty] = newValue }
  }

  public func flowLayoutFooterReferenceSize(_ size: CGSize?) -> Self {
    copy(updating: flowLayoutFooterReferenceSizeProperty, to: size)
  }

  // MARK: Private

  private var flowLayoutFooterReferenceSizeProperty: EpoxyModelProperty<CGSize?> {
    .init(
      keyPath: \UICollectionViewFlowLayoutFooterReferenceSizeProvider.flowLayoutFooterReferenceSize,
      defaultValue: nil,
      updateStrategy: .replace)
  }

}

// MARK: - SectionModel + UICollectionViewFlowLayoutFooterReferenceSizeProvider

extension SectionModel: UICollectionViewFlowLayoutFooterReferenceSizeProvider { }
