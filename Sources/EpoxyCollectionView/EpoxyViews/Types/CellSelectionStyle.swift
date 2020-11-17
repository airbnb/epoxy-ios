//  Created by bryan_keller on 10/10/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

public enum CellSelectionStyle {
  // This case can't be labeled "none" as that is misinterpreted by the compiler as Optional.none when checking against .none in other files. https://forums.swift.org/t/optional-enum-with-case-none/19126
  case noBackground
  case color(UIColor)
}
