//  Created by Laura Skelton on 5/14/17.
//  Copyright © 2017 Airbnb. All rights reserved.

// MARK: - ItemCellState

/// The state of an cell that contains an item view.
public enum ItemCellState {
  /// The item cell is neither selected nor highlighted.
  case normal
  /// The item cell is highlighted.
  case highlighted
  /// The item cell is selected.
  case selected
}
