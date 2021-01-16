// Created by Cal Stephens on 11/30/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit
import Epoxy

// MARK: - StaticHeightBar

final class StaticHeightBar: UIView, EpoxyableView {

  // MARK: Lifecycle

  struct Style: Hashable {
    var height: CGFloat
  }

  init(style: Style) {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalToConstant: style.height)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}

// MARK: - EmptyContent

struct EmptyContent: Equatable { }
