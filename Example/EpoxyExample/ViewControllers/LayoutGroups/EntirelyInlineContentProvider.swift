// Created by Tyler Hedrick on 3/24/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCollectionView
import EpoxyLayoutGroups
import Foundation
import UIKit

/// This content provider shows how you can create entire components
/// inline using VGroupView and HGroupView inside of Epoxy
struct EntirelyInlineContentProvider: ContentProvider {

  // MARK: Internal

  var title: String { "Entirely Inline" }

  var items: [ItemModeling] {
    [
      VGroupView.itemModel(
        dataID: RowDataID.textRow,
        content: .init {
          titleItem(title: "Here is a title of an inline row")
          subtitleItem(subtitle: "Cras mattis consectetur purus sit amet fermentum. Etiam porta sem malesuada magna mollis euismod. Vestibulum id ligula porta felis euismod semper. Donec ullamcorper nulla non metus auctor fringilla. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit.")
        },
        style: .init(
          vGroupStyle: .init(spacing: 8),
          layoutMargins: .init(top: 16, left: 24, bottom: 16, right: 24))),
      HGroupView.itemModel(
        dataID: RowDataID.imageRow,
        content: .init {
          ImageView.groupItem(
            dataID: GroupDataID.image,
            content: UIImage(systemName: "folder"),
            style: .init(size: .init(width: 32, height: 32), tintColor: .systemGreen))
            .verticalAlignment(.top)
          VGroupItem(
            dataID: GroupDataID.verticalGroup,
            style: .init(spacing: 8))
          {
            titleItem(title: "Risus Elit Fringilla Vestibulum")
            subtitleItem(subtitle: "Sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec ullamcorper nulla non metus auctor fringilla. Cras mattis consectetur purus sit amet fermentum.")
          }
        },
        style: .init(
          hGroupStyle: .init(spacing: 16),
          layoutMargins: .init(top: 16, left: 24, bottom: 16, right: 24))),
    ]
  }

  // MARK: Private

  private enum RowDataID {
    case textRow
    case imageRow
  }

  private enum GroupDataID {
    case title
    case subtitle
    case image
    case verticalGroup
  }

  private func titleItem(title: String) -> GroupItemModeling {
    Label.groupItem(
      dataID: GroupDataID.title,
      content: title,
      style: .style(with: .title2))
  }

  private func subtitleItem(subtitle: String) -> GroupItemModeling {
    Label.groupItem(
      dataID: GroupDataID.subtitle,
      content: subtitle,
      style: .style(with: .body))
  }

}
