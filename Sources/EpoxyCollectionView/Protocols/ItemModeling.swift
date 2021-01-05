//  Created by Laura Skelton on 1/12/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import Foundation
import UIKit

// MARK: - ItemModeling

public protocol ItemModeling: DataIDProviding, ReuseIDProviding, Diffable {
  /// Returns this item model with its type erased to the `AnyItemModel` type.
  func eraseToAnyItemModel() -> AnyItemModel
}

// MARK: Extensions

extension ItemModeling {
  /// The internal wrapped item model.
  var internalItemModel: InternalItemModeling {
    eraseToAnyItemModel().model
  }
}

// MARK: - InternalItemModeling

public protocol InternalItemModeling: ItemModeling,
  EpoxyModeled,
  SelectionStyleProviding,
  IsMovableProviding
{
  /// Configures the cell for presentation.
  func configure(cell: ItemWrapperView, with metadata: EpoxyViewMetadata)

  /// Set behaviors needed by the view.
  ///
  /// Called before presentation and when cells are reordered.
  func setBehavior(cell: ItemWrapperView, with metadata: EpoxyViewMetadata)

  /// Updates the cell based on a state change.
  func configureStateChange(in cell: ItemWrapperView, with metadata: EpoxyViewMetadata)

  /// Handles the cell being selected.
  func handleDidSelect(_ cell: ItemWrapperView, with metadata: EpoxyViewMetadata)

  /// Informs consumers that this item is about to be displayed.
  func handleWillDisplay(_ cell: ItemWrapperView, with metadata: EpoxyViewMetadata)

  /// Informs consumers that this item is no longer displayed.
  func handleDidEndDisplaying(_ cell: ItemWrapperView, with metadata: EpoxyViewMetadata)

  /// Whether the cell should be selectable.
  var isSelectable: Bool { get }

  /// Creates view for this item. This should only be used to create a view outside of a collection
  /// view.
  ///
  /// - Parameter traitCollection: The trait collection to create the view for
  /// - Returns: The configured view for this item model.
  func configuredView(traitCollection: UITraitCollection) -> UIView
}

// MARK: Diffable

extension InternalItemModeling {
  public var diffIdentifier: AnyHashable {
    DiffIdentifier(reuseID: reuseID, dataID: dataID)
  }
}

// MARK: - DiffIdentifier

private struct DiffIdentifier: Hashable {
  var reuseID: String
  var dataID: AnyHashable
}
