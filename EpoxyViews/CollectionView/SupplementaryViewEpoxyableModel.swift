//  Created by Laura Skelton on 9/8/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// The `SupplementaryViewEpoxyableModel` contains the reference data id for the model backing
/// an item, the element kind, as well as the reuse id for the item's type.
public protocol SupplementaryViewEpoxyableModel {

  var elementKind: String { get }
  var reuseID: String { get }
  var dataID: String { get }

  func configure(
    reusableView: CollectionViewReusableView,
    forTraitCollection traitCollection: UITraitCollection)
}

/// This contains the view's data and methods for lazily creating views and applying the data to a view.
public protocol TypedSupplementaryViewEpoxyableModel: SupplementaryViewEpoxyableModel {

  associatedtype View: UIView

  func makeView() -> View
  func configureView(_ view: View, forTraitCollection traitCollection: UITraitCollection)
}

extension TypedSupplementaryViewEpoxyableModel {
  public func configure(
    reusableView: CollectionViewReusableView,
    forTraitCollection traitCollection: UITraitCollection)
  {
    let view = reusableView.view as? View ?? makeView() // Kyle++
    reusableView.setViewIfNeeded(view: view)
    configureView(view, forTraitCollection: traitCollection)
  }
}
