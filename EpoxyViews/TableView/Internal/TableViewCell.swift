//  Created by Laura Skelton on 12/3/16.
//  Copyright © 2016 com.airbnb. All rights reserved.

import UIKit

/// An internal cell class for use in a `TableView`. It handles displaying a `Divider` and
/// wraps view classes passed to it.
public final class TableViewCell: UITableViewCell, EpoxyCell {

  // MARK: Lifecycle

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    backgroundColor = .clear
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public private(set) var view: UIView?

  /// Pass a view for this cell's reuseID that the cell will pin to the edges of its `contentView`.
  public func setViewIfNeeded(view: UIView) {
    if self.view != nil {
      return
    }
    view.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(view)
    view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    let bottomConstraint = view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    bottomConstraint.priority = UILayoutPriorityDefaultHigh - 1
    bottomConstraint.isActive = true
    self.view = view

    updateHorizontalViewMarginsIfNeeded()

    if let dividerView = dividerView {
      contentView.bringSubview(toFront: dividerView)
    }
  }

  public override func layoutMarginsDidChange() {
    super.layoutMarginsDidChange()
    updateHorizontalViewMarginsIfNeeded()
  }

  // MARK: Internal

  private(set) var dividerView: UIView?

  /// Pass a `ViewMaker` that generates a `Divider` for this cell's reuseID that the cell will pin to the bottom of its `contentView`.
  func makeDividerViewIfNeeded(with dividerViewMaker: () -> UIView) {
    if self.dividerView != nil {
      return
    }
    let dividerView = dividerViewMaker()
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(dividerView)
    dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    dividerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    self.dividerView = dividerView
  }

  // MARK: Private

  private func updateHorizontalViewMarginsIfNeeded() {
    guard let view = view,
      view.layoutMargins.left != layoutMargins.left
        || view.layoutMargins.right != layoutMargins.right else {
          return
    }
    view.layoutMargins = UIEdgeInsets(
      top: view.layoutMargins.top,
      left: layoutMargins.left,
      bottom: view.layoutMargins.bottom,
      right: layoutMargins.right)
  }
}
