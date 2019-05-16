//  Created by Laura Skelton on 1/4/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// This contains the view's data and methods for lazily creating views and applying the data to a view.
public protocol TypedEpoxyableModel: EpoxyableModel {

  associatedtype View: UIView

  func makeView() -> View
  func configureView(_ view: View, forTraitCollection traitCollection: UITraitCollection, animated: Bool)
  func configureView(_ view: View, forTraitCollection traitCollection: UITraitCollection, state: EpoxyCellState)
  func setViewBehavior(_ view: View)
  func didSelectView(_ view: View)
  func viewWillDisplay(_ view: View)
  func viewDidEndDisplaying(_ view: View)
}

extension TypedEpoxyableModel {
  public func configure(cell: EpoxyWrapperView, forTraitCollection traitCollection: UITraitCollection, animated: Bool) {
    let view = cell.view as? View ?? makeView() // Kyle++
    cell.setViewIfNeeded(view: view)
    configureView(view, forTraitCollection: traitCollection, animated: animated)
  }

  public func configure(cell: EpoxyWrapperView, forTraitCollection traitCollection: UITraitCollection, state: EpoxyCellState) {
    let view = cell.view as? View ?? makeView() // Kyle++
    cell.setViewIfNeeded(view: view)
    configureView(view, forTraitCollection: traitCollection, state: state)
  }

  public func setBehavior(cell: EpoxyWrapperView) {
    let view = cell.view as? View ?? makeView() // Kyle++
    cell.setViewIfNeeded(view: view)
    setViewBehavior(view)
  }

  public func didSelect(_ cell: EpoxyWrapperView) {
    guard let view = cell.view as? View else {
      assertionFailure("The selected view is not the expected type.")
      return
    }
    didSelectView(view)
  }

  public func willDisplay(_ cell: EpoxyWrapperView) {
    guard let view = cell.view as? View else {
      assertionFailure("The displayed view is not the expected type.")
      return
    }
    viewWillDisplay(view)
  }

  public func didEndDisplaying(_ cell: EpoxyWrapperView) {
    guard let view = cell.view as? View else {
      assertionFailure("The disappearing view is not the expected type.")
      return
    }
    viewDidEndDisplaying(view)
  }

  public func configuredView(traitCollection: UITraitCollection) -> UIView {
    let view = makeView()
    configureView(view, forTraitCollection: traitCollection, animated: false)
    setViewBehavior(view)
    return view
  }

  public func setViewBehavior(_ view: View) { }
  public func didSelectView(_ view: View) { }
  public func viewWillDisplay(_ view: View) { }
  public func viewDidEndDisplaying(_ view: View) { }

  public func configureView(_ view: View, forTraitCollection traitCollection: UITraitCollection, state: EpoxyCellState) { }

}
