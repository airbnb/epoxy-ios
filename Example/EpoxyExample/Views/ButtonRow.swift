// Created by Tyler Hedrick on 1/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class ButtonRow: UIView, EpoxyableView {

  // MARK: Lifecycle

  init() {
    super.init(frame: .zero)
    setUp()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  struct Behaviors: ViewBehaviors {
    var buttonWasTapped: ((UIButton) -> Void)?
  }

  struct Content: Equatable {
    var text: String?
  }

  func setContent(_ content: Content, animated: Bool) {
    text = content.text
  }

  func setBehaviors(_ behaviors: Behaviors) {
    buttonWasTapped = behaviors.buttonWasTapped
  }

  // MARK: Private

  private let button = UIButton(type: .system)
  private var buttonWasTapped: ((UIButton) -> Void)?

  private var text: String? {
    get { button.title(for: .normal) }
    set { button.setTitle(newValue, for: .normal) }
  }

  private func setUp() {
    translatesAutoresizingMaskIntoConstraints = false
    layoutMargins = UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24)
    backgroundColor = .tertiarySystemFill

    button.tintColor = .systemBlue
    button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
    button.translatesAutoresizingMaskIntoConstraints = false

    addSubview(button)
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      button.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      button.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      button.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
    ])

    button.addTarget(
      self,
      action: #selector(buttonTapped),
      for: .touchUpInside)
  }

  @objc
  private func buttonTapped() {
    buttonWasTapped?(button)
  }

}
