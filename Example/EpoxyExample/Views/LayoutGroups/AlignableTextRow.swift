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

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  // MARK: EpoxyableView

  struct Style: Hashable {
    var titleAlignment: VGroup.ItemAlignment = .leading
    var showLabelBackgrounds = false
  }

  struct Content: Equatable {
    let title: String
    let subtitle: String?
  }

  func setContent(_ content: Content, animated _: Bool) {
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

  private enum DataID {
    case title
    case subtitle
  }

  private let style: Style
  private lazy var group = VGroup(spacing: 8) { }

  private func setUp() {
    group.install(in: self)
    group.constrainToMarginsWithHighPriorityBottom()
  }

}

extension AlignableTextRow.Style {
  static var standard: AlignableTextRow.Style {
    .init()
  }

  static var leadingTitle: AlignableTextRow.Style {
    var style = standard
    style.showLabelBackgrounds = true
    return style
  }

  static var centerTitle: AlignableTextRow.Style {
    var style = standard
    style.titleAlignment = .center
    style.showLabelBackgrounds = true
    return style
  }

  static var trailingTitle: AlignableTextRow.Style {
    var style = standard
    style.titleAlignment = .trailing
    style.showLabelBackgrounds = true
    return style
  }
}
