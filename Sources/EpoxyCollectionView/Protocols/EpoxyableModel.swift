//  Created by Laura Skelton on 1/12/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import Foundation
import UIKit

// MARK: - EpoxyableModel

public protocol EpoxyableModel: DataIDProviding, ReuseIDProviding, Diffable {
  /// Returns this Epoxy model with its type erased to the `AnyEpoxyModel` type.
  func eraseToAnyEpoxyModel() -> AnyEpoxyModel
}

// MARK: Extensions

extension EpoxyableModel {
  /// The internal wrapped Epoxy model.
  var internalEpoxyModel: InternalEpoxyableModel {
    eraseToAnyEpoxyModel().model
  }
}

// MARK: - InternalEpoxyableModel

public protocol InternalEpoxyableModel: EpoxyableModel,
  EpoxyModeled,
  SelectionStyleProviding,
  IsMovableProviding
{
  /// Configures the cell for presentation.
  func configure(cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata)

  /// Set behaviors needed by the view.
  ///
  /// Called before presentation and when cells are reordered.
  func setBehavior(cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata)

  /// Updates the cell based on a state change.
  func configureStateChange(in cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata)

  /// Handles the cell being selected.
  func handleDidSelect(_ cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata)

  /// Informs consumers that this item is about to be displayed.
  func handleWillDisplay()

  /// Informs consumers that this item is no longer displayed.
  func handleDidEndDisplaying()

  /// Whether the cell should be selectable.
  var isSelectable: Bool { get }

  /// Creates view for this epoxy model. This should only be used to create a view outside of a
  /// collection or table view.
  ///
  /// - Parameter traitCollection: The trait collection to create the view for
  /// - Returns: The configured view for this epoxy model.
  func configuredView(traitCollection: UITraitCollection) -> UIView
}

// MARK: Diffable

extension InternalEpoxyableModel {
  public var diffIdentifier: AnyHashable {
    DiffIdentifier(reuseID: reuseID, dataID: dataID)
  }
}

// MARK: - DiffIdentifier

private struct DiffIdentifier: Hashable {
  var reuseID: String
  var dataID: AnyHashable
}
