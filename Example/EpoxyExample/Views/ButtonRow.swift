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

  struct Behaviors {
    var didTap: (() -> Void)?
  }

  struct Content: Equatable {
    var text: String?
  }

  func setContent(_ content: Content, animated: Bool) {
    text = content.text
  }

  func setBehaviors(_ behaviors: Behaviors?) {
    didTap = behaviors?.didTap
  }

  // MARK: Private

  private let button = UIButton(type: .system)
  private var didTap: (() -> Void)?

  private var text: String? {
    get { button.title(for: .normal) }
    set { button.setTitle(newValue, for: .normal) }
  }

  private func setUp() {
    translatesAutoresizingMaskIntoConstraints = false
    layoutMargins = UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24)
    backgroundColor = .quaternarySystemFill

    button.tintColor = .systemBlue
    button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
    button.translatesAutoresizingMaskIntoConstraints = false

    addSubview(button)
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      button.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      button.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      button.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
    ])

    button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
  }

  @objc
  private func handleTap() {
    didTap?()
  }

}
