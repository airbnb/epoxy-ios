//  Created by Laura Skelton on 9/8/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// The `SupplementaryViewEpoxyableModel` contains the reference data id for the model backing
/// an item, the element kind, as well as the reuse id for the item's type.
public protocol SupplementaryViewEpoxyableModel {

  var elementKind: String { get }
  var reuseID: String { get }
  var dataID: AnyHashable { get }

  func configure(
    reusableView: CollectionViewReusableView,
    forTraitCollection traitCollection: UITraitCollection)

  func setBehavior(reusableView: CollectionViewReusableView)
}

/// This contains the view's data and methods for lazily creating views and applying the data to a view.
public protocol TypedSupplementaryViewEpoxyableModel: SupplementaryViewEpoxyableModel {

  associatedtype View: UIView

  var dataID: AnyHashable { get }
  func makeView() -> View
  func configureView(_ view: View, forTraitCollection traitCollection: UITraitCollection)
  func setViewBehavior(_ view: View)
}

extension TypedSupplementaryViewEpoxyableModel {

  public func configure(
    reusableView: CollectionViewReusableView,
    forTraitCollection traitCollection: UITraitCollection)
  {
    let view = reusableView.view as? View ?? makeView()
    reusableView.setViewIfNeeded(view: view)
    configureView(view, forTraitCollection: traitCollection)
  }

  public func setBehavior(reusableView: CollectionViewReusableView) {
    let view = reusableView.view as? View ?? makeView()
    reusableView.setViewIfNeeded(view: view)
    setViewBehavior(view)
  }
}
