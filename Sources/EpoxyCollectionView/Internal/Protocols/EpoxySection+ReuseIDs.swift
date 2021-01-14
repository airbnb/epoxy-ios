//  Created by Laura Skelton on 9/6/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore

// MARK: Extensions

extension SectionModel {

  /// Gets all items' view differentiators from the section.
  public func getItemViewDifferentiators() -> Set<ViewDifferentiator> {
    var newViewDifferentiators = Set<ViewDifferentiator>(minimumCapacity: items.count)
    for item in items {
      newViewDifferentiators.insert(item.viewDifferentiator)
    }
    return newViewDifferentiators
  }

  /// Gets the supplementary views' view differentiators for each element kind from the given section.
  public func getSupplementaryViewDifferentiators() -> [String: Set<ViewDifferentiator>] {
    var newViewDifferentiatorsForElementKind = [String: Set<ViewDifferentiator>]()

    for (elementKind, elementSupplementaryModels) in supplementaryItems {
      var newViewDifferentiators = Set<ViewDifferentiator>()
      for elementSupplementaryModel in elementSupplementaryModels {
        let viewDifferentiator = elementSupplementaryModel
          .eraseToAnySupplementaryItemModel()
          .viewDifferentiator
        newViewDifferentiators.insert(viewDifferentiator)
      }
      newViewDifferentiatorsForElementKind[elementKind] = newViewDifferentiators
    }

    return newViewDifferentiatorsForElementKind
  }
}

// MARK: - Array

extension Array where Element == SectionModel {
  public func getItemViewDifferentiators() -> Set<ViewDifferentiator> {
    var newViewDifferentiators = Set<ViewDifferentiator>()
    for section in self {
      newViewDifferentiators = newViewDifferentiators.union(section.getItemViewDifferentiators())
    }
    return newViewDifferentiators
  }

  public func getSupplementaryViewDifferentiators() -> [String: Set<ViewDifferentiator>] {
    var newViewDifferentiatorsForElementKind = [String: Set<ViewDifferentiator>]()
    for section in self {
      let sectionViewDifferentiators = section.getSupplementaryViewDifferentiators()
      for (elementKind, viewDifferentiators) in sectionViewDifferentiators {
        let existingSet = newViewDifferentiatorsForElementKind[elementKind] ?? []
        newViewDifferentiatorsForElementKind[elementKind] = existingSet.union(viewDifferentiators)
      }
    }
    return newViewDifferentiatorsForElementKind
  }
}
