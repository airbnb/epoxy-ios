//  Created by Laura Skelton on 9/8/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - SupplementaryItemModel

/// A flexible model type for configuring supplementary views of a specific type with content of a
/// specific type, using closures for creation, configuration, and behavior setting.
///
/// Designed to be used with a `CollectionView` to lazily create and configure views as they are
/// recycled in a `UICollectionView`.
public struct SupplementaryItemModel<View: UIView, Content: Equatable>: ContentViewEpoxyModeled {

  // MARK: Lifecycle

  public init(
    dataID: AnyHashable,
    content: Content,
    configureView: ((CallbackContext) -> Void)? = nil)
  {
    self.dataID = dataID
    self.content = content
    self.configureView = configureView
  }

  // MARK: Public

  public var storage = EpoxyModelStorage()

  // MARK: Private

  private func viewForReusableView(_ reusableView: CollectionViewReusableView) -> View {
    guard let reusableViewView = reusableView.view else {
      let view = makeView()
      reusableView.setViewIfNeeded(view: view)
      return view
    }

    let view: View
    if let cellView = reusableViewView as? View {
      view = cellView
    } else {
      EpoxyLogger.shared.assertionFailure(
        """
        Overriding existing view \(reusableViewView) on view \(reusableView), which is not of \
        expected type \(View.self). This is programmer error.
        """)
      view = makeView()
    }
    reusableView.setViewIfNeeded(view: view)
    return view
  }

}

// MARK: Providers

extension SupplementaryItemModel: AlternateStyleIDProviding {}
extension SupplementaryItemModel: ConfigureViewProviding {}
extension SupplementaryItemModel: ContentProviding {}
extension SupplementaryItemModel: DataIDProviding {}
extension SupplementaryItemModel: DidEndDisplayingProviding {}
extension SupplementaryItemModel: MakeViewProviding {}
extension SupplementaryItemModel: SetBehaviorsProviding {}
extension SupplementaryItemModel: WillDisplayProviding {}

// MARK: SupplementaryItemModeling

extension SupplementaryItemModel: SupplementaryItemModeling {
  public func eraseToAnySupplementaryItemModel() -> AnySupplementaryItemModel {
    .init(internalItemModel: self)
  }
}

// MARK: InternalSupplementaryItemModeling

extension SupplementaryItemModel: InternalSupplementaryItemModeling {
  public var viewDifferentiator: ViewDifferentiator {
    .init(viewType: View.self, styleID: alternateStyleID)
  }

  public func configure(
    reusableView: CollectionViewReusableView,
    traitCollection: UITraitCollection,
    animated: Bool)
  {
    // Even if there's no `configureView` closure, we need to make sure to call
    // `viewForReusableView` to ensure that the view is created.
    let view = viewForReusableView(reusableView)
    configureView?(.init(view: view, content: content, dataID: dataID, traitCollection: traitCollection, animated: animated))
  }

  public func setBehavior(
    reusableView: CollectionViewReusableView,
    traitCollection: UITraitCollection,
    animated: Bool)
  {
    setBehaviors?(.init(view: viewForReusableView(reusableView), content: content, dataID: dataID, traitCollection: traitCollection, animated: animated))
  }

  func handleWillDisplay(
    _ reusableView: CollectionViewReusableView,
    traitCollection: UITraitCollection,
    animated: Bool)
  {
    willDisplay?(.init(view: viewForReusableView(reusableView), content: content, dataID: dataID, traitCollection: traitCollection, animated: animated))
  }

  func handleDidEndDisplaying(
    _ reusableView: CollectionViewReusableView,
    traitCollection: UITraitCollection,
    animated: Bool)
  {
    didEndDisplaying?(.init(view: viewForReusableView(reusableView), content: content, dataID: dataID, traitCollection: traitCollection, animated: animated))
  }
}

// MARK: Diffable

extension SupplementaryItemModel: Diffable {
  public var diffIdentifier: AnyHashable {
    DiffIdentifier(dataID: dataID, viewClass: .init(View.self), alternateStyleID: alternateStyleID)
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let other = otherDiffableItem as? Self else {
      return false
    }
    return content == other.content
  }
}

// MARK: CallbackContextEpoxyModeled

extension SupplementaryItemModel: CallbackContextEpoxyModeled {

  /// The context passed to callbacks on an `SupplementaryItemModel`.
  public struct CallbackContext: ViewProviding, ContentProviding, TraitCollectionProviding, AnimatedProviding {

    // MARK: Lifecycle

    public init(
      view: View,
      content: Content,
      dataID: AnyHashable,
      traitCollection: UITraitCollection,
      animated: Bool)
    {
      self.view = view
      self.content = content
      self.dataID = dataID
      self.traitCollection = traitCollection
      self.animated = animated
    }

    // MARK: Public

    public var view: View
    public var content: Content
    public var dataID: AnyHashable
    public var traitCollection: UITraitCollection
    public var animated: Bool
  }

}

// MARK: - DiffIdentifier

/// The identity of an item: a item view instance can be shared between two item model instances if
/// their `DiffIdentifier`s are equal. If they are not equal, the old item view will be considered
/// removed and a new item view will be created and inserted in its place.
private struct DiffIdentifier: Hashable {
  var dataID: AnyHashable
  // The `View.Type` wrapped in `ObjectIdentifier` since `AnyClass` is not `Hashable`.
  var viewClass: ObjectIdentifier
  var alternateStyleID: AnyHashable?
}
