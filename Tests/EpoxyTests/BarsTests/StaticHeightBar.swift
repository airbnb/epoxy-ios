// Created by Cal Stephens on 11/30/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit
import EpoxyBars

// MARK: - StaticHeightBar

final class StaticHeightBar: UIView {

  // MARK: Lifecycle

  init(height: CGFloat) {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalToConstant: height)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Internal

  static func barModel(height: CGFloat) -> BarModeling {
    BarModel<StaticHeightBar, EmptyContent>(
      content: EmptyContent(),
      makeView: { StaticHeightBar(height: 100) },
      configureView: { _ in })
  }

}

// MARK: - EmptyContent

struct EmptyContent: Equatable { }
