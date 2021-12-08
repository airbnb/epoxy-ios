// Created by Tyler Hedrick on 2/5/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import EpoxyLayoutGroups
import UIKit

final class ActionButtonRow: BaseRow, EpoxyableView {

  // MARK: Lifecycle

  override init() {
    super.init()
    setUp()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  struct Content: Equatable {
    let title: String
    let subtitle: String
    let actionText: String
  }

  enum DataID {
    case title
    case subtitle
    case action
  }

  func setContent(_ content: Content, animated _: Bool) {
    group.setItems {
      Label.groupItem(
        dataID: DataID.title,
        content: content.title,
        style: .style(with: .title2))
      Label.groupItem(
        dataID: DataID.subtitle,
        content: content.subtitle,
        style: .style(with: .body))
      Button.groupItem(
        dataID: DataID.action,
        content: .init(title: content.actionText),
        behaviors: .init { button in
          print("Tapped the button \(button)")
        },
        style: .init())
    }
  }

  // MARK: Private

  private let group = VGroup(alignment: .leading, spacing: 8)

  private func setUp() {
    group.install(in: self)
    group.constrainToMarginsWithHighPriorityBottom()
  }

}
