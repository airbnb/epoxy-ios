//  Created by Laura Skelton on 1/4/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

// This *contains* the content. Whether it's a UIView or a Content struct or a ListItemID or whatever.
public protocol ViewConfigurer: ListItem {

  associatedtype View: UIView

  func makeView() -> View
  func configureView(_ view: View, animated: Bool)
}

extension ViewConfigurer {
  public func configure(cell: ListCell, animated: Bool) {
    let view = cell.view as? View ?? makeView() // Kyle++
    cell.setViewIfNeeded(view: view)
    configureView(view, animated: animated)
  }
}
