// Created by Tyler Hedrick on 1/27/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCollectionView
import UIKit

class MessagesViewController: CollectionViewController {

  init() {
    super.init(layout: UICollectionViewCompositionalLayout.list)
    setItems(items, animated: false)
  }

  // MARK: Internal

  override var title: String? {
    get { "Message List (LayoutGroups)" }
    set { }
  }

  var items: [ItemModeling] {
    let sampleRows = [
      MessageRow.itemModel(
        dataID: DataID.sara,
        content: .init(
          name: "Sara Bareilles",
          date: "Jan 25, 2021",
          messagePreview: BeloIpsum.sentence(count: 5),
          seenText: "Seen"),
        style: .init(showUnread: true)),
      MessageRow.itemModel(
        dataID: DataID.beyonce,
        content: .init(
          name: "Beyoncé Knowles",
          date: "Jan 22, 2021",
          messagePreview: BeloIpsum.sentence(count: 2),
          seenText: "Unread"),
        style: .init(showUnread: false)),
      MessageRow.itemModel(
        dataID: DataID.taylor,
        content: .init(
          name: "Taylor Swift",
          date: "Dec 21, 2020",
          messagePreview: BeloIpsum.sentence(count: 1),
          seenText: "Seen"),
        style: .init(showUnread: false)),
    ]
    return Array(repeating: sampleRows, count: 100).flatMap { $0 }
  }

  // MARK: Private

  private enum DataID {
    case sara
    case beyonce
    case taylor
  }

}
