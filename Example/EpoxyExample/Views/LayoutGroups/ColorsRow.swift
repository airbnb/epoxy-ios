// Created by Tyler Hedrick on 1/27/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import EpoxyLayoutGroups
import UIKit

final class ColorsRow: BaseRow, EpoxyableView {

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

  struct Style: Hashable {
    enum Variant: Equatable, Hashable {
      case hGroup(_ alignment: HGroup.ItemAlignment)
      case vGroup(_ alignment: VGroup.ItemAlignment)
    }

    var variant: Variant
  }

  // MARK: Private

  private let style: Style

  private var currentTitle: String {
    switch style.variant {
    case .hGroup(let alignment):
      return "HGroup \(alignment)"
    case .vGroup(let alignment):
      return "VGroup \(alignment)"
    }
  }

  private enum DataID {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple

    case hGroup
    case vGroup

    case title
  }

  private func setUp() {
    // we set the outer group alignment to `.fill` for `VGroup` to show that the
    // contents of the inner VGroup will stretch when used outside of another `VGroup`
    // we set the outer group alignment to `.leading` for `HGroup` so that we
    // don't stretch any of the subviews of the inner `HGroup`
    let group: GroupItemModeling
    let outerGroupAlignment: VGroup.ItemAlignment
    switch style.variant {
    case .hGroup(let alignment):
      group = HGroupItem(
        dataID: DataID.hGroup,
        style: .init(alignment: alignment, spacing: 8))
      {
        ColorView.groupItem(
          dataID: DataID.red,
          style: .init(size: .init(width: 30, height: 30), color: .systemRed))
        ColorView.groupItem(
          dataID: DataID.orange,
          style: .init(size: .init(width: 50, height: 50), color: .systemOrange))
        ColorView.groupItem(
          dataID: DataID.yellow,
          style: .init(size: .init(width: 70, height: 70), color: .systemYellow))
      }
      outerGroupAlignment = .leading
    case .vGroup(let alignment):
      group = VGroupItem(
        dataID: DataID.vGroup,
        style: .init(alignment: alignment, spacing: 8))
      {
        ColorView.groupItem(
          dataID: DataID.green,
          style: .init(size: .init(width: 30, height: 30), color: .systemGreen))
        ColorView.groupItem(
          dataID: DataID.blue,
          style: .init(size: .init(width: 50, height: 50), color: .systemBlue))
        ColorView.groupItem(
          dataID: DataID.purple,
          style: .init(size: .init(width: 70, height: 70), color: .systemPurple))
      }
      outerGroupAlignment = .fill
    }

    let outerGroup = VGroup(alignment: outerGroupAlignment) {
      Label.groupItem(
        dataID: DataID.title,
        content: currentTitle,
        style: .style(with: .title2))
      group
    }
    outerGroup.install(in: self)
    outerGroup.constrainToMarginsWithHighPriorityBottom()
  }

}
