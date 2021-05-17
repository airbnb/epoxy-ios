// Created by Tyler Hedrick on 1/28/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import UIKit

class BaseRow: UIView {
  init() {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    layoutMargins = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
