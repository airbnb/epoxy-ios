//  Created by Laura Skelton on 5/19/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import Foundation

// MARK: - InternalCollectionViewEpoxyData

public struct InternalCollectionViewEpoxyData {

  // MARK: Lifecycle

  init(
    sections: [SectionModel],
    sectionIndexMap: [AnyHashable: Int],
    itemIndexMap: [AnyHashable: IndexPath],
    epoxyLogger: EpoxyLogging)
  {
    self.sections = sections
    self.sectionIndexMap = sectionIndexMap
    self.itemIndexMap = itemIndexMap
    self.epoxyLogger = epoxyLogger
  }

  // MARK: Public

  public let sections: [SectionModel]

  public static func make(sections: [SectionModel], epoxyLogger: EpoxyLogging) -> Self {
    var sectionIndexMap = [AnyHashable: Int]()
    var itemIndexMap = [AnyHashable: IndexPath]()

    sections.enumerated().forEach { sectionIndex, section in
      sectionIndexMap[section.dataID] = sectionIndex
      section.items.enumerated().forEach { itemIndex, item in
        itemIndexMap[item.dataID] = IndexPath(item: itemIndex, section: sectionIndex)
      }
    }

    return .init(
      sections: sections,
      sectionIndexMap: sectionIndexMap,
      itemIndexMap: itemIndexMap,
      epoxyLogger: epoxyLogger)
  }

  public func makeChangeset(from otherData: Self) -> EpoxyChangeset {
    let sectionChangeset = sections.makeIndexSetChangeset(from: otherData.sections)

    var itemChangesetsForSections = [IndexPathChangeset]()

    for fromSection in otherData.sections.indices {
      if let toSection = sectionChangeset.newIndices[fromSection]! {
        let fromItems = otherData.sections[fromSection].items.map { $0.eraseToAnyItemModel() }
        let toItems = sections[toSection].items.map { $0.eraseToAnyItemModel() }

        let itemIndexChangeset = toItems.makeIndexPathChangeset(
          from: fromItems,
          fromSection: fromSection,
          toSection: toSection)

        itemChangesetsForSections.append(itemIndexChangeset)
      }
    }

    let itemChangeset = itemChangesetsForSections.reduce(IndexPathChangeset(), +)

    return EpoxyChangeset(sectionChangeset: sectionChangeset, itemChangeset: itemChangeset)
  }

  public func indexPathForItem(at dataID: AnyHashable) -> IndexPath? {
    itemIndexMap[dataID]
  }

  public func indexForSection(at dataID: AnyHashable) -> Int? {
    sectionIndexMap[dataID]
  }

  // MARK: Private

  private let sectionIndexMap: [AnyHashable: Int]
  private let itemIndexMap: [AnyHashable: IndexPath]
  private let epoxyLogger: EpoxyLogging
}

// MARK: CustomStringConvertible

extension InternalCollectionViewEpoxyData: CustomStringConvertible {
  public var description: String {
    return "Data: (Sections: [\(sections)]"
  }
}
