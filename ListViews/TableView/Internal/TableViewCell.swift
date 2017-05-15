//  Created by Laura Skelton on 12/3/16.
//  Copyright © 2016 com.airbnb. All rights reserved.

import UIKit

/// An internal cell class for use in a `TableView`. It handles displaying a `Divider` and
/// wraps view classes passed to it.
public final class TableViewCell: UITableViewCell, ListCell {

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
    view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    self.view = view

    if let dividerView = dividerView {
      contentView.bringSubview(toFront: dividerView)
    }
  }

  // MARK: Internal

  private(set) var dividerView: UIView?

  /// Pass a `ViewMaker` that generates a `Divider` for this cell's reuseID that the cell will pin to the bottom of its `contentView`.
  func makeDividerViewIfNeeded(with dividerViewMaker: ViewMaker) {
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
}
