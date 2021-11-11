// Created by Tyler Hedrick on 11/11/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class DynamicRow: BaseRow, EpoxyableView {

  // MARK: Lifecycle

  override init() {
    super.init()
    layout.install(in: self)
    layout.constrainToMarginsWithHighPriorityBottom()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  // MARK: ContentConfigurableView

  struct Content: Equatable {
    let title: String
    let subtitle: String
    let revealOptionsButton: String?
    let options: [String]?
    let footer: String
  }

  // MARK: BehaviorsConfigurableView

  struct Behaviors {
    let didTapRevealOptions: (() -> Void)?
    let didTapOption: ((String) -> Void)?
  }

  func setContent(_ content: Content, animated: Bool) {
    var items: [GroupItemModeling] = [
      Label.groupItem(
        dataID: DataID.title,
        content: content.title,
        style: Label.Style.style(with: .title2))
        // force text to hug tightly to avoid height changes during animation
        .contentHuggingPriority(.required, for: .vertical),
      Label.groupItem(
        dataID: DataID.subtitle,
        content: content.subtitle,
        style: Label.Style.style(with: .body))
        // force text to hug tightly to avoid height changes during animation
        .contentHuggingPriority(.required, for: .vertical),
    ]

    if let revealOptionsText = content.revealOptionsButton {
      items.append(
        Button.groupItem(
          dataID: DataID.revealOptions,
          content: .init(title: revealOptionsText),
          behaviors: .init { [weak self] _ in
            self?.didTapRevealOptions?()
          },
          style: .init()))
    } else if let options = content.options {
      for option in options {
        items.append(
          Button.groupItem(
            dataID: option,
            content: .init(title: option),
            behaviors: .init { [weak self] _ in
              self?.didTapOption?(option)
            },
            style: .init()))
      }
    }

    items.append(
      Label.groupItem(
        dataID: DataID.footer,
        content: content.footer,
        style: .style(with: .footnote)))

    layout.setItems(items, animated: animated)
  }

  func setBehaviors(_ behaviors: Behaviors?) {
    didTapRevealOptions = behaviors?.didTapRevealOptions
    didTapOption = behaviors?.didTapOption
  }

  // MARK: Private

  private enum DataID {
    case title
    case subtitle
    case revealOptions
    case footer
  }

  private let layout = VGroup()
  private var didTapRevealOptions: (() -> Void)? = nil
  private var didTapOption: ((String) -> Void)? = nil

}
