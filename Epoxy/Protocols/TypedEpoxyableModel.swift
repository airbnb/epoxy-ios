//  Created by Laura Skelton on 1/4/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// This contains the view's data and methods for lazily creating views and applying the data to a view.
public protocol TypedEpoxyableModel: EpoxyableModel {

  associatedtype View: UIView

  func makeView() -> View
  func configureView(_ view: View, with metadata: EpoxyViewMetadata)
  func configureViewForStateChange(_ view: View, with metadata: EpoxyViewMetadata)
  func setViewBehavior(_ view: View, with metadata: EpoxyViewMetadata)
  func didSelectView(_ view: View, with metadata: EpoxyViewMetadata)
}

extension TypedEpoxyableModel {
  public func configure(cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) {
    let view = cell.view as? View ?? makeView() // Kyle++
    cell.setViewIfNeeded(view: view)
    configureView(view, with: metadata)
  }

  public func configureStateChange(in cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) {
    let view = cell.view as? View ?? makeView() // Kyle++
    cell.setViewIfNeeded(view: view)
    configureViewForStateChange(view, with: metadata)
  }

  public func setBehavior(cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) {
    let view = cell.view as? View ?? makeView() // Kyle++
    cell.setViewIfNeeded(view: view)
    setViewBehavior(view, with: metadata)
  }

  public func didSelect(_ cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) {
    guard let view = cell.view as? View else {
      assertionFailure("The selected view is not the expected type.")
      return
    }
    didSelectView(view, with: metadata)
  }

  public func configuredView(traitCollection: UITraitCollection) -> UIView {
    let view = makeView()
    let metadata = EpoxyViewMetadata(
      traitCollection: traitCollection,
      state: .normal,
      animated: false)
    configureView(view, with: metadata)
    setViewBehavior(view, with: metadata)
    return view
  }

  public func setViewBehavior(_ view: View, with metadata: EpoxyViewMetadata) { }
  public func didSelectView(_ view: View, with metadata: EpoxyViewMetadata) { }

  public func configureViewForStateChange(_ view: View, with metadata: EpoxyViewMetadata) { }

}
