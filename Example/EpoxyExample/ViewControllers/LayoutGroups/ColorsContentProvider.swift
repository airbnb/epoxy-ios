// Created by Tyler Hedrick on 1/27/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCollectionView
import Foundation

struct ColorsContentProvider: ContentProvider {

  var title: String { "Static sized squares" }

  enum DataID {
    case hGroupFill
    case hGroupTop
    case hGroupCenter
    case hGroupBottom
    case vGroupFill
    case vGroupLeading
    case vGroupCenter
    case vGroupTrailing
  }
  
  var items: [ItemModeling] {
    [
      ColorsRow.itemModel(dataID: DataID.hGroupFill, style: .init(variant: .hGroup(.fill))),
      ColorsRow.itemModel(dataID: DataID.hGroupTop, style: .init(variant: .hGroup(.top))),
      ColorsRow.itemModel(dataID: DataID.hGroupCenter, style: .init(variant: .hGroup(.center))),
      ColorsRow.itemModel(dataID: DataID.hGroupBottom, style: .init(variant: .hGroup(.bottom))),
      ColorsRow.itemModel(dataID: DataID.vGroupFill, style: .init(variant: .vGroup(.fill))),
      ColorsRow.itemModel(dataID: DataID.vGroupLeading, style: .init(variant: .vGroup(.leading))),
      ColorsRow.itemModel(dataID: DataID.vGroupCenter, style: .init(variant: .vGroup(.center))),
      ColorsRow.itemModel(dataID: DataID.vGroupTrailing, style: .init(variant: .vGroup(.trailing))),
    ]
  }
}
