//  Created by Bryn Bodayle on 7/13/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation

public enum EpoxySectionFindError: Error {
  case itemNotFound
  case sectionNotFound
}

public extension Sequence where Iterator.Element == SectionModel {

  /// Find the ItemModeling and IndexPath for a given dataID
  func findItem(for dataID: AnyHashable) throws -> (ItemModeling, IndexPath) {

    for (sectionIndex, section) in self.enumerated() {
      for (itemIndex, item) in section.items.enumerated() {
        if item.dataID == dataID {
          return (item, IndexPath(item: itemIndex, section: sectionIndex))
        }
      }
    }

    throw EpoxySectionFindError.itemNotFound
  }

  /// Find the SectionModel and Index for a given section dataID
  func findSection(for dataID: AnyHashable) throws -> (SectionModel, Int) {

    for (sectionIndex, section) in self.enumerated() {
      if section.dataID == dataID {
        return (section, sectionIndex)
      }
    }

    throw EpoxySectionFindError.sectionNotFound
  }
}
