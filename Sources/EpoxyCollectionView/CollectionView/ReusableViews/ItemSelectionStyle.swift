//  Created by bryan_keller on 10/10/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// The style applied to selected items in a `CollectionView`.
///
/// - SeeAlso: `SelectionStyleProviding`
public enum ItemSelectionStyle: Hashable {
  /// No background is drawn behind selected items.
  ///
  /// This case can't be labeled "none" as that is misinterpreted by the compiler as Optional.none
  /// when checking against .none in other files. https://forums.swift.org/t/optional-enum-with-case-none/19126
  case noBackground
  /// The associated color is drawn behind selected items.
  case color(UIColor)
}
