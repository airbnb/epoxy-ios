// Created by Tyler Hedrick on 1/26/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCollectionView
import Foundation

struct TextRowExampleContentProvider: ContentProvider {

  // MARK: Internal

  var title: String { "Label alignment" }

  var items: [ItemModeling] {
    [
      AlignableTextRow.itemModel(
        dataID: DataID.leading,
        content: .init(title: "Title Text", subtitle: "The title in this row uses .horizontalAlignment(.leading)"),
        style: .leadingTitle),
      AlignableTextRow.itemModel(
        dataID: DataID.center,
        content: .init(title: "Title Text", subtitle: "The title in this row uses .horizontalAlignment(.center)"),
        style: .centerTitle),
      AlignableTextRow.itemModel(
        dataID: DataID.trailing,
        content: .init(title: "Title Text", subtitle: "The title in this row uses .horizontalAlignment(.trailing)"),
        style: .trailingTitle),
    ]
  }

  // MARK: Private

  private enum DataID {
    case leading
    case center
    case trailing
  }

}
