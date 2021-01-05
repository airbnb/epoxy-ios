// Created by Tyler Hedrick on 9/12/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

public final class Row: UIView {

  init() {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    setUpViews()
    setUpConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public var titleText: String? {
    set { titleLabel.text = newValue }
    get { return titleLabel.text }
  }

  public var text: String? {
    set { label.text = newValue }
    get { return label.text }
  }

  public var textColor: UIColor {
    set { label.textColor = newValue }
    get { return label.textColor }
  }

  // MARK: Private

  private let titleLabel = UILabel(frame: .zero)
  private let label = UILabel(frame: .zero)
  private let stackView = UIStackView(frame: .zero)

  private func setUpViews() {
    titleLabel.textColor = .black
    titleLabel.font = .boldSystemFont(ofSize: 20)
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .black
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 8
    stackView.axis = .vertical
    stackView.alignment = .leading
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(
      top: 16,
      left: 24,
      bottom: 16,
      right: 24)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(label)
    addSubview(stackView)
  }

  private func setUpConstraints() {
    stackView.leadingAnchor.constraint(
      equalTo: self.leadingAnchor).isActive = true
    stackView.trailingAnchor.constraint(
      equalTo: self.trailingAnchor).isActive = true
    stackView.topAnchor.constraint(
      equalTo: self.topAnchor).isActive = true
    stackView.bottomAnchor.constraint(
      equalTo: self.bottomAnchor).isActive = true
  }
}

struct RowContent: Equatable {
  var title: String?
  var subtitle: String?
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

extension Row: DisplayResponder {
  public func didDisplay(_ isDisplayed: Bool) {
    print("Is displayed? \(isDisplayed)")
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
