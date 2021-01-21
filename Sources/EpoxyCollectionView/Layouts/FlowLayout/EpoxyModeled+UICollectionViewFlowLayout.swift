// Created by Tyler Hedrick on 1/20/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - UICollectionViewFlowLayoutItemSizeProvider

public protocol UICollectionViewFlowLayoutItemSizeProvider {
  var flowLayoutItemSize: CGSize? { get }
}

extension EpoxyModeled where Self: UICollectionViewFlowLayoutItemSizeProvider {
  public var flowLayoutItemSize: CGSize? {
    get { self[flowLayoutItemSizeProperty] }
    set { self[flowLayoutItemSizeProperty] = newValue }
  }

  private var flowLayoutItemSizeProperty: EpoxyModelProperty<CGSize?> {
    .init(
      keyPath: \UICollectionViewFlowLayoutItemSizeProvider.flowLayoutItemSize,
      defaultValue: nil,
      updateStrategy: .replace)
  }

  public func flowLayoutItemSize(_ itemSize: CGSize?) -> Self {
    copy(updating: flowLayoutItemSizeProperty, to: itemSize)
  }
}

extension ItemModel: UICollectionViewFlowLayoutItemSizeProvider {}
extension AnyItemModel: UICollectionViewFlowLayoutItemSizeProvider {}
extension SectionModel: UICollectionViewFlowLayoutItemSizeProvider {}

// MARK: - UICollectionViewFlowLayoutSectionInsetProvider

public protocol UICollectionViewFlowLayoutSectionInsetProvider {
  var flowLayoutSectionInset: UIEdgeInsets? { get }
}

extension EpoxyModeled where Self: UICollectionViewFlowLayoutSectionInsetProvider {
  public var flowLayoutSectionInset: UIEdgeInsets? {
    get { self[flowLayoutSectionInsetProperty] }
    set { self[flowLayoutSectionInsetProperty] = newValue }
  }

  private var flowLayoutSectionInsetProperty: EpoxyModelProperty<UIEdgeInsets?> {
    .init(
      keyPath: \UICollectionViewFlowLayoutSectionInsetProvider.flowLayoutSectionInset,
      defaultValue: nil,
      updateStrategy: .replace)
  }

  public func flowLayoutSectionInset(_ sectionInset: UIEdgeInsets?) -> Self {
    copy(updating: flowLayoutSectionInsetProperty, to: sectionInset)
  }
}

extension SectionModel: UICollectionViewFlowLayoutSectionInsetProvider {}

// MARK: - UICollectionViewFlowLayoutMinimumLineSpacingProvider

public protocol UICollectionViewFlowLayoutMinimumLineSpacingProvider {
  var flowLayoutMinimumLineSpacing: CGFloat? { get }
}

extension EpoxyModeled where Self: UICollectionViewFlowLayoutMinimumLineSpacingProvider {
  public var flowLayoutMinimumLineSpacing: CGFloat? {
    get { self[flowLayoutMinimumLineSpacingProperty] }
    set { self[flowLayoutMinimumLineSpacingProperty] = newValue }
  }

  private var flowLayoutMinimumLineSpacingProperty: EpoxyModelProperty<CGFloat?> {
    .init(
      keyPath: \UICollectionViewFlowLayoutMinimumLineSpacingProvider.flowLayoutMinimumLineSpacing,
      defaultValue: nil,
      updateStrategy: .replace)
  }

  public func flowLayoutMinimumLineSpacing(_ lineSpacing: CGFloat?) -> Self {
    copy(updating: flowLayoutMinimumLineSpacingProperty, to: lineSpacing)
  }
}

extension SectionModel: UICollectionViewFlowLayoutMinimumLineSpacingProvider {}

// MARK: - UICollectionViewFlowLayoutMinimumInteritemSpacing

public protocol UICollectionViewFlowLayoutMinimumInteritemSpacing {
  var flowLayoutMinimumInteritemSpacing: CGFloat? { get }
}

extension EpoxyModeled where Self: UICollectionViewFlowLayoutMinimumInteritemSpacing {
  public var flowLayoutMinimumInteritemSpacing: CGFloat? {
    get { self[flowLayoutMinimumInteritemSpacingProperty] }
    set { self[flowLayoutMinimumInteritemSpacingProperty] = newValue }
  }

  private var flowLayoutMinimumInteritemSpacingProperty: EpoxyModelProperty<CGFloat?> {
    .init(
      keyPath: \UICollectionViewFlowLayoutMinimumInteritemSpacing.flowLayoutMinimumInteritemSpacing,
      defaultValue: nil,
      updateStrategy: .replace)
  }

  public func flowLayoutMinimumInteritemSpacing(_ interitemSpacing: CGFloat?) -> Self {
    copy(updating: flowLayoutMinimumInteritemSpacingProperty, to: interitemSpacing)
  }
}

extension SectionModel: UICollectionViewFlowLayoutMinimumInteritemSpacing {}

// MARK: - UICollectionViewFlowLayoutHeaderReferenceSizeProvider

public protocol UICollectionViewFlowLayoutHeaderReferenceSizeProvider {
  var flowLayoutHeaderReferenceSize: CGSize? { get }
}

extension EpoxyModeled where Self: UICollectionViewFlowLayoutHeaderReferenceSizeProvider {
  public var flowLayoutHeaderReferenceSize: CGSize? {
    get { self[flowLayoutHeaderReferenceSizeProperty] }
    set { self[flowLayoutHeaderReferenceSizeProperty] = newValue }
  }

  private var flowLayoutHeaderReferenceSizeProperty: EpoxyModelProperty<CGSize?> {
    .init(
      keyPath: \UICollectionViewFlowLayoutHeaderReferenceSizeProvider.flowLayoutHeaderReferenceSize,
      defaultValue: nil,
      updateStrategy: .replace)
  }

  public func flowLayoutHeaderReferenceSize(_ size: CGSize?) -> Self {
    copy(updating: flowLayoutHeaderReferenceSizeProperty, to: size)
  }
}

extension SectionModel: UICollectionViewFlowLayoutHeaderReferenceSizeProvider {}

// MARK: - UICollectionViewFlowLayoutFooterReferenceSizeProvider

public protocol UICollectionViewFlowLayoutFooterReferenceSizeProvider {
  var flowLayoutFooterReferenceSize: CGSize? { get }
}

extension EpoxyModeled where Self: UICollectionViewFlowLayoutFooterReferenceSizeProvider {
  public var flowLayoutFooterReferenceSize: CGSize? {
    get { self[flowLayoutFooterReferenceSizeProperty] }
    set { self[flowLayoutFooterReferenceSizeProperty] = newValue }
  }

  private var flowLayoutFooterReferenceSizeProperty: EpoxyModelProperty<CGSize?> {
    .init(
      keyPath: \UICollectionViewFlowLayoutFooterReferenceSizeProvider.flowLayoutFooterReferenceSize,
      defaultValue: nil,
      updateStrategy: .replace)
  }

  public func flowLayoutFooterReferenceSize(_ size: CGSize?) -> Self {
    copy(updating: flowLayoutFooterReferenceSizeProperty, to: size)
  }
}

extension SectionModel: UICollectionViewFlowLayoutFooterReferenceSizeProvider {}
