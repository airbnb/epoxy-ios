//  Created by Laura Skelton on 1/4/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// This contains the view's data and methods for lazily creating views and applying the data to a view.
public protocol ViewConfigurer: ListItem {

  associatedtype View: UIView

  func makeView() -> View
  func configureView(_ view: View, animated: Bool)
  func configureView(_ view: View, forState state: ListCellState)
  func setViewBehavior(_ view: View)
}

extension ViewConfigurer {
  public func configure(cell: ListCell, animated: Bool) {
    let view = cell.view as? View ?? makeView() // Kyle++
    cell.setViewIfNeeded(view: view)
    configureView(view, animated: animated)
  }

  public func configure(cell: ListCell, forState state: ListCellState) {
    let view = cell.view as? View ?? makeView() // Kyle++
    cell.setViewIfNeeded(view: view)
    configureView(view, forState: state)
  }

  public func setBehavior(cell: ListCell) {
    let view = cell.view as? View ?? makeView() // Kyle++
    cell.setViewIfNeeded(view: view)
    setViewBehavior(view)
  }

  public func setViewBehavior(_ view: View) { }

  public func configureView(_ view: View, forState state: ListCellState) { }

}
