//  Created by Laura Skelton on 1/12/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

public protocol ListCell {
  var view: UIView? { get }
  func setViewIfNeeded(view: UIView)
  var isHighlighted: Bool { get }
  var isSelected: Bool { get }
}

extension ListCell {

  public var state: ListCellState {
    var state: ListCellState = .normal
    if isHighlighted {
      state = .highlighted
    }
    if isSelected {
      state = .selected
    }
    return state
  }
  
}
