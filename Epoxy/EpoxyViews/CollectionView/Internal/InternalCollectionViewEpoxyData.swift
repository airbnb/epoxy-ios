//  Created by Laura Skelton on 5/19/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation

public final class InternalCollectionViewEpoxyData: InternalEpoxyDataType {

  public typealias Item = EpoxyModelWrapper
  public typealias ExternalSection = EpoxyCollectionViewSection
  public typealias InternalSection = EpoxyCollectionViewSection

  init(
    sections: [EpoxyCollectionViewSection],
    sectionIndexMap: [String: Int],
    itemIndexMap: [String: IndexPath])
  {
    self.sections = sections
    self.sectionIndexMap = sectionIndexMap
    self.itemIndexMap = itemIndexMap
  }

  public fileprivate(set) var sections: [EpoxyCollectionViewSection]

  // MARK: Fileprivate

  fileprivate var sectionIndexMap = [String: Int]()
  fileprivate var itemIndexMap = [String: IndexPath]()
}

extension InternalCollectionViewEpoxyData {

  public static func make(with sections: [EpoxyCollectionViewSection]) -> InternalCollectionViewEpoxyData {

    var sectionIndexMap = [String: Int]()
    var itemIndexMap = [String: IndexPath]()

    sections.enumerated().forEach { sectionIndex, section in
      sectionIndexMap[section.dataID] = sectionIndex
      section.items.enumerated().forEach { itemIndex, item in
        itemIndexMap[item.dataID] = IndexPath(item: itemIndex, section: sectionIndex)
      }
    }

    return InternalCollectionViewEpoxyData(
      sections: sections,
      sectionIndexMap: sectionIndexMap,
      itemIndexMap: itemIndexMap)
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

  public func updateItem(at dataID: String, with item: EpoxyableModel) -> IndexPath? {
    guard let indexPath = itemIndexMap[dataID] else {
      assert(false, "No item with that dataID exists")
      return nil
    }

    let oldItem = sections[indexPath.section].items[indexPath.item]

    assert(oldItem.reuseID == item.reuseID, "Cannot update item with a different reuse ID.")

    sections[indexPath.section].items[indexPath.item] = EpoxyModelWrapper(
      epoxyModel: item)

    return indexPath
  }

  public func indexPathForItem(at dataID: String) -> IndexPath? {
    return itemIndexMap[dataID]
  }
}

extension InternalCollectionViewEpoxyData: CustomStringConvertible {
  public var description: String {
    return "Data: (Sections: [\(sections)]"
  }
}
