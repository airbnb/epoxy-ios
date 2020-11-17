//  Created by Laura Skelton on 3/14/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - EpoxyModel

/// A flexible `EpoxyModel` class for configuring views of a specific type with data of a specific type, 
/// using blocks for creation, configuration, and behavior setting. This was designed to be used in 
/// a `EpoxyInterface` to lazily create and configure views as they are recycled in a `UITableView` 
/// or `UICollectionView`.
public class EpoxyModel<ViewType, DataType>: TypedEpoxyableModel where
  ViewType: UIView,
  DataType: Equatable
{
  // MARK: Lifecycle
  /**
   Initializes an `EpoxyModel` that creates and configures a specific type of view for display in a `EpoxyInterface`.
   - Parameters:
     - data: The data this view takes for configuration, specific to this particular epoxy item instance.
     - dataID: An optional ID to differentiate this row from other rows, used when diffing.
     - alternateStyleID: An optional ID for an alternative style type to use for reuse of this view. Use this to differentiate between different styling configurations.
     - builder: A closure that builds and returns this view type.
     - configurer: A closure that configures this view type with the specified data type.
     - stateConfigurer: An optional closure that configures this view type for a specific state.
     - behaviorSetter: An optional closure that sets the view's behavior (such as interaction blocks or delegates). This block is called whenever a view is configured with an Epoxy model.
     - selectionHandler: An optional closure that is called whenever the view is tapped.
     - userInfo: An optional dictionary used for holding onto user-specific data
   - Returns: An `EpoxyModel` instance that will create the specified view type with this data.
   */
  public init(
    data: DataType,
    dataID: DataID,
    alternateStyleID: String? = nil,
    makeView: @escaping () -> ViewType = { ViewType() },
    configureView: @escaping (EpoxyContext<ViewType, DataType>) -> Void,
    didChangeState: ((EpoxyContext<ViewType, DataType>) -> Void)? = nil,
    setBehaviors: ((EpoxyContext<ViewType, DataType>) -> Void)? = nil,
    didSelect: ((EpoxyContext<ViewType, DataType>) -> Void)? = nil,
    willDisplay: ((DataType, AnyHashable) -> Void)? = nil,
    didEndDisplaying: ((DataType, AnyHashable) -> Void)? = nil,
    userInfo: [EpoxyUserInfoKey: Any] = [:])
  {
    self.data = data
    self.dataID = dataID
    self.alternateStyleID = alternateStyleID
    self.reuseID = "\(type(of: ViewType.self))_\(self.alternateStyleID ?? "")"
    self.makeViewBlock = makeView
    self.configureView = configureView
    self.didChangeState = didChangeState
    self.setBehaviors = setBehaviors
    self.didSelect = didSelect
    self.willDisplayHandler = willDisplay
    self.didEndDisplayingHandler = didEndDisplaying
    self.userInfo = userInfo
    isSelectable = didSelect != nil
  }

  // MARK: Public

  public let dataID: AnyHashable
  public let reuseID: String
  public let data: DataType
  public let userInfo: [EpoxyUserInfoKey : Any]

  /**
   Whether or not the view this model represents should be selectable.
   Automatically set to true if you provide a `selectionHandler`
   */
  public var isSelectable: Bool

  /**
   The selection style of the cell.
   If nil, defaults to the `selectionStyle` set on the `DeprecatedTableView` or `CollectionView`.
   Default value is `nil`
   */
  public var selectionStyle: CellSelectionStyle?

  /**
   This is a experimental property to allow interactive reordering of items within collection view,
   it defaults to false, but you can configure it to be true to enable reordering
   */
  public var isMovable: Bool = false

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    if let other = otherDiffableItem as? EpoxyModel<ViewType, DataType> {
      return self.data == other.data
    } else {
      return false
    }
  }

  public func makeView() -> ViewType {
    return makeViewBlock()
  }

  public func configureView(_ view: ViewType, with metadata: EpoxyViewMetadata) {
    configureView(context(for: view, with: metadata))
  }

  public func configureViewForStateChange(_ view: ViewType, with metadata: EpoxyViewMetadata) {
    didChangeState?(context(for: view, with: metadata))
  }

  public func setViewBehavior(_ view: ViewType, with metadata: EpoxyViewMetadata) {
    setBehaviors?(context(for: view, with: metadata))
  }

  public func didSelectView(_ view: ViewType, with metadata: EpoxyViewMetadata) {
    didSelect?(context(for: view, with: metadata))
  }

  public func willDisplay() {
    willDisplayHandler?(data, dataID)
  }

  public func didEndDisplaying() {
    didEndDisplayingHandler?(data, dataID)
  }

  // MARK: Private
  private let alternateStyleID: String?
  private let makeViewBlock: () -> ViewType
  private let configureView: (EpoxyContext<ViewType, DataType>) -> Void
  private let didChangeState: ((EpoxyContext<ViewType, DataType>) -> Void)?
  private let setBehaviors: ((EpoxyContext<ViewType, DataType>) -> Void)?
  private let didSelect: ((EpoxyContext<ViewType, DataType>) -> Void)?
  private let willDisplayHandler: ((DataType, AnyHashable) -> Void)?
  private let didEndDisplayingHandler: ((DataType, AnyHashable) -> Void)?

  private func context(for view: ViewType, with metadata: EpoxyViewMetadata) -> EpoxyContext<ViewType, DataType> {
    return EpoxyContext<ViewType, DataType>(
      view: view,
      data: data,
      dataID: dataID,
      traitCollection: metadata.traitCollection,
      cellState: metadata.state,
      animated: metadata.animated)
  }
}

// Builder extensions
public extension EpoxyModel {

  /// Create a builder from an EpoxyModel
  ///
  /// - Returns: a builder object set up with all the data from the original EpoxyModel
  func toBuilder() -> BaseEpoxyModelBuilder<ViewType, DataType> {
    return BaseEpoxyModelBuilder<ViewType, DataType>(
      data: data,
      dataID: dataID)
      .alternateStyleID(alternateStyleID)
      .makeView(makeViewBlock)
      .configureView(configureView)
      .setBehaviors(setBehaviors)
      .didSelect(didSelect)
      .didChangeState(didChangeState)
      .willDisplay(willDisplayHandler)
      .didEndDisplaying(didEndDisplayingHandler)
      .userInfo(userInfo)
  }
}
