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

  /// Constructs an item model with a data ID, content, and a closure to configure the item view
  /// with new content whenever it changes.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this item relative to other items in the
  ///     same collection.
  ///   - content: The content of the item view that will be applied to the view in the
  ///     `configureView` closure whenver it has changed.
  ///   - configureView: A closure that's called to configure the view with its content, both
  ///     immediately following its construction in `makeView` and subsequently whenever a new item
  ///     model that replaced an old item model with the same `dataID` has content that is not equal
  ///     to the content of the old item model.
  public init(
    dataID: AnyHashable,
    content: Content,
    configureView: ((CallbackContext) -> Void)? = nil)
  {
    self.dataID = dataID
    self.content = content
    self.configureView = configureView
  }

  /// Constructs an item model with a data ID, initializer parameters, content, a closure to
  /// construct the view from the parameters, and a closure to configure the item view with new
  /// content whenever it changes.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this item relative to other items in the
  ///     same collection.
  ///   - params: The parameters used to construct an instance of the view, passed into the
  ///     `makeView` function and used as a view reuse identifier.
  ///   - content: The content of the item view that will be applied to the view in the
  ///     `configureView` closure whenver it has changed.
  ///   - makeView: A closure that's called with `params` to construct view instances as required.
  ///   - configureView: A closure that's called to configure the view with its content, both
  ///     immediately following its construction in `makeView` and subsequently whenever a new item
  ///     model that replaced an old item model with the same `dataID` has content that is not equal
  ///     to the content of the old item model.
  public init<Params: Hashable>(
    dataID: AnyHashable,
    params: Params,
    content: Content,
    makeView: @escaping (Params) -> View,
    configureView: @escaping ConfigureView)
  {
    self.dataID = dataID
    self.styleID = params
    self.content = content
    self.makeView = { makeView(params) }
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

extension SupplementaryItemModel: ConfigureViewProviding {}
extension SupplementaryItemModel: ContentProviding {}
extension SupplementaryItemModel: DataIDProviding {}
extension SupplementaryItemModel: DidEndDisplayingProviding {}
extension SupplementaryItemModel: MakeViewProviding {}
extension SupplementaryItemModel: SetBehaviorsProviding {}
extension SupplementaryItemModel: StyleIDProviding {}
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
    .init(viewType: View.self, styleID: styleID)
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
    DiffIdentifier(dataID: dataID, viewClass: .init(View.self), styleID: styleID)
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
  var styleID: AnyHashable?
}
