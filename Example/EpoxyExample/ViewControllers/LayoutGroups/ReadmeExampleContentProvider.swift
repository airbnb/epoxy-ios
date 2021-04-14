// Created by Tyler Hedrick on 2/5/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCollectionView
import UIKit

struct ReadmeExamplesContentProvider: ContentProvider {

  // MARK: Internal

  var title: String { "Readme Examples" }

  var items: [ItemModeling] {
    [
      ActionButtonRow.itemModel(
        dataID: DataID.actionButtonRow,
        content: .init(
          title: "Title text",
          subtitle: "Subtitle text",
          actionText: "Perform action")),
      IconRow.itemModel(
        dataID: DataID.iconRow,
        content: .init(
          title: "This is an IconRow",
          icon: UIImage(systemName: "person.fill")!)),
    ]
  }

  // MARK: Private

  private enum DataID {
    case actionButtonRow
    case iconRow
  }

}
