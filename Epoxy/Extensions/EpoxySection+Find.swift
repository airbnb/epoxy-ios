//  Created by Bryn Bodayle on 7/13/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation

public enum EpoxySectionFindError: Error {
  case itemNotFound
  case sectionNotFound
}

public extension Sequence where Iterator.Element == EpoxySection {

  /// Find the EpoxyableModel and IndexPath for a given dataID
  func findItem(for dataID: String) throws -> (EpoxyableModel, IndexPath) {

    for (sectionIndex, section) in self.enumerated() {
      for (itemIndex, item) in section.items.enumerated() {
        if item.dataID == dataID {
          return (item, IndexPath(item: itemIndex, section: sectionIndex))
        }
      }
    }

    throw EpoxySectionFindError.itemNotFound
  }

  /// Find the EpoxySection and Index for a given section dataID
  func findSection(for dataID: String) throws -> (EpoxySection, Int) {

    for (sectionIndex, section) in self.enumerated() {
      if section.dataID == dataID {
        return (section, sectionIndex)
      }
    }

    throw EpoxySectionFindError.sectionNotFound
  }
}
