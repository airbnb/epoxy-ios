// Created by Tyler Hedrick on 1/27/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCollectionView
import Foundation

struct MessagesContentProvider: ContentProvider {

  var title: String { "Message List (LayoutGroups)" }

  private enum DataID {
    case sara
    case beyonce
    case taylor
  }

  var items: [ItemModeling] {
    let sampleRows = [
      MessageRow.itemModel(
        dataID: DataID.sara,
        content: .init(
          name: "Sara Bareilles",
          date: "Jan 25, 2021",
          messagePreview: "Sed posuere consectetur est at lobortis. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Donec ullamcorper nulla non metus auctor fringilla. Aenean lacinia bibendum nulla sed consectetur. Nullam quis risus eget urna mollis ornare vel eu leo. Cras mattis consectetur purus sit amet fermentum.",
          seenText: "Seen"),
        style: .init(showUnread: true)),
      MessageRow.itemModel(
        dataID: DataID.beyonce,
        content: .init(
          name: "Beyoncé Knowles",
          date: "Jan 22, 2021",
          messagePreview: "Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Nulla vitae elit libero, a pharetra augue. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Donec id elit non mi porta gravida at eget metus. Praesent commodo cursus magna, vel scelerisque nisl consectetur et.",
          seenText: "Unread"),
        style: .init(showUnread: false)),
      MessageRow.itemModel(
        dataID: DataID.taylor,
        content: .init(
          name: "Taylor Swift",
          date: "Dec 21, 2020",
          messagePreview: "Donec id elit non mi porta gravida at eget metus.",
          seenText: "Seen"),
        style: .init(showUnread: false)),
    ]
    return sampleRows.duplicate(100)
  }
}
