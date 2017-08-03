//  Created by Laura Skelton on 11/28/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import DLSPrimitives
import UIKit

public enum TableViewCellSelectionStyle {
  case none
  case color(UIColor)
}

/// A TableView class that handles updates through its `setSections` method, and optionally animates diffs.
public class TableView: UITableView, EpoxyView, InternalEpoxyInterface {

  public typealias DataType = InternalTableViewEpoxyData
  public typealias Cell = TableViewCell

  // MARK: Lifecycle

  /// Initializes the TableView
  public init() {
    self.epoxyDataSource = TableViewEpoxyDataSource()
    super.init(frame: .zero, style: .plain)
    setUp()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public func setSections(_ sections: [EpoxySection]?, animated: Bool) {
    epoxyDataSource.setSections(sections, animated: animated)
  }

  public func scrollToItem(at dataID: String) {
    if let indexPath = epoxyDataSource.internalData?.indexPathForItem(at: dataID) {
      scrollToRow(at: indexPath, at: .middle, animated: false)
    }
  }

  public func updateItem(
    at dataID: String,
    with item: EpoxyableModel,
    animated: Bool)
  {
    epoxyDataSource.updateItem(at: dataID, with: item, animated: animated)
  }

  /// Delegate for handling `UIScrollViewDelegate` callbacks related to scrolling.
  /// Ignores zooming delegate methods.
  public weak var scrollDelegate: UIScrollViewDelegate?

  /// Delegate which indicates when an epoxy item will be displayed, typically used
  /// for logging.
  public weak var epoxyModelDisplayDelegate: TableViewEpoxyModelDisplayDelegate?

  /// Selection color for the `UITableViewCell`s of `EpoxyModel`s that have `isSelectable == true`
  public var selectionStyle = TableViewCellSelectionStyle.color(Colors.backgroundHighlightedOrSelected)

  /// Whether or not the final item in the list shows a bottom divider. Defaults to false.
  public var showsLastDivider: Bool = false

  /// Hides the bottom divider for the given dataIDs
  public func hideBottomDivider(for dataIDs: [String]) {
    dataIDsForHidingDividers = dataIDs

    guard isTableViewLaidOut() else {
      // We only want to update the dividers if the table view has completed it's original
      // layout and loading, otherwise we can get unsatisfiable constraint errors in cells.
      return
    }

    indexPathsForVisibleRows?.forEach { indexPath in
      guard let cell = cellForRow(at: indexPath) else {
        return
      }
      guard let epoxyCell = cell as? TableViewCell else {
        assertionFailure("Only TableViewCell and subclasses are allowed in a TableView.")
        return
      }

      if let item = epoxyDataSource.epoxyModel(at: indexPath) {
        self.updateDivider(for: epoxyCell, dividerType: item.dividerType, dataID: item.epoxyModel.dataID)
      }
    }
  }

  /// Block that should return an initialized view of the type you'd like to use for this divider.
  public var rowDividerBuilder: (() -> UIView)?

  /// Block that configures the divider.
  public var rowDividerConfigurer: ((UIView) -> Void)?

  /// Block that should return an initialized view of the type you'd like to use for this divider.
  public var sectionHeaderDividerBuilder: (() -> UIView)?

  /// Block that configures this divider.
  public var sectionHeaderDividerConfigurer: ((UIView) -> Void)?

  public var visibleIndexPaths: [IndexPath] {
    return indexPathsForVisibleRows ?? []
  }

  public func register(reuseID: String) {
    super.register(
      TableViewCell.self,
      forCellReuseIdentifier: reuseID)
  }

  public func configure(cell: Cell, with item: DataType.Item) {
    configure(cell: cell, with: item, animated: false)

    switch selectionStyle {
    case .none:
      cell.selectionStyle = .none
    case .color(let selectionColor):
      cell.selectedBackgroundView?.backgroundColor = selectionColor
    }
    
    updateHorizontalMarginsIfNeeded(for: cell)
  }

  public func reloadItem(at indexPath: IndexPath, animated: Bool) {
    if let cell = cellForRow(at: indexPath as IndexPath) as? TableViewCell,
      let item = epoxyDataSource.epoxyModel(at: indexPath) {
      configure(cell: cell, with: item, animated: animated)
    }
  }

  public func apply(
    _ newData: DataType?,
    animated: Bool,
    changesetMaker: @escaping (DataType?) -> DataType.Changeset?)
  {
    guard animated,
      newData != nil,
      let sectionCount = dataSource?.numberOfSections?(in: self),
      sectionCount > 0
      else {
        _ = changesetMaker(newData)
        reloadData()
        return
    }

    beginUpdates()

    if let changeset = changesetMaker(newData) {
      changeset.itemChangeset.updates.forEach { fromIndexPath, toIndexPath in
        if let cell = cellForRow(at: fromIndexPath as IndexPath) as? TableViewCell,
          let epoxyModel = epoxyDataSource.epoxyModel(at: toIndexPath)?.epoxyModel {
          epoxyModel.configure(cell: cell, animated: true)
          epoxyModel.configure(cell: cell, forState: cell.state)
        }
      }

      // TODO(ls): Make animations configurable
      deleteRows(at: changeset.itemChangeset.deletes as [IndexPath], with: .fade)
      deleteSections(changeset.sectionChangeset.deletes as IndexSet, with: .fade)

      insertRows(at: changeset.itemChangeset.inserts, with: .fade)
      insertSections(changeset.sectionChangeset.inserts as IndexSet, with: .fade)

      changeset.sectionChangeset.moves.forEach { (fromIndex, toIndex) in
        moveSection(fromIndex, toSection: toIndex)
      }

      changeset.itemChangeset.moves.forEach { (fromIndexPath, toIndexPath) in
        moveRow(at: fromIndexPath, to: toIndexPath)
      }
    }

    endUpdates()

    indexPathsForVisibleRows?.forEach { indexPath in
      guard let cell = cellForRow(at: indexPath) else {
        return
      }
      guard let epoxyCell = cell as? TableViewCell else {
        assertionFailure("Only TableViewCell and subclasses are allowed in a TableView.")
        return
      }

      if let item = epoxyDataSource.epoxyModel(at: indexPath) {
        item.epoxyModel.setBehavior(cell: epoxyCell)
        self.updateDivider(for: epoxyCell, dividerType: item.dividerType, dataID: item.epoxyModel.dataID)
      }
    }
  }

  public func addInfiniteScrolling<LoaderView>(
    delegate: InfiniteScrollingDelegate,
    loaderView: LoaderView)
    where LoaderView: UIView, LoaderView: Animatable
  {
    let height = loaderView.compressedHeight(forWidth: bounds.width)
    loaderView.translatesAutoresizingMaskIntoConstraints = true
    loaderView.frame.size.height = height
    tableFooterView = loaderView

    loaderView.stopAnimating()
    infiniteScrollingLoader = loaderView
    infiniteScrollingDelegate = delegate
  }

  public override func layoutMarginsDidChange() {
    super.layoutMarginsDidChange()

    guard isTableViewLaidOut() else {
      // Accessing a table view's visibleCells before the table view has a valid
      // size can cause unsatisfiable constraint errors in cells
      return
    }

    visibleCells.forEach { [weak self] cell in
      self?.updateHorizontalMarginsIfNeeded(for: cell)
    }
  }

  // MARK: Fileprivate

  fileprivate let epoxyDataSource: TableViewEpoxyDataSource

  fileprivate weak var infiniteScrollingDelegate: InfiniteScrollingDelegate?
  fileprivate var infiniteScrollingState: InfiniteScrollingState = .stopped
  fileprivate var infiniteScrollingLoader: Animatable?
  
  fileprivate func updatedInfiniteScrollingState(in scrollView: UIScrollView) -> (InfiniteScrollingState, Bool) {
    let previousState = infiniteScrollingState
    let newState = previousState.next(in: scrollView)
    return (newState, previousState == .triggered && newState == .loading)
  }

  // MARK: Private

  private var dataIDsForHidingDividers = [String]()

  private func setUp() {
    delegate = self
    epoxyDataSource.epoxyInterface = self
    dataSource = epoxyDataSource
    rowHeight = UITableViewAutomaticDimension
    estimatedRowHeight = 44 // TODO(ls): Use better estimated height
    separatorStyle = .none
    backgroundColor = .clear
    translatesAutoresizingMaskIntoConstraints = false
    cellLayoutMarginsFollowReadableWidth = false
  }

  private func configure(cell: Cell, with item: DataType.Item, animated: Bool) {
    item.epoxyModel.configure(cell: cell, animated: animated)
    item.epoxyModel.setBehavior(cell: cell)
    updateDivider(for: cell, dividerType: item.dividerType, dataID: item.epoxyModel.dataID)
  }

  private func updateDivider(for cell: TableViewCell, dividerType: EpoxyModelDividerType, dataID: String?) {
    if let dataID = dataID,
      dataIDsForHidingDividers.contains(dataID)
    {
      cell.dividerView?.isHidden = true
      return
    }
    switch dividerType {
    case .none:
      if !showsLastDivider {
        cell.dividerView?.isHidden = true
      } else {
        configureCellWithRowDivider(cell: cell)
      }
    case .rowDivider:
      configureCellWithRowDivider(cell: cell)
    case .sectionHeaderDivider:
      configureCellWithSectionHeaderDivider(cell: cell)
    }
  }

  private func configureCellWithRowDivider(cell: TableViewCell) {
    if let rowDividerBuilder = rowDividerBuilder {
      cell.dividerView?.isHidden = false
      cell.makeDividerViewIfNeeded(with: rowDividerBuilder)
      if let divider = cell.dividerView {
        rowDividerConfigurer?(divider)
      }
    } else {
      cell.dividerView?.isHidden = true
    }
  }

  private func configureCellWithSectionHeaderDivider(cell: TableViewCell) {
    if let sectionHeaderDividerBuilder = sectionHeaderDividerBuilder {
      cell.dividerView?.isHidden = false
      cell.makeDividerViewIfNeeded(with: sectionHeaderDividerBuilder)
      if let divider = cell.dividerView {
        sectionHeaderDividerConfigurer?(divider)
      }
    } else {
      cell.dividerView?.isHidden = true
    }
  }

  private func updateHorizontalMarginsIfNeeded(for cell: UITableViewCell) {
    guard cell.layoutMargins.left != layoutMargins.left
      || cell.layoutMargins.right != layoutMargins.right else {
      return
    }
    cell.layoutMargins = UIEdgeInsets(
      top: cell.layoutMargins.top,
      left: layoutMargins.left,
      bottom: cell.layoutMargins.bottom,
      right: layoutMargins.right)
  }

  private func isTableViewLaidOut() -> Bool {
    return frame.size.width > 0 && frame.size.height > 0
  }
}

// MARK: UITableViewDelegate

extension TableView: UITableViewDelegate {

  public func tableView(
    _ tableView: UITableView,
    willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath)
  {
    guard let item = epoxyDataSource.epoxyModel(at: indexPath) else {
      assertionFailure("Index path is out of bounds.")
      return
    }
    epoxyModelDisplayDelegate?.tableView(self, willDisplay: item.epoxyModel)
  }

  public func tableView(
    _ tableView: UITableView,
    shouldHighlightRowAt indexPath: IndexPath) -> Bool
  {
    guard let item = epoxyDataSource.epoxyModel(at: indexPath) else {
      assertionFailure("Index path is out of bounds")
      return false
    }
    return item.epoxyModel.isSelectable
  }

  public func tableView(
    _ tableView: UITableView,
    didHighlightRowAt indexPath: IndexPath)
  {
    guard let item = epoxyDataSource.epoxyModel(at: indexPath),
      let cell = tableView.cellForRow(at: indexPath) as? TableViewCell else {
      assertionFailure("Index path is out of bounds")
      return
    }
    item.epoxyModel.configure(cell: cell, forState: .highlighted)
  }

  public func tableView(
    _ tableView: UITableView,
    didUnhighlightRowAt indexPath: IndexPath)
  {
    guard let item = epoxyDataSource.epoxyModel(at: indexPath),
      let cell = tableView.cellForRow(at: indexPath) as? TableViewCell else {
        assertionFailure("Index path is out of bounds")
        return
    }
    item.epoxyModel.configure(cell: cell, forState: .normal)
  }

  public func tableView(
    _ tableView: UITableView,
    willSelectRowAt indexPath: IndexPath) -> IndexPath?
  {
    guard let item = epoxyDataSource.epoxyModel(at: indexPath) else {
      assertionFailure("Index path is out of bounds")
      return nil
    }
    return item.epoxyModel.isSelectable ? indexPath : nil
  }

  public func tableView(
    _ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath)
  {
    guard let item = epoxyDataSource.epoxyModel(at: indexPath),
      let cell = tableView.cellForRow(at: indexPath) as? TableViewCell else {
      assertionFailure("Index path is out of bounds")
      return
    }
    item.epoxyModel.configure(cell: cell, forState: .selected)
    item.epoxyModel.didSelect()
    tableView.deselectRow(at: indexPath, animated: true)
  }

  public func tableView(
    _ tableView: UITableView,
    didDeselectRowAt indexPath: IndexPath)
  {
    guard let item = epoxyDataSource.epoxyModel(at: indexPath),
      let cell = tableView.cellForRow(at: indexPath) as? TableViewCell else {
        assertionFailure("Index path is out of bounds")
        return
    }
    item.epoxyModel.configure(cell: cell, forState: .normal)
  }

  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewDidScroll?(scrollView)
    let (newState, shouldTrigger) = updatedInfiniteScrollingState(in: scrollView)
    infiniteScrollingState = newState
    if shouldTrigger {
      infiniteScrollingLoader?.startAnimating()
      infiniteScrollingDelegate?.didScrollToInfiniteLoader { [weak self] in
        self?.infiniteScrollingLoader?.stopAnimating()
        self?.infiniteScrollingState = .stopped
      }
    }
  }

  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewWillBeginDragging?(scrollView)
  }

  public func scrollViewWillEndDragging(
    _ scrollView: UIScrollView, withVelocity
    velocity: CGPoint,
    targetContentOffset: UnsafeMutablePointer<CGPoint>)
  {
    scrollDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
  }

  public func scrollViewDidEndDragging(
    _ scrollView: UIScrollView, willDecelerate
    decelerate: Bool)
  {
    scrollDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
  }

  public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
    return scrollDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
  }

  public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewDidScrollToTop?(scrollView)
  }

  public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewWillBeginDecelerating?(scrollView)
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewDidEndDecelerating?(scrollView)
  }

  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
  }
}

// MARK: Unavailable Methods

extension TableView {

  @available (*, unavailable, message: "You shouldn't be registering cell classes on a TableView. The TableViewEpoxyDataSource handles this for you.")
  public override func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
    super.register(cellClass, forCellReuseIdentifier: identifier)
  }

  @available (*, unavailable, message: "You shouldn't be registering cell nibs on a TableView. The TableViewEpoxyDataSource handles this for you.")
  public override func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
    super.register(nib, forCellReuseIdentifier: identifier)
  }

  @available (*, unavailable, message: "You shouldn't be header or footer nibs on a TableView. The TableViewEpoxyDataSource handles this for you.")
  public override func register(_ nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: String) {
    super.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
  }

  @available (*, unavailable, message: "You shouldn't be registering header or footer classes on a TableView. The TableViewEpoxyDataSource handles this for you.")
  public override func register(_ aClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String) {
    super.register(aClass, forHeaderFooterViewReuseIdentifier: identifier)
  }

}
