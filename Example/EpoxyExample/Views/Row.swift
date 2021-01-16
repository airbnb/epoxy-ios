// Created by Tyler Hedrick on 9/12/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class Row: UIView, EpoxyableView {

  // MARK: Lifecycle

  init(style: Style) {
    self.style = style
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    setUpViews()
    setUpConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  enum Style {
    case large
    case small
  }

  struct Content: Equatable {
    var title: String?
    var body: String?
  }

  func setContent(_ content: Content, animated: Bool) {
    title = content.title
    body = content.body
  }

  // MARK: Private

  private let style: Style
  private let titleLabel = UILabel()
  private let bodyLabel = UILabel()
  private let stackView = UIStackView()

  private var title: String? {
    get { titleLabel.text }
    set {
      guard titleLabel.text != newValue else { return }
      titleLabel.text = newValue
      titleLabel.isHidden = (newValue == nil)
    }
  }

  private var body: String? {
    get { bodyLabel.text }
    set {
      guard bodyLabel.text != newValue else { return }
      bodyLabel.text = newValue
      bodyLabel.isHidden = (newValue == nil)
    }
  }

  private func setUpViews() {
    setUpTitleLabel()
    setUpBodyLabel()
    setUpStackView()
  }

  private func setUpTitleLabel() {
    titleLabel.textColor = UIColor.label
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.isHidden = true
    titleLabel.adjustsFontForContentSizeCategory = true
    switch style {
    case .large:
      titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
    case .small:
      titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
    }
  }

  private func setUpBodyLabel() {
    bodyLabel.textColor = UIColor.secondaryLabel
    bodyLabel.numberOfLines = 0
    bodyLabel.translatesAutoresizingMaskIntoConstraints = false
    bodyLabel.isHidden = true
    bodyLabel.adjustsFontForContentSizeCategory = true
    switch style {
    case .large:
      bodyLabel.font = UIFont.preferredFont(forTextStyle: .body)
    case .small:
      bodyLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
    }
  }

  private func setUpStackView() {
    stackView.spacing = 8
    stackView.axis = .vertical
    stackView.alignment = .leading
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
    stackView.insetsLayoutMarginsFromSafeArea = false
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(bodyLabel)
    addSubview(stackView)
  }

  private func setUpConstraints() {
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }
}

// MARK: SelectableView

extension Row: Selectable {
  func didSelect() {
    // Handle this row being selected, e.g. to trigger haptics.
    UISelectionFeedbackGenerator().selectionChanged()
  }
}

// MARK: HighlightableView

extension Row: Highlightable {
  func didHighlight(_ isHighlighted: Bool) {
    UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
      switch isHighlighted {
      case true:
        self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
      case false:
        self.transform = .identity
      }
    }
  }
}

// MARK: DisplayRespondingView

extension Row: DisplayResponder {
  func didDisplay(_ isDisplayed: Bool) {
    // Handle this row being displayed.
  }
}
