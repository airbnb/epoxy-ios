//  Created by Laura Skelton on 3/14/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - EpoxyModel

/// A flexible `EpoxyModel` type for configuring views of a specific type with content of a specific
/// type, using closures for creation, configuration, and behavior setting.
///
/// This is designed to be used with a `CollectionView` to lazily create and configure views as they
/// are recycled in a `UICollectionView`.
public struct EpoxyModel<View: UIView, Content: Equatable>: ContentViewEpoxyModeled {

  // MARK: Lifecycle

  /// Constructs a item model with a data ID, content, and a closure to configure the item view with
  /// new content whenever it changes.
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
    configureView: ((EpoxyContext<View, Content>) -> Void)? = nil)
  {
    self.dataID = dataID
    self.content = content
    self.configureView = configureView
  }

  // MARK: Public

  public var storage = EpoxyModelStorage()

}

extension EpoxyModel: DataIDProviding {}
extension EpoxyModel: AlternateStyleIDProviding {}
extension EpoxyModel: DidChangeStateProviding {}
extension EpoxyModel: MakeViewProviding {}
extension EpoxyModel: ConfigureViewProviding {}
extension EpoxyModel: SetBehaviorsProviding {}
extension EpoxyModel: DidSelectProviding {}
extension EpoxyModel: SelectionStyleProviding {}
extension EpoxyModel: ContentProviding {}
extension EpoxyModel: DidEndDisplayingProviding {}
extension EpoxyModel: WillDisplayProviding {}
extension EpoxyModel: IsMovableProviding {}

// MARK: EpoxyableModel

extension EpoxyModel: EpoxyableModel {
  public func eraseToAnyEpoxyModel() -> AnyEpoxyModel {
    .init(internalEpoxyModel: self)
  }
}

// MARK: InternalEpoxyableModel

extension EpoxyModel: InternalEpoxyableModel {
  public var reuseID: String {
    let viewType = "\(type(of: View.self))"
    guard let alternateStyleID = alternateStyleID else { return viewType }
    return viewType + "_" + alternateStyleID
  }

  public var isSelectable: Bool {
    didSelect != nil
  }

  public func handleWillDisplay() {
    willDisplay?()
  }

  public func handleDidEndDisplaying() {
    didEndDisplaying?()
  }

  public func configure(cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) {
    let view = cell.view as? View ?? makeView()
    cell.setViewIfNeeded(view: view)
    configureView?(.init(view: view, content: content, dataID: dataID, metadata: metadata))
  }

  public func configureStateChange(in cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) {
    let view = cell.view as? View ?? makeView()
    cell.setViewIfNeeded(view: view)
    didChangeState?(.init(view: view, content: content, dataID: dataID, metadata: metadata))
  }

  public func setBehavior(cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) {
    let view = cell.view as? View ?? makeView()
    cell.setViewIfNeeded(view: view)
    setBehaviors?(.init(view: view, content: content, dataID: dataID, metadata: metadata))
  }

  public func handleDidSelect(_ cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) {
    guard let view = cell.view as? View else {
      assertionFailure("The selected view is not the expected type.")
      return
    }
    didSelect?(.init(view: view, content: content, dataID: dataID, metadata: metadata))
  }

  public func configuredView(traitCollection: UITraitCollection) -> UIView {
    let view = makeView()
    let context = EpoxyContext(
      view: view,
      content: content,
      dataID: dataID,
      traitCollection: traitCollection,
      cellState: .normal,
      animated: false)
    configureView?(context)
    setBehaviors?(context)
    return view
  }
}

// MARK: Diffable

extension EpoxyModel: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let other = otherDiffableItem as? EpoxyModel<View, Content> else {
      return false
    }
    return content == other.content
  }
}
