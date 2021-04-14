// Created by Tyler Hedrick on 4/5/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

final class Button: UIButton, EpoxyableView {

  // MARK: Lifecycle

  init(style: Style) {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    setTitleColor(style.color, for: .normal)
    titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
    addTarget(
      self,
      action: #selector(handleButtonTapped(_:)),
      for: .touchUpInside)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  // MARK: EpoxyableView

  struct Style: Hashable {
    let color = UIColor.systemGreen
  }

  struct Content: Equatable {
    let title: String
  }

  struct Behaviors {
    let didTap: (UIButton) -> Void
  }

  func setContent(_ content: Content, animated: Bool) {
    setTitle(content.title, for: .normal)
  }

  func setBehaviors(_ behaviors: Behaviors?) {
    didTap = behaviors?.didTap
  }

  @objc
  func handleButtonTapped(_ sender: UIButton) {
    didTap?(sender)
  }

  // MARK: Private

  private var didTap: ((UIButton) -> Void)?

}
