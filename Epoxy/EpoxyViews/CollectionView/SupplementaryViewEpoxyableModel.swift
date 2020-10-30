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
  associatedtype DataID: Hashable

  var dataID: DataID { get }
  func makeView() -> View
  func configureView(_ view: View, forTraitCollection traitCollection: UITraitCollection)
  func setViewBehavior(_ view: View)
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

  public func setBehavior(reusableView: CollectionViewReusableView) {
    let view = reusableView.view as? View ?? makeView() // Kyle++
    reusableView.setViewIfNeeded(view: view)
    setViewBehavior(view)
  }

  public var dataID: AnyHashable {
    // We need the explicit type annotation to ensure the compiler doesn't stack overflow here.
    let id: DataID = dataID

    // If the data ID is double-boxed as an AnyHashable<AnyHashable<…>>, we need to unbox it to
    // ensure it would be equal to a single-boxed value. This is a Swift standard lib bug
    // https://bugs.swift.org/browse/SR-13794.
    let casted = id as AnyHashable
    if let base = casted.base as? AnyHashable {
      return base
    }
    return casted
  }
}
