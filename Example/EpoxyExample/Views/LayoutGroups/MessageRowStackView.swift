// Created by Tyler Hedrick on 1/27/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import EpoxyLayoutGroups
import UIKit

/// A component created using UIStackView to compare API and performance
/// to MessageRow which is created using LayoutGroups
final class MessageRowStackView: BaseRow, EpoxyableView {

  // MARK: Lifecycle

  init(style: Style) {
    self.style = style
    super.init()
    setUp()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  struct Style: Hashable {
    let showUnread: Bool
  }

  struct Content: Equatable {
    let name: String
    let date: String
    let messagePreview: String
    let seenText: String
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
      stackView?.axis = useVerticalLayout ? .vertical : .horizontal
    }
  }

  func setContent(_ content: Content, animated: Bool) {
    nameLabel.text = content.name
    dateLabel.text = content.date
    messageLabel.text = content.messagePreview
    seenLabel.text = content.seenText
  }

  // MARK: Private

  private let style: Style
  private let avatar = IconView(
    image: UIImage(systemName: "person.crop.circle"),
    size: .init(width: 48, height: 48))
  private let unreadIndicator = ColorView(
    style: .init(
      size: .init(width: 8, height: 8),
      color: .systemBlue))
  private let nameLabel = Label(style: .style(with: .title3))
  private let dateLabel = Label(style: .style(with: .subheadline))
  private let disclosureIcon = IconView(
    image: UIImage(systemName: "chevron.right"),
    size: .init(width: 12, height: 16))
  private let messageLabel = Label(style: .style(with: .body))
  private let seenLabel = Label(style: .style(with: .footnote))
  private var stackView: UIStackView?

  private var useVerticalLayout: Bool {
    traitCollection.preferredContentSizeCategory.isAccessibilityCategory
  }

  private func setUp() {
    nameLabel.numberOfLines = 1
    dateLabel.numberOfLines = 1
    messageLabel.numberOfLines = 3

    // ensure we always see the full date
    dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

    avatar.layer.cornerRadius = avatar.size.height / 2
    unreadIndicator.layer.cornerRadius = unreadIndicator.intrinsicContentSize.height / 2

    avatar.tintColor = .black
    disclosureIcon.tintColor = .black
    disclosureIcon.contentMode = .center

    let nameAndUnreadStack = UIStackView(arrangedSubviews: [nameLabel])
    if style.showUnread {
      nameAndUnreadStack.addArrangedSubview(unreadIndicator)
    }
    nameAndUnreadStack.axis = .horizontal
    nameAndUnreadStack.alignment = .center
    nameAndUnreadStack.translatesAutoresizingMaskIntoConstraints = false
    nameAndUnreadStack.spacing = 8

    let dateAndDisclosureStack = UIStackView(arrangedSubviews: [
      dateLabel,
      disclosureIcon,
    ])
    dateAndDisclosureStack.axis = .horizontal
    dateAndDisclosureStack.alignment = .center
    dateAndDisclosureStack.translatesAutoresizingMaskIntoConstraints = false
    dateAndDisclosureStack.spacing = 8

    let spacer = UIView()
    spacer.translatesAutoresizingMaskIntoConstraints = false
    spacer.backgroundColor = .clear
    spacer.isAccessibilityElement = false

    let nameWithDateStack = UIStackView(arrangedSubviews: [
      nameAndUnreadStack,
      spacer,
      dateAndDisclosureStack,
    ])
    nameWithDateStack.alignment = .center
    nameWithDateStack.axis = .horizontal
    nameWithDateStack.translatesAutoresizingMaskIntoConstraints = false
    nameWithDateStack.spacing = 8

    let textStack = UIStackView(arrangedSubviews: [
      nameWithDateStack,
      messageLabel,
      seenLabel,
    ])
    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.translatesAutoresizingMaskIntoConstraints = false
    textStack.spacing = 8

    let avatarStack = UIStackView(arrangedSubviews: [
      avatar,
      textStack,
    ])
    avatarStack.alignment = .leading
    avatarStack.translatesAutoresizingMaskIntoConstraints = false
    avatarStack.spacing = 8
    avatarStack.axis = useVerticalLayout ? .vertical : .horizontal

    stackView = avatarStack

    addSubview(avatarStack)
    avatarStack.constrainToMarginsWithHighPriorityBottom()
  }

}
