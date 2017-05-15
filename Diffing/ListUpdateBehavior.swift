//  Created by Laura Skelton on 5/11/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation

/// The behavior of the ListInterface on update.
public enum ListUpdateBehavior {
  /// The `ListInterface` animates inserts, deletes, moves, and updates.
  case diffs
  /// The `ListInterface` reloads completely.
  case reloads
}
