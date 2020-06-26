//  Created by Laura Skelton on 11/25/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import Foundation

// MARK: - Stack

private final class Stack<T> {
  /// Pushes the element onto the top of the Stack.
  func push(itemToPush: T){
    stackArray.append(itemToPush)
  }

  /**
   Pops the top element from the Stack in O(1).
   - Requires: `count > 0`
   */
  func pop() -> T {
    return stackArray.removeLast()
  }

  private var stackArray = [T]()
}

// MARK: - Entry

private final class Entry {
  var oldIndices = Stack<Int?>()
  var updated: Bool = false
}

// MARK: - Record

private final class Record {

  init(entry: Entry) {
    self.entry = entry
  }

  var entry: Entry
  var correspondingIndex: Int? = nil
}

// MARK: - IndexChangeset

/// A set of inserts, deletes, updates, and moves that define the changes between two arrays.
public struct IndexChangeset {

  public init(
    inserts: [Int] = [Int](),
    deletes: [Int] = [Int](),
    updates: [(Int, Int)] = [(Int, Int)](),
    moves: [(Int, Int)] = [(Int, Int)](),
    newIndices: [Int: Int?] = [Int: Int?]())
  {
    self.inserts = inserts
    self.deletes = deletes
    self.updates = updates
    self.moves = moves
    self.newIndices = newIndices
  }

  /// The inserted indices needed to get from the old array to the new array.
  public let inserts: [Int]

  /// The deleted indices needed to get from the old array to the new array.
  public let deletes: [Int]

  /// The updated indices needed to get from the old array to the new array.
  public let updates: [(Int, Int)]

  /// The moved indices needed to get from the old array to the new array.
  public let moves: [(Int, Int)]

  /// A record for each old array item of what its index (if any) is in the new array.
  public let newIndices: [Int: Int?]
}

// MARK: - IndexPathChangeset

public struct IndexPathChangeset {

  init(
    inserts: [IndexPath] = [IndexPath](),
    deletes: [IndexPath] = [IndexPath](),
    updates: [(IndexPath, IndexPath)] = [(IndexPath, IndexPath)](),
    moves: [(IndexPath, IndexPath)] = [(IndexPath, IndexPath)]())
  {
    self.inserts = inserts
    self.deletes = deletes
    self.updates = updates
    self.moves = moves
  }

  /// The inserted `IndexPath`s needed to get from the old array to the new array.
  public let inserts: [IndexPath]

  /// The deleted `IndexPath`s needed to get from the old array to the new array.
  public let deletes: [IndexPath]

  /// The updated `IndexPath`s needed to get from the old array to the new array.
  public let updates: [(IndexPath, IndexPath)]

  /// The moved `IndexPath`s needed to get from the old array to the new array.
  public let moves: [(IndexPath, IndexPath)]

  /// Whether there are any inserts, deletes, moves, or updates in this changeset
  public var isEmpty: Bool {
    return  inserts.isEmpty &&
            deletes.isEmpty &&
            updates.isEmpty &&
            moves.isEmpty
  }
}

public func +(left: IndexPathChangeset, right: IndexPathChangeset) -> IndexPathChangeset {
  let inserts: [IndexPath] = left.inserts + right.inserts
  let deletes: [IndexPath] = left.deletes + right.deletes
  let updates: [(IndexPath, IndexPath)] = left.updates + right.updates
  let moves: [(IndexPath, IndexPath)] = left.moves + right.moves

  return IndexPathChangeset(
    inserts: inserts,
    deletes: deletes,
    updates: updates,
    moves: moves)
}

// MARK: - IndexSetChangeset

public struct IndexSetChangeset {

  public init(
    inserts: NSIndexSet,
    deletes: NSIndexSet,
    updates: [(Int, Int)],
    moves: [(Int, Int)],
    newIndices: [Int: Int?] = [Int: Int?]())
  {
    self.inserts = inserts
    self.deletes = deletes
    self.updates = updates
    self.moves = moves
    self.newIndices = newIndices
  }

  /// An `NSIndexSet` of inserts needed to get from the old array to the new array.
  public let inserts: NSIndexSet

  /// An `NSIndexSet` of deletes needed to get from the old array to the new array.
  public let deletes: NSIndexSet

  /// The updated indices needed to get from the old array to the new array.
  public let updates: [(Int, Int)]

  /// The moved indices needed to get from the old array to the new array.
  public let moves: [(Int, Int)]

  /// A record for each old array item of what its index (if any) is in the new array.
  public let newIndices: [Int: Int?]

  /// Whether there are any inserts, deletes, moves, or updates in this changeset
  public var isEmpty: Bool {
    return  inserts.count == 0 &&
            deletes.count == 0 &&
            updates.isEmpty &&
            moves.isEmpty
  }
}

extension Collection where Self.Iterator.Element: Diffable, Self.Index == Int {

  /// Diffs between two collections (eg. `Array`s) of `Diffable` items, and returns an `IndexChangeset`
  /// representing the minimal set of changes to get from the other collection to this collection.
  ///
  /// - Parameters:
  ///     - from otherCollection: The collection of old data
  public func makeChangeset(from
    otherCollection: Self) -> IndexChangeset
  {
    var entries = [AnyHashable: Entry]()

    var newResultsArray = [Int: Record]()
    for i in startIndex..<endIndex {
      let entry: Entry
      if let diffIdentifier = self[i].diffIdentifier,
        let existingEntry = entries[diffIdentifier] {
        entry = existingEntry
      } else {
        entry = Entry()
      }
      entry.oldIndices.push(itemToPush: nil)
      if let diffIdentifier = self[i].diffIdentifier {
        entries[diffIdentifier] = entry
      }
      newResultsArray[i] = (Record(entry: entry))
    }

    // Old array must be done in reverse to stack indices in correct order
    var oldResultsArray = [Int: Record]()
    for i in (otherCollection.startIndex..<otherCollection.endIndex).reversed() {
      let entry: Entry
      if let diffIdentifier = otherCollection[i].diffIdentifier,
        let existingEntry = entries[diffIdentifier] {
        entry = existingEntry
      } else {
        entry = Entry()
      }
      entry.oldIndices.push(itemToPush: i)
      if let diffIdentifier = otherCollection[i].diffIdentifier {
        entries[diffIdentifier] = entry
      }
      oldResultsArray[i] = (Record(entry: entry))
    }

    for i in startIndex..<endIndex {
      let entry = newResultsArray[i]!.entry
      if let originalIndex = entry.oldIndices.pop() {

        let newItem = self[i]
        let oldItem = otherCollection[originalIndex]

        if !oldItem.isDiffableItemEqual(to: newItem) {
          entry.updated = true
        }

        newResultsArray[i]!.correspondingIndex = originalIndex
        oldResultsArray[originalIndex]!.correspondingIndex = i
      }
    }

    var inserts = [Int]()
    var updates = [(Int, Int)]()
    var deletes = [Int]()
    var moves = [(Int, Int)]()

    var deleteOffsets = [Int]()
    var insertOffsets = [Int]()

    var runningDeleteOffset: Int = 0

    for i in otherCollection.startIndex..<otherCollection.endIndex {
      deleteOffsets.append(runningDeleteOffset)

      let record = oldResultsArray[i]!

      if record.correspondingIndex == nil {
        deletes.append(i)
        runningDeleteOffset += 1
      }
    }

    var runningInsertOffset: Int = 0

    for i in startIndex..<endIndex {
      insertOffsets.append(runningInsertOffset)

      let record = newResultsArray[i]!

      if let oldArrayIndex = record.correspondingIndex {

        if record.entry.updated {
          updates.append((oldArrayIndex, i))
        }

        let insertOffset = insertOffsets[i]
        let deleteOffset = deleteOffsets[oldArrayIndex]
        if ((oldArrayIndex - deleteOffset + insertOffset) != i) {
          moves.append((oldArrayIndex, i))
        }

      } else {
        inserts.append(i)
        runningInsertOffset += 1
      }
    }

    assert(otherCollection.count + inserts.count - deletes.count == self.count,
           "Failed sanity check for old array count with changes matching new array count.")

    let newIndicesArray: [(Int, Int?)] = oldResultsArray.map { index, record in
      return (index, record.correspondingIndex)
    }

    return IndexChangeset(
      inserts: inserts,
      deletes: deletes,
      updates: updates,
      moves: moves,
      newIndices: newIndicesArray.toDictionary { $0 })
  }

  /// Diffs between two collections (eg. `Array`s) of `Diffable` items, and returns an `IndexPathChangeset`
  /// representing the minimal set of changes to get from the other collection to this collection.
  ///
  /// - Parameters:
  ///     - from otherCollection: The collection of old data
  ///     - fromSection: The section the other collection's data exists within. Defaults to `0`.
  ///     - toSection: The section this collection's data exists within. Defaults to `0`.
  public func makeIndexPathChangeset(from
    otherCollection: Self,
    fromSection: Int = 0,
    toSection: Int = 0) -> IndexPathChangeset
  {
    let indexChangeset = makeChangeset(from: otherCollection)

    let inserts: [IndexPath] = indexChangeset.inserts.map { index in
      return IndexPath(item: index, section: toSection)
    }

    let deletes: [IndexPath] = indexChangeset.deletes.map { index in
      return IndexPath(item: index, section: fromSection)
    }

    let updates: [(IndexPath, IndexPath)] = indexChangeset.updates.map { fromIndex, toIndex in
      return (IndexPath(item: fromIndex, section: fromSection),
        IndexPath(item: toIndex, section: toSection))
    }

    let moves: [(IndexPath, IndexPath)] = indexChangeset.moves.map { fromIndex, toIndex in
      return (IndexPath(item: fromIndex, section: fromSection),
        IndexPath(item: toIndex, section: toSection))
    }

    return IndexPathChangeset(
      inserts: inserts,
      deletes: deletes,
      updates: updates,
      moves: moves)
  }

  /// Diffs between two collections (eg. `Array`s) of `Diffable` items, and returns an `IndexSetChangeset`
  /// representing the minimal set of changes to get from the other collection to this collection.
  ///
  /// - Parameters:
  ///     - from otherCollection: The collection of old data
  public func makeIndexSetChangeset(from
    otherCollection: Self) -> IndexSetChangeset
  {
    let indexChangeset = makeChangeset(from: otherCollection)

    let inserts = NSMutableIndexSet()
    indexChangeset.inserts.forEach { index in
      inserts.add(index)
    }

    let deletes = NSMutableIndexSet()
    indexChangeset.deletes.forEach { index in
      deletes.add(index)
    }

    return IndexSetChangeset(
      inserts: inserts,
      deletes: deletes,
      updates: indexChangeset.updates,
      moves: indexChangeset.moves,
      newIndices: indexChangeset.newIndices)
  }
}

// MARK: - Collection

extension Collection {

  /// Quickly generate a `Dictionary` from an `Array` (or other `CollectionType`), returning either a `(key, value)` tuple or `nil` for each `Array` element
  fileprivate func toDictionary<K, V>
    (_ transform:(_ element: Self.Iterator.Element) -> (key: K, value: V)?) -> [K: V] {
    var dictionary = [K: V]()
    for element in self {
      if let (key, value) = transform(element) {
        dictionary[key] = value
      }
    }

    return dictionary
  }
}
