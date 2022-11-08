//  Created by Laura Skelton on 9/8/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - SupplementaryItemModeling

/// Contains the reference data id for the model backing an item, as well as the reuse id for the
/// item's type.
public protocol SupplementaryItemModeling {
  /// Returns this item model with its type erased to the `AnySupplementaryItemModel` type.
  func eraseToAnySupplementaryItemModel() -> AnySupplementaryItemModel
}

// MARK: Extensions

extension SupplementaryItemModeling {
  /// The internal wrapped item model.
  var internalItemModel: InternalSupplementaryItemModeling {
    eraseToAnySupplementaryItemModel().model
  }
}

// MARK: - InternalSupplementaryItemModeling

protocol InternalSupplementaryItemModeling: SupplementaryItemModeling,
  DataIDProviding,
  ViewDifferentiatorProviding,
  Diffable,
  EpoxyModeled
{
  /// Configures the cell for presentation.
  func configure(
    reusableView: CollectionViewReusableView,
    traitCollection: UITraitCollection,
    animated: Bool)

  /// Creates view for this supplementary item. This should only be used to create a view outside of a collection
  /// view.
  ///
  /// - Parameter traitCollection: The trait collection to create the view for
  /// - Returns: The configured view for this supplementary item model.
  func configuredView(traitCollection: UITraitCollection) -> UIView

  /// Set behaviors needed by the view.
  ///
  /// Called before presentation and when cells are reordered.
  func setBehavior(
    reusableView: CollectionViewReusableView,
    traitCollection: UITraitCollection,
    animated: Bool)

  /// Informs consumers that this item is about to be displayed.
  func handleWillDisplay(
    _ view: CollectionViewReusableView,
    traitCollection: UITraitCollection,
    animated: Bool)

  /// Informs consumers that this item is no longer displayed.
  func handleDidEndDisplaying(
    _ view: CollectionViewReusableView,
    traitCollection: UITraitCollection,
    animated: Bool)
}
