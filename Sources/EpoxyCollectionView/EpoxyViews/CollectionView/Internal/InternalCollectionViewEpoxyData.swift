//  Created by Laura Skelton on 5/19/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import Foundation

// MARK: - InternalCollectionViewEpoxyData

struct InternalCollectionViewEpoxyData {

  // MARK: Lifecycle

  private init(
    sections: [SectionModel],
    sectionIndexMap: SectionIndexMap,
    itemIndexMap: ItemIndexMap)
  {
    self.sections = sections
    self.sectionIndexMap = sectionIndexMap
    self.itemIndexMap = itemIndexMap
  }

  // MARK: Internal

  let sections: [SectionModel]

  static func make(sections: [SectionModel]) -> Self {
    var sectionIndexMap = SectionIndexMap()
    var itemIndexMap = ItemIndexMap()

    for sectionIndex in sections.indices {
      let section = sections[sectionIndex]
      let sectionDataID = section.dataID
      sectionIndexMap[sectionDataID, default: .init()].insert(sectionIndex)

      let sectionItems = section.items
      for itemIndex in sectionItems.indices {
        let item = sectionItems[itemIndex]
        let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
        itemIndexMap[item.dataID, default: [:]][sectionDataID, default: []].append(indexPath)
      }
    }

    return .init(sections: sections, sectionIndexMap: sectionIndexMap, itemIndexMap: itemIndexMap)
  }

  func makeChangeset(from otherData: Self) -> CollectionViewChangeset {
    let section = sections.makeSectionedChangeset(from: otherData.sections)

    let supplementaryItem = supplementaryItemChangeset(
      from: otherData,
      sectionChangeset: section.sectionChangeset)

    let changeset = CollectionViewChangeset(
      sectionChangeset: section.sectionChangeset,
      itemChangeset: section.itemChangeset,
      supplementaryItemChangeset: supplementaryItem)

    warnOnDuplicates(in: changeset)

    return changeset
  }

  /// Returns the erased item model at the given index path, asserting if it does not exist.
  func item(at indexPath: IndexPath) -> AnyItemModel? {
    guard indexPath.section < sections.count else {
      return nil
    }

    let section = sections[indexPath.section]

    guard indexPath.row < section.items.count else {
      EpoxyLogger.shared.assertionFailure(
        """
        Item index \(indexPath.section) is out of bounds \(section.items.count). Make sure your \
        section models and item models all have unique dataIDs.
        """)
      return nil
    }

    return section.items[indexPath.row].eraseToAnyItemModel()
  }

  /// Returns the erased item model at the given index path, otherwise `nil` if it does not exist.
  func itemIfPresent(at indexPath: IndexPath) -> AnyItemModel? {
    guard indexPath.section < sections.count else { return nil }

    let section = sections[indexPath.section]
    guard indexPath.row < section.items.count else { return nil }

    return section.items[indexPath.row].eraseToAnyItemModel()
  }

  /// Returns the section model at the given index, asserting if it does not exist.
  func section(at index: Int) -> SectionModel? {
    guard index < sections.count else {
      EpoxyLogger.shared.assertionFailure(
        """
        Section index \(index) is out of bounds \(sections.count). Make sure your section models \
        and item models all have unique dataIDs.
        """)
      return nil
    }

    return sections[index]
  }

  /// Returns the section model at the given index, otherwise `nil` if it does not exist.
  func sectionIfPresent(at index: Int) -> SectionModel? {
    guard index < sections.count else { return nil }

    return sections[index]
  }

  /// Returns the supplementary item model of the provided kind at the given index, otherwise `nil`
  /// if it does not exist.
  func supplementaryItemIfPresent(
    ofKind elementKind: String,
    at indexPath: IndexPath)
    -> AnySupplementaryItemModel?
  {
    guard indexPath.section < sections.count else { return nil }

    let section = sections[indexPath.section]

    guard let models = section.supplementaryItems[elementKind] else { return nil }
    guard indexPath.item < models.count else { return nil }

    return models[indexPath.item].eraseToAnySupplementaryItemModel()
  }

  /// Returns the supplementary item model of the provided kind at the given index, asserting if it
  /// does not exist.
  func supplementaryItem(
    ofKind elementKind: String,
    at indexPath: IndexPath)
    -> AnySupplementaryItemModel?
  {
    guard indexPath.section < sections.count else {
      EpoxyLogger.shared.assertionFailure("Index of supplementary view is out of bounds.")
      return nil
    }

    let section = sections[indexPath.section]

    guard let model = section.supplementaryItems[elementKind]?[indexPath.item] else {
      EpoxyLogger.shared.assertionFailure(
        """
        Supplementary item model not found for the given element kind \(elementKind) and index \
        path \(indexPath).
        """)
      return nil
    }

    return model.eraseToAnySupplementaryItemModel()
  }

  /// Returns the `IndexPath` corresponding to the given `ItemPath`, logging a warning if the
  /// `ItemPath` corresponds to multiple items due to duplicate data IDs.
  func indexPathForItem(at path: ItemPath) -> IndexPath? {
    guard let itemIndexMapBySectionID = itemIndexMap[path.itemDataID] else {
      return nil
    }

    func lastIndexPath(in indexPaths: [IndexPath], sectionID: AnyHashable) -> IndexPath? {
      if indexPaths.count > 1 {
        EpoxyLogger.shared.warn({
          // `sectionIndexMap` is constructed from the same data as `itemIndexMap` so we can force
          // unwrap.
          let sectionIndex = sectionIndexMap[sectionID]!

          return """
          Warning! Attempted to locate item \(path.itemDataID) in section \(sectionID) at indexes \
          \(sectionIndex.map { $0 }) when there are multiple items with that ID at the indexes \
          \(indexPaths.map { $0.item }). Choosing the last index. Items should have unique data \
          IDs within a section as duplicate data IDs cause undefined behavior.
          """
        }())
      }

      return indexPaths.last
    }

    switch path.section {
    case .dataID(let sectionID):
      if let indexPaths = itemIndexMapBySectionID[sectionID] {
        // If the section ID is specified, just look up the indexes for that section.
        return lastIndexPath(in: indexPaths, sectionID: sectionID)
      }
      return nil

    case .lastWithItemDataID:
      // If the section ID is unspecified but there's only one section with this data ID:
      if itemIndexMapBySectionID.count == 1, let idAndIndexes = itemIndexMapBySectionID.first {
        return lastIndexPath(in: idAndIndexes.value, sectionID: idAndIndexes.key)
      }

      // Otherwise there's multiple sections with the same data ID so we pick the last section so
      // that it's stable.
      let lastSectionID = itemIndexMapBySectionID.max(by: { first, second in
        // `sectionIndexMap` is constructed from the same data as `itemIndexMap` so we can safely
        // force unwrap.
        sectionIndexMap[first.key]!.last! < sectionIndexMap[second.key]!.last!
      })

      if let sectionID = lastSectionID {
        EpoxyLogger.shared.warn({
          return """
          Warning! Attempted to locate item \(path.itemDataID) when there are multiple sections that \
          contain it each with IDs \(itemIndexMapBySectionID.keys) at the indexes \
          \(itemIndexMapBySectionID.keys.map { sectionIndexMap[$0] }). Choosing the last section \
          \(sectionID.key). To fix this warning specify the desired section data ID when \
          constructing your `ItemPath`.
          """
        }())

        return lastIndexPath(in: sectionID.value, sectionID: sectionID.key)
      }

      return nil
    }
  }

  /// Returns the `Int` index corresponding to the given section `dataID`, logging a warning if the
  /// index corresponds to multiple items due to duplicate data IDs.
  func indexForSection(at dataID: AnyHashable) -> Int? {
    guard let indexes = sectionIndexMap[dataID] else {
      return nil
    }

    if indexes.count == 1 {
      return indexes.first
    }

    EpoxyLogger.shared.warn({
      return """
      Warning! Attempted to locate section \(dataID) when there are multiple sections with that ID \
      at the indexes \(indexes.map { $0 }). Choosing the last index. Sections should have unique \
      data IDs within a collection as duplicate data IDs can cause undefined behavior.
      """
    }())

    return indexes.last
  }

  // MARK: Private

  /// The storage for section indexes, with the section `dataID` as the key and its section indexes
  /// as the value.
  ///
  /// If the value contains more than one index, the section `dataID` is duplicated.
  private typealias SectionIndexMap = [AnyHashable: IndexSet]

  /// The storage for item indexes, with the item `dataID` as the key in the outer `Dictionary`, and
  /// the inner `Dictionary` with a key of the section `dataID` and the value as the collection of
  /// `IndexPath`s with both the item and section `dataID`.
  private typealias ItemIndexMap = [AnyHashable: [AnyHashable: [IndexPath]]]

  private let sectionIndexMap: SectionIndexMap
  private let itemIndexMap: ItemIndexMap

  private func supplementaryItemChangeset(
    from otherData: Self,
    sectionChangeset: IndexSetChangeset)
    -> [String: IndexPathChangeset]
  {
    var supplementaryItem = [String: IndexPathChangeset]()

    for fromSectionIndex in otherData.sections.indices {
      guard let toSectionIndex = sectionChangeset.newIndices[fromSectionIndex] else {
        continue
      }

      let fromSupplementaryItems = otherData.sections[fromSectionIndex].supplementaryItems
        .mapValues { $0.map { $0.eraseToAnySupplementaryItemModel() } }
      let toSupplementaryItems = sections[toSectionIndex].supplementaryItems
        .mapValues { $0.map { $0.eraseToAnySupplementaryItemModel() } }

      for (elementKind, toSupplementaryItems) in toSupplementaryItems {
        let fromSupplementaryItems = fromSupplementaryItems[elementKind, default: []]

        let itemIndexChangeset = toSupplementaryItems.makeIndexPathChangeset(
          from: fromSupplementaryItems,
          fromSection: fromSectionIndex,
          toSection: toSectionIndex)

        supplementaryItem[elementKind, default: .init()] += itemIndexChangeset
      }
    }

    return supplementaryItem
  }

  /// Outputs a warning for the given `changeset` if it contains duplicate IDs.
  private func warnOnDuplicates(in changeset: CollectionViewChangeset) {
    let sectionDuplicates = !changeset.sectionChangeset.duplicates.isEmpty
    let itemDuplicates = !changeset.itemChangeset.duplicates.isEmpty
    let supplementaryItemDuplicates = !changeset.supplementaryItemChangeset.allSatisfy { $0.value.duplicates.isEmpty }
    guard sectionDuplicates || itemDuplicates || supplementaryItemDuplicates else { return }

    EpoxyLogger.shared.warn({
      var message: [String] = [
        """
        Warning! Duplicate data IDs detected. Items should have unique data IDs within a section \
        and sections should have unique data IDs within a collection. Duplicate data IDs can cause \
        undefined behavior. Digest:
        """
      ]

      if sectionDuplicates {
        message.append("- Duplicate section IDs:")
        for duplicateIndexes in changeset.sectionChangeset.duplicates {
          // Force unwrap is safe here since `duplicateIndexes` is never empty.
          let duplicateID = sections[duplicateIndexes.first!].dataID
          message.append(
            "  - Section ID \(duplicateID) duplicated at indexes \(duplicateIndexes.map { $0 })")
        }
      }

      if itemDuplicates {
        message.append("- Duplicate item IDs:")
        for duplicateIndexes in changeset.itemChangeset.duplicates {
          // Subscripting is safe here since `duplicateIndexes` is never empty.
          let firstIndex = duplicateIndexes[0]
          let duplicateSection = sections[firstIndex.section]
          let duplicateSectionID = duplicateSection.dataID
          let duplicateItemID = duplicateSection.items[firstIndex.item].dataID
          message.append(
            """
              - In section with ID \(duplicateSectionID) at index \(firstIndex.section) item \
            with ID \(duplicateItemID) duplicated at indexes \(duplicateIndexes.map { $0.item })
            """)
        }
      }

      if supplementaryItemDuplicates {
        message.append("- Duplicate supplementary item IDs:")
        for (elementKind, changeset) in changeset.supplementaryItemChangeset {
          for duplicateIndexes in changeset.duplicates {
            // Subscripting is safe here since `duplicateIndexes` is never empty.
            let firstIndex = duplicateIndexes[0]
            let duplicateSection = sections[firstIndex.section]
            let duplicateSectionID = duplicateSection.dataID
            let duplicateItemID = duplicateSection
              .supplementaryItems[elementKind, default: []][firstIndex.item]
              .eraseToAnySupplementaryItemModel()
              .dataID
            message.append(
              """
                - In section with ID \(duplicateSectionID) at index \(firstIndex.section) \
              supplementary item of kind \(elementKind) with ID \(duplicateItemID) duplicated at \
              indexes \(duplicateIndexes.map { $0.item })
              """)
          }
        }
      }

      return message.joined(separator: "\n")
    }())
  }

}
