//  Created by Laura Skelton on 1/4/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// This contains the view's data and methods for lazily creating views and applying the data to a view.
public protocol TypedEpoxyableModel: EpoxyableModel {

  associatedtype View: UIView

  func makeView() -> View
  func configureView(_ view: View, animated: Bool)
  func configureView(_ view: View, forState state: EpoxyCellState)
  func setViewBehavior(_ view: View)
  func didSelectView(_ view: View)
}

extension TypedEpoxyableModel {
  public func configure(cell: EpoxyCell, animated: Bool) {
    let view = cell.view as? View ?? makeView() // Kyle++
    cell.setViewIfNeeded(view: view)
    configureView(view, animated: animated)
  }

  public func configure(cell: EpoxyCell, forState state: EpoxyCellState) {
    let view = cell.view as? View ?? makeView() // Kyle++
    cell.setViewIfNeeded(view: view)
    configureView(view, forState: state)
  }

  public func setBehavior(cell: EpoxyCell) {
    let view = cell.view as? View ?? makeView() // Kyle++
    cell.setViewIfNeeded(view: view)
    setViewBehavior(view)
  }

  public func didSelect(_ cell: EpoxyCell) {
    guard let view = cell.view as? View else {
      assertionFailure("The selected view is not the expected type.")
      return
    }
    didSelectView(view)
  }

  public func setViewBehavior(_ view: View) { }
  public func didSelectView(_ view: View) { }

  public func configureView(_ view: View, forState state: EpoxyCellState) { }

}
