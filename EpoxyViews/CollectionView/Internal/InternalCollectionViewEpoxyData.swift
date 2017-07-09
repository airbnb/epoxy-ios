//  Created by Laura Skelton on 5/19/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation

public final class InternalCollectionViewEpoxyData: DiffableInternalEpoxyDataType {

  public typealias Changeset = EpoxyChangeset
  public typealias Item = InternalCollectionViewEpoxyItem

  init(
    sections: [InternalCollectionViewEpoxySection],
    sectionIndexMap: [String: Int],
    itemIndexMap: [String: IndexPath])
  {
    self.sections = sections
    self.sectionIndexMap = sectionIndexMap
    self.itemIndexMap = itemIndexMap
  }

  var sections: [InternalCollectionViewEpoxySection]

  // MARK: Fileprivate

  fileprivate var sectionIndexMap = [String: Int]()
  fileprivate var itemIndexMap = [String: IndexPath]()
}

extension InternalCollectionViewEpoxyData {

  public static func make(with sections: [EpoxySection]) -> InternalCollectionViewEpoxyData {

    var sectionIndexMap = [String: Int]()
    var itemIndexMap = [String: IndexPath]()

    let sections: [InternalCollectionViewEpoxySection] = sections.enumerated().map { sectionIndex, section in

      sectionIndexMap[section.dataID] = sectionIndex

      var itemIndex = 0

      var items = [InternalCollectionViewEpoxyItem]()

      if let existingSectionHeader = section.sectionHeader {
        items.append(InternalCollectionViewEpoxyItem(
          epoxyItem: existingSectionHeader))

        if let dataID = existingSectionHeader.dataID {
          itemIndexMap[dataID] = IndexPath(item: itemIndex, section: sectionIndex)
        }

        itemIndex += 1
      }

      section.items.forEach { item in
        items.append(InternalCollectionViewEpoxyItem(
          epoxyItem: item))

        if let dataID = item.dataID {
          itemIndexMap[dataID] = IndexPath(item: itemIndex, section: sectionIndex)
        }

        itemIndex += 1
      }

      return InternalCollectionViewEpoxySection(
        dataID: section.dataID,
        items: items)
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

    assert(oldItem.epoxyItem.reuseID == item.reuseID, "Cannot update item with a different reuse ID.")

    sections[indexPath.section].items[indexPath.item] = InternalCollectionViewEpoxyItem(
      epoxyItem: item)

    return indexPath
  }

}

extension InternalCollectionViewEpoxyData: CustomStringConvertible {
  public var description: String {
    return "Data: (Sections: [\(sections)]"
  }
}

// MARK: InternalCollectionViewEpoxySection

/// A section in the `InternalCollectionViewEpoxyData`.
public struct InternalCollectionViewEpoxySection {

  init(
    dataID: String,
    items: [InternalCollectionViewEpoxyItem])
  {
    self.dataID = dataID
    self.items = items
  }

  let dataID: String
  var items: [InternalCollectionViewEpoxyItem]
}

extension InternalCollectionViewEpoxySection: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableSection = otherDiffableItem as? InternalCollectionViewEpoxySection else { return false }
    return dataID == otherDiffableSection.dataID
  }

  public var diffIdentifier: String? {
    return dataID
  }
}

extension InternalCollectionViewEpoxySection: CustomStringConvertible {
  public var description: String {
    return "Section: (dataID: \(dataID), items: \(items.count))"
  }
}

// MARK: InternalCollectionViewEpoxyItem

/// An item in a `InternalCollectionViewEpoxySection`, representing either a row or a section header.
public struct InternalCollectionViewEpoxyItem {

  init(
    epoxyItem: EpoxyableModel)
  {
    self.epoxyItem = epoxyItem
  }

  let epoxyItem: EpoxyableModel
}

extension InternalCollectionViewEpoxyItem: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableEpoxyItem = otherDiffableItem as? InternalCollectionViewEpoxyItem else { return false }
    return epoxyItem.isDiffableItemEqual(to: otherDiffableEpoxyItem.epoxyItem)
  }

  public var diffIdentifier: String? {
    return epoxyItem.diffIdentifier
  }
}
