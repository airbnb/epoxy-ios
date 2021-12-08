// Created by oleksandr_zarochintsev on 4/26/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class TextFieldRow: UIView, EpoxyableView {

  // MARK: Lifecycle

  init(style: Style) {
    self.style = style
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    setUpViews()
    setUpConstraints()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  enum Style {
    case base
  }

  struct Content: Equatable {
    var text: String?
    var placeholder: String?
  }

  struct Behaviors {
    var didUpdateText: (String?) -> Void
  }

  func setContent(_ content: Content, animated _: Bool) {
    text = content.text
    placeholder = content.placeholder
  }

  func setBehaviors(_ behaviors: Behaviors?) {
    didUpdateText = behaviors?.didUpdateText
  }

  // MARK: Private

  private let style: Style
  private let textField = UITextField()
  private var didUpdateText: ((String?) -> Void)?

  private var text: String? {
    get { textField.text }
    set {
      guard textField.text != newValue else { return }
      textField.text = newValue
    }
  }

  private var placeholder: String? {
    get { textField.placeholder }
    set {
      guard textField.placeholder != newValue else { return }
      textField.placeholder = newValue
    }
  }

  private func setUpViews() {
    setUpTextField()
  }

  private func setUpTextField() {
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.addTarget(self, action: #selector(didChangeText), for: .editingChanged)
    textField.borderStyle = .roundedRect
    addSubview(textField)
  }

  private func setUpConstraints() {
    NSLayoutConstraint.activate([
      textField.topAnchor.constraint(equalTo: topAnchor, constant: 16),
      textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
    ])
  }

  @objc
  private func didChangeText() {
    didUpdateText?(textField.text)
  }
}
