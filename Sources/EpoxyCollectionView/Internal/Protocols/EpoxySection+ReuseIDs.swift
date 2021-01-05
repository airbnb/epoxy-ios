//  Created by Laura Skelton on 9/6/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore

// MARK: Extensions

extension SectionModel {
  /// Gets the cell reuse IDs from the given external sections
  public func getCellReuseIDs() -> Set<String> {
    var newCellReuseIDs = Set<String>()
    for item in items {
      newCellReuseIDs.insert(item.reuseID)
    }
    return newCellReuseIDs
  }

  /// Gets the supplementary view reuse IDs by kind from the given external sections
  public func getSupplementaryViewReuseIDs() -> [String: Set<String>] {
    var newSupplementaryViewReuseIDs = [String: Set<String>]()

    for (elementKind, elementSupplementaryModels) in supplementaryItems {
      var newElementSupplementaryViewReuseIDs = Set<String>()
      for elementSupplementaryModel in elementSupplementaryModels {
        let reuseID = elementSupplementaryModel.eraseToAnySupplementaryItemModel().reuseID
        newElementSupplementaryViewReuseIDs.insert(reuseID)
      }
      newSupplementaryViewReuseIDs[elementKind] = newElementSupplementaryViewReuseIDs
    }

    return newSupplementaryViewReuseIDs
  }
}

// MARK: - Array

extension Array where Element == SectionModel {
  public func getCellReuseIDs() -> Set<String> {
    var newReuseIDs = Set<String>()
    forEach { section in
      newReuseIDs = newReuseIDs.union(section.getCellReuseIDs())
    }
    return newReuseIDs
  }

  public func getSupplementaryViewReuseIDs() -> [String: Set<String>] {
    var newReuseIDs = [String: Set<String>]()
    forEach { section in
      let sectionReuseIDs = section.getSupplementaryViewReuseIDs()
      for (elementKind, reuseIDs) in sectionReuseIDs {
        let existingSet = newReuseIDs[elementKind] ?? Set<String>()
        newReuseIDs[elementKind] = existingSet.union(reuseIDs)
      }
    }
    return newReuseIDs
  }
}
