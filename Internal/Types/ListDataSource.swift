//
//  ListDataSource.swift
//  List
//
//  Created by Laura Skelton on 5/11/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

import UIKit

/// A data source powered by a `[ListSection]` that can be specialized for different types of `ListInterface`s
public class ListDataSource<ListInterfaceType: InternalListInterface>: NSObject {

  // MARK: Lifecycle

  init(updateBehavior: ListUpdateBehavior) {
    self.updateBehavior = updateBehavior
  }

  // MARK: Internal

  weak var listInterface: ListInterfaceType? {
    didSet {
      resetReuseIDs()
    }
  }

  fileprivate(set) var sections: [ListSection]? {
    didSet {
      registerReuseIDs(with: sections)
      if let sections = sections {
        internalData = ListInterfaceType.DataType.make(with: sections)
      } else {
        internalData = nil
      }
    }
  }

  fileprivate(set) var internalData: ListInterfaceType.DataType? {
    didSet {
      applyData(oldData: oldValue)
    }
  }

  func setSections(_ sections: [ListSection]?) {
    self.sections = sections
  }

  func updateItem(
    at dataID: String,
    with item: ListItem,
    animated: Bool)
  {
    guard let internalData = internalData else {
      assert(false, "Update item was called when the data was nil.")
      return
    }
    guard let listInterface = listInterface else {
      assert(false, "Update item was called before the ListInterface was set.")
      return
    }
    guard let indexPath = internalData.updateItem(at: dataID, with: item) else {
      assert(false, "Update item was called with an index path that does not exist in the data.")
      return
    }

    listInterface.reloadItem(at: indexPath, animated: animated)
  }

  // MARK: Fileprivate

  fileprivate let updateBehavior: ListUpdateBehavior
  fileprivate var reuseIDs = Set<String>()

  fileprivate func applyData(oldData: ListInterfaceType.DataType?) {
    guard let oldData = oldData,
      let newData = internalData else {
        listInterface?.reloadData()
        return
    }

    switch updateBehavior {
    case .diffs:
      let changeset = newData.makeChangeset(from: oldData)
      listInterface?.apply(changeset)
    case .reloads:
      listInterface?.reloadData()
    }
  }

  fileprivate func resetReuseIDs() {
    reuseIDs.removeAll()
    registerReuseIDs(with: sections)
  }

  fileprivate func registerReuseIDs(with sections: [ListSection]?) {
    guard let listInterface = listInterface else {
      assert(false, "Trying to register reuse IDs before the ListInterface was set.")
      return
    }

    var newReuseIDs = Set<String>()

    sections?.forEach { section in
      let items: [ListItem] = section.items + [section.sectionHeader].flatMap { $0 }
      items.forEach { item in
        newReuseIDs.insert(item.reuseID)
      }
    }

    reuseIDs.forEach { reuseID in
      if !newReuseIDs.contains(reuseID) {
        listInterface.unregister(reuseID: reuseID)
      }
    }

    newReuseIDs.forEach { reuseID in
      if !reuseIDs.contains(reuseID) {
        listInterface.register(reuseID: reuseID)
      }
    }

    reuseIDs = newReuseIDs
  }

}
