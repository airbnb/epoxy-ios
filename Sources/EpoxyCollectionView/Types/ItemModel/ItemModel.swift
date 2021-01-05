//  Created by Laura Skelton on 3/14/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - ItemModel

/// A flexible model type for configuring views of a specific type with content of a specific type,
/// using closures for creation, configuration, and behavior setting.
///
/// Designed to be used with a `CollectionView` to lazily create and configure views as they are
/// recycled in a `UICollectionView`.
public struct ItemModel<View: UIView, Content: Equatable>: ContentViewEpoxyModeled {

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
    configureView: ((CallbackContext) -> Void)? = nil)
  {
    self.dataID = dataID
    self.content = content
    self.configureView = configureView
  }

  // MARK: Public

  public var storage = EpoxyModelStorage()

  // MARK: Private

  private func viewForCell(_ cell: ItemWrapperView) -> View {
    guard let cellView = cell.view else {
      let view = makeView()
      cell.setViewIfNeeded(view: view)
      return view
    }

    let view: View
    if let cellView = cellView as? View {
      view = cellView
    } else {
      EpoxyLogger.shared.assertionFailure(
        """
        Overriding existing view \(cellView) on cell \(cell), which is not of expected type \
        \(View.self). This is programmer error.
        """)
      view = makeView()
    }
    cell.setViewIfNeeded(view: view)
    return view
  }

}

// MARK: Providers

extension ItemModel: AlternateStyleIDProviding {}
extension ItemModel: ConfigureViewProviding {}
extension ItemModel: ContentProviding {}
extension ItemModel: DataIDProviding {}
extension ItemModel: DidChangeStateProviding {}
extension ItemModel: DidEndDisplayingProviding {}
extension ItemModel: DidSelectProviding {}
extension ItemModel: IsMovableProviding {}
extension ItemModel: MakeViewProviding {}
extension ItemModel: SelectionStyleProviding {}
extension ItemModel: SetBehaviorsProviding {}
extension ItemModel: WillDisplayProviding {}

// MARK: ItemModeling

extension ItemModel: ItemModeling {
  public func eraseToAnyItemModel() -> AnyItemModel {
    .init(internalItemModel: self)
  }
}

// MARK: InternalItemModeling

extension ItemModel: InternalItemModeling {
  public var reuseID: String {
    let viewType = "\(type(of: View.self))"
    guard let alternateStyleID = alternateStyleID else { return viewType }
    return viewType + "_" + alternateStyleID
  }

  public var isSelectable: Bool {
    didSelect != nil
  }

  public func handleWillDisplay(_ cell: ItemWrapperView, with metadata: EpoxyViewMetadata) {
    willDisplay?(.init(view: viewForCell(cell), content: content, dataID: dataID, metadata: metadata))
  }

  public func handleDidEndDisplaying(_ cell: ItemWrapperView, with metadata: EpoxyViewMetadata) {
    didEndDisplaying?(.init(view: viewForCell(cell), content: content, dataID: dataID, metadata: metadata))
  }

  public func configure(cell: ItemWrapperView, with metadata: EpoxyViewMetadata) {
    // Even if there's no `configureView` closure, we need to make sure to call `viewForCell` to
    // ensure that the cell is set up.
    let view = viewForCell(cell)
    configureView?(.init(view: view, content: content, dataID: dataID, metadata: metadata))
  }

  public func configureStateChange(in cell: ItemWrapperView, with metadata: EpoxyViewMetadata) {
    didChangeState?(.init(view: viewForCell(cell), content: content, dataID: dataID, metadata: metadata))
  }

  public func setBehavior(cell: ItemWrapperView, with metadata: EpoxyViewMetadata) {
    setBehaviors?(.init(view: viewForCell(cell), content: content, dataID: dataID, metadata: metadata))
  }

  public func handleDidSelect(_ cell: ItemWrapperView, with metadata: EpoxyViewMetadata) {
    didSelect?(.init(view: viewForCell(cell), content: content, dataID: dataID, metadata: metadata))
  }

  public func configuredView(traitCollection: UITraitCollection) -> UIView {
    let view = makeView()
    let context = CallbackContext(
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

extension ItemModel: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let other = otherDiffableItem as? Self else {
      return false
    }
    return content == other.content
  }
}

// MARK: CallbackContextEpoxyModeled

extension ItemModel: CallbackContextEpoxyModeled {

  /// The context passed to callbacks on an `ItemModel`.
  public struct CallbackContext: ViewProviding, ContentProviding, TraitCollectionProviding, AnimatedProviding {

    // MARK: Lifecycle

    public init(
      view: View,
      content: Content,
      dataID: AnyHashable,
      traitCollection: UITraitCollection,
      cellState: EpoxyCellState,
      animated: Bool)
    {
      self.view = view
      self.content = content
      self.dataID = dataID
      self.traitCollection = traitCollection
      self.cellState = cellState
      self.animated = animated
    }

    public init(
      view: View,
      content: Content,
      dataID: AnyHashable,
      metadata: EpoxyViewMetadata)
    {
      self.init(
        view: view,
        content: content,
        dataID: dataID,
        traitCollection: metadata.traitCollection,
        cellState: metadata.state,
        animated: metadata.animated)
    }

    // MARK: Public

    public var view: View
    public var content: Content
    public var dataID: AnyHashable
    public var traitCollection: UITraitCollection
    public var cellState: EpoxyCellState
    public var animated: Bool
  }

}
