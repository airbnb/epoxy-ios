// Created by Tyler Hedrick on 1/20/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

final class ColorView: UIView, EpoxyableView {

  init(style: Style) {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = style.color
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  struct Style: Hashable {
    var color = UIColor.red
  }

}

extension ColorView.Style {
  static var red: ColorView.Style = .init(color: .systemRed)
  static var orange: ColorView.Style = .init(color: .systemOrange)
  static var yellow: ColorView.Style = .init(color: .systemYellow)
  static var green: ColorView.Style = .init(color: .systemGreen)
  static var blue: ColorView.Style = .init(color: .systemBlue)
  static var purple: ColorView.Style = .init(color: .systemPurple)
}
