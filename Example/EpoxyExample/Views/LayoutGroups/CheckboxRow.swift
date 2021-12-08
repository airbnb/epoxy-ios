// Created by Tyler Hedrick on 1/28/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import EpoxyLayoutGroups
import UIKit

final class CheckboxRow: BaseRow, EpoxyableView {

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
    let isChecked: Bool
  }

  enum DataID {
    case checkbox
    case verticalGroup
    case title
    case subtitle
  }

  func setContent(_ content: Content, animated _: Bool) {
    group.setItems {
      IconView.groupItem(
        dataID: DataID.checkbox,
        content: UIImage(systemName: content.isChecked ? "checkmark.square.fill" : "checkmark.square"),
        style: .init(
          size: .init(width: 24, height: 24),
          tintColor: content.isChecked ? .systemGreen : .systemGray))
      VGroupItem(
        dataID: DataID.verticalGroup,
        style: .init(spacing: 4))
      {
        Label.groupItem(
          dataID: DataID.title,
          content: content.title,
          style: .style(with: .title2))
        Label.groupItem(
          dataID: DataID.subtitle,
          content: content.subtitle,
          style: .style(with: .body))
      }
    }
  }

  // MARK: Private

  private let group = HGroup(alignment: .top, spacing: 8)

  private func setUp() {
    group.install(in: self)
    group.constrainToMarginsWithHighPriorityBottom()
  }

}
