//  Created by Laura Skelton on 12/3/16.
//  Copyright © 2016 com.airbnb. All rights reserved.

import UIKit

final class TableViewCell: UITableViewCell {

  // MARK: Lifecycle

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  private(set) var dividerView: UIView?
  private(set) var view: UIView?

  func makeView(with viewMaker: ViewMaker) {
    if self.view != nil {
      return
    }
    let view = viewMaker()
    view.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(view)
    view.constrainToSuperview(attributes: [.bottom, .top, .trailing, .leading])
    self.view = view

    if let dividerView = dividerView {
      contentView.bringSubviewToFront(dividerView)
    }
  }

  func makeDividerView(with viewMaker: ViewMaker) {
    if self.dividerView != nil {
      return
    }
    let dividerView = viewMaker()
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(dividerView)
    dividerView.constrainToSuperview(attributes: [.bottom, .trailing, .leading])
    self.dividerView = dividerView
  }
}
