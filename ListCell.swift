//  Created by Laura Skelton on 1/12/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

public protocol ListCell {
  var view: UIView? { get }
  func setViewIfNeeded(view: UIView)
}
