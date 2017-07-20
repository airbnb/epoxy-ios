//
//  EpoxySection+Find.swift
//  Epoxy
//
//  Created by Bryn Bodayle on 7/13/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

import Foundation

public enum EpoxySectionFindError: Error {
  case itemNotFound
}

public extension Sequence where Iterator.Element == EpoxySection {

  /// Find the EpoxyableModel and IndexPath for a given dataID
  public func findItem(for dataID: String) throws -> (EpoxyableModel, IndexPath) {

    for (sectionIndex, section) in self.enumerated() {
      for (itemIndex, item) in section.items.enumerated() {
        if item.dataID == dataID {
          return (item, IndexPath(item: itemIndex, section: sectionIndex))
        }
      }
    }

    throw EpoxySectionFindError.itemNotFound
  }
}
