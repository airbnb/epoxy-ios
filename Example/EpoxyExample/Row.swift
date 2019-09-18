// Created by Tyler Hedrick on 9/12/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

public final class Row: UIView {

  init() {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    layoutMargins = UIEdgeInsets(
      top: 16,
      left: 24,
      bottom: 16,
      right: 24)
    setUpViews()
    setUpConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public var text: String? {
    set { label.text = newValue }
    get { return label.text }
  }

  // MARK: Private

  private let label = UILabel(frame: .zero)

  private func setUpViews() {
    label.translatesAutoresizingMaskIntoConstraints = false
    addSubview(label)
  }

  private func setUpConstraints() {
    label.leadingAnchor.constraint(
      equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
    label.trailingAnchor.constraint(
      equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
    label.topAnchor.constraint(
      equalTo: layoutMarginsGuide.topAnchor).isActive = true
    label.bottomAnchor.constraint(
      equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
  }

}

extension Row: Selectable {
  public func didSelect() {
    print("Firing haptic feedback!")
    UISelectionFeedbackGenerator().selectionChanged()
  }
}

extension Row: Highlightable {
  public func didHighlight(_ isHighlighted: Bool) {
    switch isHighlighted {
    case true:
      shrink()
    case false:
      reset()
    }
  }
}

extension Row {
  func shrink() {
    UIView.animate(withDuration: 0.15) {
      self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }
  }

  func reset() {
    UIView.animate(withDuration: 0.15) {
      self.transform = .identity
    }
  }
}
