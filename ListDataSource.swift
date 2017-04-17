//  Created by Laura Skelton on 3/30/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

// MARK: - ListUpdateBehavior

/// The behavior of the ListInterface on update.
public enum ListUpdateBehavior {
  /// The `ListInterface` animates inserts, deletes, moves, and updates.
  case diffs
  /// The `ListInterface` reloads completely.
  case reloads
}

// MARK: - ListDataSourceProtocol

/// A protocol for a data source powered by a `ListStructure`
public protocol ListDataSourceProtocol {

  func setStructure(_ structure: ListStructure?)

  func updateItem(at dataID: String, with item: ListItem, animated: Bool)

}

extension ListDataSourceProtocol {

  public func setItems(_ items: [ListItem]) {
    let structure = ListStructure(items: items)
    setStructure(structure)
  }
}

// MARK: - ListDataSource

/// A data source powered by a `ListStructure` that can be specialized for different types of `ListInterface`s
public class ListDataSource<ListInterfaceType: DiffableListInterface>: NSObject {

  // MARK: Lifecycle

  /// Initializes the ListDataSource and configures its behavior on update.
  ///
  /// - Parameters:
  ///     - updateBehavior: Use `.Diffs` if you want the ListInterface to animate changes through inserts, deletes, moves, and updates. Use `.Reloads` if you want the ListInterface to completely reload when the Structure is set.
  public init(updateBehavior: ListUpdateBehavior) {
    self.updateBehavior = updateBehavior
  }

  // MARK: Public

  public weak var listInterface: ListInterfaceType? {
    didSet {
      resetReuseIDs()
    }
  }
  
  public fileprivate(set) var listStructure: ListStructure? {
    didSet {
      registerReuseIDs(with: listStructure)
      if let listStructure = listStructure {
        internalStructure = ListInterfaceType.Structure.make(with: listStructure)
      } else {
        internalStructure = nil
      }
    }
  }

  public fileprivate(set) var internalStructure: ListInterfaceType.Structure? {
    didSet {
      applyStructure(oldStructure: oldValue)
    }
  }

  // MARK: Fileprivate

  fileprivate let updateBehavior: ListUpdateBehavior
  fileprivate var reuseIDs = Set<String>()

  fileprivate func applyStructure(oldStructure: ListInterfaceType.Structure?) {
    guard let oldStructure = oldStructure,
      let newStructure = internalStructure else {
        listInterface?.reloadData()
        return
    }

    switch updateBehavior {
    case .diffs:
      let changeset = newStructure.makeChangeset(from: oldStructure)
      listInterface?.apply(changeset)
    case .reloads:
      listInterface?.reloadData()
    }
  }

  fileprivate func resetReuseIDs() {
    reuseIDs.removeAll()
    registerReuseIDs(with: listStructure)
  }

  fileprivate func registerReuseIDs(with listStructure: ListStructure?) {
    guard let listInterface = listInterface else {
      assert(false, "Trying to register reuse IDs before the ListInterface was set.")
      return
    }

    var newReuseIDs = Set<String>()

    listStructure?.sections.forEach { section in
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

// MARK: ListDataSource

extension ListDataSource: ListDataSourceProtocol {

  public func setStructure(_ structure: ListStructure?) {
    listStructure = structure
  }

  public func updateItem(
    at dataID: String,
    with item: ListItem,
    animated: Bool)
  {
    guard let internalStructure = internalStructure else {
      assert(false, "Update item was called when the ListStructure was nil.")
      return
    }
    guard let listInterface = listInterface else {
      assert(false, "Update item was called before the ListInterface was set.")
      return
    }
    guard let indexPath = internalStructure.updateItem(at: dataID, with: item) else {
      assert(false, "Update item was called with an index path that does not exist in the ListStructure.")
      return
    }

    listInterface.reloadItem(at: indexPath, animated: animated)
  }

}
