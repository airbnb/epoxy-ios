//  Created by Laura Skelton on 1/12/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

// MARK: - ItemWrapperView

/// A reusable view that contains an item view.
public protocol ItemWrapperView: UIView {
  /// The view if it has been set via `setViewIfNeeded(view:)`, else `nil`.
  var view: UIView? { get }

  /// Updates the `view` of this wrapper to the given view if it has not been set yet.
  func setViewIfNeeded(view: UIView)
}

// MARK: - ItemCellView

/// A reusable cell that contains an item view.
public protocol ItemCellView: ItemWrapperView {
  /// Whether this cell is highlighted.
  var isHighlighted: Bool { get }

  /// Whether this cell is selected.
  var isSelected: Bool { get }
}

// MARK: Extensions

extension ItemCellView {
  /// The state of this cell view.
  public var state: ItemCellState {
    var state: ItemCellState = .normal
    if isHighlighted {
      state = .highlighted
    }
    if isSelected {
      state = .selected
    }
    return state
  }
}
