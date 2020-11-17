//  Created by Laura Skelton on 5/19/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import Foundation

public final class InternalCollectionViewEpoxyData: InternalEpoxyDataType {
  init(
    sections: [InternalEpoxySection],
    sectionIndexMap: [AnyHashable: Int],
    itemIndexMap: [AnyHashable: IndexPath],
    epoxyLogger: EpoxyLogging)
  {
    self.sections = sections
    self.sectionIndexMap = sectionIndexMap
    self.itemIndexMap = itemIndexMap
    self.epoxyLogger = epoxyLogger
  }

  public fileprivate(set) var sections: [InternalEpoxySection]

  // MARK: Fileprivate

  fileprivate var sectionIndexMap = [AnyHashable: Int]()
  fileprivate var itemIndexMap = [AnyHashable: IndexPath]()
  fileprivate let epoxyLogger: EpoxyLogging
}

extension InternalCollectionViewEpoxyData {

  public static func make(
    with sections: [EpoxySection],
    epoxyLogger: EpoxyLogging)
    -> InternalCollectionViewEpoxyData
  {
    var sectionIndexMap = [AnyHashable: Int]()
    var itemIndexMap = [AnyHashable: IndexPath]()

    var convertedSections = [InternalEpoxySection]()
    sections.enumerated().forEach { sectionIndex, section in
      sectionIndexMap[section.dataID] = sectionIndex
      var epoxyModelWrappers = [EpoxyModelWrapper]()
      section.items.enumerated().forEach { itemIndex, item in
        itemIndexMap[item.dataID] = IndexPath(item: itemIndex, section: sectionIndex)
        epoxyModelWrappers.append(EpoxyModelWrapper(epoxyModel: item))
      }
      convertedSections.append(InternalEpoxySection(
        dataID: section.dataID,
        items: epoxyModelWrappers,
        userInfo: section.userInfo))
    }

    return InternalCollectionViewEpoxyData(
      sections: convertedSections,
      sectionIndexMap: sectionIndexMap,
      itemIndexMap: itemIndexMap,
      epoxyLogger: epoxyLogger)
  }

  public func makeChangeset(from
    otherData: InternalCollectionViewEpoxyData) -> EpoxyChangeset
  {
    let sectionChangeset = sections.makeIndexSetChangeset(from: otherData.sections)

    var itemChangesetsForSections = [IndexPathChangeset]()
    for i in 0..<otherData.sections.count {
      if let newSectionIndex = sectionChangeset.newIndices[i]! {

        let fromSection = i
        let toSection = newSectionIndex

        let fromArray = otherData.sections[fromSection].items
        let toArray = sections[toSection].items

        let itemIndexChangeset = toArray.makeIndexPathChangeset(
          from: fromArray,
          fromSection: fromSection,
          toSection: toSection)

        itemChangesetsForSections.append(itemIndexChangeset)
      }
    }

    let itemChangeset: IndexPathChangeset = itemChangesetsForSections.reduce(IndexPathChangeset(), +)

    return EpoxyChangeset(
      sectionChangeset: sectionChangeset,
      itemChangeset: itemChangeset)
  }

  public func updateItem(at dataID: AnyHashable, with item: EpoxyableModel) -> IndexPath? {
    guard let indexPath = itemIndexMap[dataID] else {
      epoxyLogger.epoxyAssert(false, "No item with that dataID exists")
      return nil
    }

    let oldItem = sections[indexPath.section].items[indexPath.item]

    epoxyLogger.epoxyAssert(oldItem.reuseID == item.reuseID, "Cannot update item with a different reuse ID.")

    sections[indexPath.section].items[indexPath.item] = EpoxyModelWrapper(
      epoxyModel: item)

    return indexPath
  }

  public func indexPathForItem(at dataID: AnyHashable) -> IndexPath? {
    return itemIndexMap[dataID]
  }

  public func indexForSection(at dataID: AnyHashable) -> Int? {
    return sectionIndexMap[dataID]
  }
}

extension InternalCollectionViewEpoxyData: CustomStringConvertible {
  public var description: String {
    return "Data: (Sections: [\(sections)]"
  }
}
