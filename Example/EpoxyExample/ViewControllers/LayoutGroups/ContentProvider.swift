// Created by Tyler Hedrick on 1/25/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCollectionView
import UIKit

protocol ContentProvider {
  var items: [ItemModeling] { get }
  var title: String { get }
}

extension CollectionViewController {
  convenience init(contentProvider: ContentProvider) {
    self.init(
      layout: UICollectionViewCompositionalLayout.list,
      items: contentProvider.items)
    self.title = contentProvider.title
  }
}
