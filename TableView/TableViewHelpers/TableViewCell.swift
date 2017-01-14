//  Created by Laura Skelton on 12/3/16.
//  Copyright © 2016 com.airbnb. All rights reserved.

import UIKit

/// An internal cell class for use in a `TableView`. It handles displaying a `Divider` and
/// wraps view classes passed to it through a `ViewMaker`.
final class TableViewCell: UITableViewCell {

  // MARK: Lifecycle

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    backgroundColor = .clear
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  private(set) var dividerView: UIView?
  private(set) var view: UIView?

  /// Pass a `ViewMaker` to generate a view for this cell's reuseID that the cell will pin to the edges of its `contentView`.
  func makeViewIfNeeded(with viewMaker: ViewMaker) {
    if self.view != nil {
      return
    }
    let view = viewMaker()
    view.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(view)
    view.constrainToParent()
    self.view = view

    if let dividerView = dividerView {
      contentView.bringSubview(toFront: dividerView)
    }
  }

  /// Pass a `ViewMaker` to generate a `Divider` for this cell's reuseID that the cell will pin to the bottom of its `contentView`.
  func makeDividerViewIfNeeded(with viewMaker: ViewMaker) {
    if self.dividerView != nil {
      return
    }
    let dividerView = viewMaker()
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(dividerView)
    dividerView.constrainToParent([.bottom, .trailing, .leading])
    self.dividerView = dividerView
  }
}
