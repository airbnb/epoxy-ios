// Created by Tyler Hedrick on 1/22/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import EpoxyLayoutGroups
import UIKit

// MARK: - AlignableTextRow

final class AlignableTextRow: BaseRow, EpoxyableView {

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

  // MARK: EpoxyableView

  struct Style: Hashable, StyleIDProviding {
    let titleAlignment: VGroup.ItemAlignment
    var showLabelBackgrounds: Bool = false

    var styleID: AnyHashable? {
      "\(titleAlignment)\(showLabelBackgrounds)"
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(styleID)
    }
  }

  struct Content: Equatable {
    public init(title: String, subtitle: String? = nil) {
      self.title = title
      self.subtitle = subtitle
    }

    let title: String
    let subtitle: String?
  }

  private enum DataID {
    case title
    case subtitle
  }

  func setContent(_ content: Content, animated: Bool) {
    let showLabelBackgrounds = style.showLabelBackgrounds

    group.setItems {
      Label.groupItem(
        dataID: DataID.title,
        content: content.title,
        style: .style(with: .title2, showBackground: showLabelBackgrounds))
        .horizontalAlignment(style.titleAlignment)

      if let subtitle = content.subtitle {
        Label.groupItem(
          dataID: DataID.subtitle,
          content: subtitle,
          style: .style(with: .body, showBackground: showLabelBackgrounds))
      }
    }
  }

  // MARK: Private

  private let style: Style
  private lazy var group = VGroup(spacing: 8) { }

  private func setUp() {
    group.install(in: self)
    group.constrainToMarginsWithHighPriorityBottom()
  }

}

extension AlignableTextRow.Style {
  static var standard: AlignableTextRow.Style {
    .init(
      titleAlignment: .fill)
  }

  static var leadingTitle: AlignableTextRow.Style {
    AlignableTextRow.Style(
      titleAlignment: .leading)
      .withLabelBackgrounds()
  }

  static var centerTitle: AlignableTextRow.Style {
    AlignableTextRow.Style(
      titleAlignment: .center)
      .withLabelBackgrounds()
  }

  static var trailingTitle: AlignableTextRow.Style {
    AlignableTextRow.Style(
      titleAlignment: .trailing)
      .withLabelBackgrounds()
  }

  func withLabelBackgrounds() -> AlignableTextRow.Style {
    .init(
      titleAlignment: titleAlignment,
      showLabelBackgrounds: true)
  }

}
