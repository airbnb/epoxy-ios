//  Created by Laura Skelton on 12/3/16.
//  Copyright © 2016 com.airbnb. All rights reserved.

import UIKit

/// An internal cell class for use in a `TableView`. It handles displaying a `Divider` and
/// wraps view classes passed to it.
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

  /// Pass a view for this cell's reuseID that the cell will pin to the edges of its `contentView`.
  func setViewIfNeeded(view: UIView) {
    if self.view != nil {
      return
    }
    view.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(view)
    view.constrainToParent()
    self.view = view

    if let dividerView = dividerView {
      contentView.bringSubview(toFront: dividerView)
    }
  }

  /// Pass a `ViewMaker` that generates a `Divider` for this cell's reuseID that the cell will pin to the bottom of its `contentView`.
  func makeDividerViewIfNeeded(with dividerViewMaker: ViewMaker) {
    if self.dividerView != nil {
      return
    }
    let dividerView = dividerViewMaker()
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(dividerView)
    dividerView.constrainToParent([.bottom, .trailing, .leading])
    self.dividerView = dividerView
  }
}

extension TableViewCell: ListCell {
  
}
