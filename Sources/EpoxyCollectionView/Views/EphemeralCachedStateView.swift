//  Created by Kieraj Mumick on 1/16/19.
//  Copyright © 2019 Airbnb. All rights reserved.

import UIKit

/// A protocol for views that have ephemeral state that (e.g. expansion state) within a
/// `CollectionView`.
///
/// Epoxy uses the cached ephemeral state to automatically restore state when cells are recycled.
public protocol EphemeralCachedStateView: UIView {
  /// The cached ephemeral state that is automatically restored after this cell is recycled.
  var cachedEphemeralState: Any? { get set }
}
