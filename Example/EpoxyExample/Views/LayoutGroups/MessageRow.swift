// Created by Tyler Hedrick on 1/27/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import EpoxyLayoutGroups
import UIKit

final class MessageRow: BaseRow, EpoxyableView {

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

  struct Style: Hashable, StyleIDProviding {
    let showUnread: Bool

    var styleID: AnyHashable? {
      "\(showUnread)"
    }
  }

  struct Content: Equatable {
    let name: String
    let date: String
    let messagePreview: String
    let seenText: String
  }

  enum DataID {
    case avatar
    case name
    case date
    case unread
    case disclosureArrow
    case message
    case seen
    case contentGroup
    case nameGroup
    case disclosureGroup
    case topContainer
    case topSpacer
  }

  func setContent(_ content: Content, animated: Bool) {
    group.setItems {
      ImageView.groupItem(
        dataID: DataID.avatar,
        content: UIImage(systemName: "person.crop.circle"),
        style: .init(
          size: .init(width: 48, height: 48),
          tintColor: .black))
        .set(\ImageView.layer.cornerRadius, value: 24)
      VGroupItem(
        dataID: DataID.contentGroup,
        style: .init(spacing: 8))
      {
        HGroupItem(
          dataID: DataID.topContainer,
          style: .init(alignment: .center, spacing: 8))
        {
          HGroupItem(
            dataID: DataID.nameGroup,
            style: .init(alignment: .center, spacing: 8))
          {
            Label.groupItem(
              dataID: DataID.name,
              content: content.name,
              style: .style(with: .title3))
              .numberOfLines(1)
            if style.showUnread {
              ColorView.groupItem(
                dataID: DataID.unread,
                style: .init(size: .init(width: 8, height: 8), color: .systemBlue))
                .set(\ColorView.layer.cornerRadius, value: 4)
            }
          }
          .reflowsForAccessibilityTypeSizes(false)

          SpacerItem(dataID: DataID.topSpacer)

          HGroupItem(
            dataID: DataID.disclosureGroup,
            style: .init(alignment: .center, spacing: 8))
          {
            Label.groupItem(
              dataID: DataID.date,
              content: content.date,
              style: .style(with: .subheadline))
              .contentCompressionResistancePriority(.required, for: .horizontal)
            ImageView.groupItem(
              dataID: DataID.disclosureArrow,
              content: UIImage(systemName: "chevron.right"),
              style: .init(
                size: .init(width: 12, height: 16),
                tintColor: .black))
              .contentMode(.center)
              .contentCompressionResistancePriority(.required, for: .horizontal)
          }
          .reflowsForAccessibilityTypeSizes(false)
        }

        Label.groupItem(
          dataID: DataID.message,
          content: content.messagePreview,
          style: .style(with: .body))
          .numberOfLines(3)
        Label.groupItem(
          dataID: DataID.seen,
          content: content.seenText,
          style: .style(with: .footnote))
      }
    }
  }

  // MARK: Private

  private let style: Style
  private let group = HGroup(alignment: .top, spacing: 8)

  private func setUp() {
    group.install(in: self)
    group.constrainToMarginsWithHighPriorityBottom()
  }

}
