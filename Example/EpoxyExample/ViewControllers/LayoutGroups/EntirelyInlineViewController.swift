// Created by Tyler Hedrick on 3/24/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCollectionView
import EpoxyLayoutGroups
import Foundation
import UIKit

/// This view controller shows how you can create entire components
/// inline using VGroupView and HGroupView inside of Epoxy
class EntirelyInlineViewController: CollectionViewController {

  // MARK: Lifecycle

  init() {
    super.init(layout: UICollectionViewCompositionalLayout.list)
    setItems(items, animated: false)
  }

  // MARK: Internal

  @ItemModelBuilder
  var items: [ItemModeling] {
    VGroupView.itemModel(
      dataID: RowDataID.textRow,
      content: .init {
        titleItem(title: BeloIpsum.sentence(count: 1))
        subtitleItem(subtitle: BeloIpsum.paragraph(count: 1))
      },
      style: .init(
        vGroupStyle: .init(spacing: 8),
        edgeInsets: .init(top: 16, leading: 24, bottom: 16, trailing: 24)))
    HGroupView.itemModel(
      dataID: RowDataID.imageRow,
      content: .init {
        IconView.groupItem(
          dataID: GroupDataID.image,
          content: UIImage(systemName: "folder"),
          style: .init(size: .init(width: 32, height: 32), tintColor: .systemGreen))
          .verticalAlignment(.top)
        VGroupItem(
          dataID: GroupDataID.verticalGroup,
          style: .init(spacing: 8))
        {
          titleItem(title: BeloIpsum.sentence(count: 1))
          subtitleItem(subtitle: BeloIpsum.paragraph(count: 1))
        }
      },
      style: .init(
        hGroupStyle: .init(spacing: 16),
        edgeInsets: .init(top: 16, leading: 24, bottom: 16, trailing: 24)))
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
