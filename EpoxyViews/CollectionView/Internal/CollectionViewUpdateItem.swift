//  Created by Bryan Keller on 2/25/18.
//  Copyright © 2018 Airbnb. All rights reserved.

import UIKit

/// A type safe way to model collection view batch updates
enum CollectionViewUpdate<SectionModel, ItemModel> {

  case sectionReload(sectionIndex: Int, newSection: SectionModel)
  case itemReload(itemIndexPath: IndexPath, newItem: ItemModel)

  case sectionDelete(sectionIndex: Int)
  case itemDelete(itemIndexPath: IndexPath)

  case sectionInsert(sectionIndex: Int, newSection: SectionModel)
  case itemInsert(itemIndexPath: IndexPath, newItem: ItemModel)

  case sectionMove(initialSectionIndex: Int, finalSectionIndex: Int)
  case itemMove(initialItemIndexPath: IndexPath, finalItemIndexPath: IndexPath)

}
