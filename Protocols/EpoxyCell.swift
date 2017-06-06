//  Created by Laura Skelton on 1/12/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

public protocol EpoxyCell {
  var view: UIView? { get }
  func setViewIfNeeded(view: UIView)
  var isHighlighted: Bool { get }
  var isSelected: Bool { get }
}

extension EpoxyCell {

  public var state: EpoxyCellState {
    var state: EpoxyCellState = .normal
    if isHighlighted {
      state = .highlighted
    }
    if isSelected {
      state = .selected
    }
    return state
  }
  
}
