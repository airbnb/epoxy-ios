//  Created by Laura Skelton on 11/25/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import Foundation

/// A protocol that allows us to check identity and equality between items for the purposes of diffing.
public protocol QuickDiffable {

  /// Checks for equality between items when diffing.
  ///
  /// - Parameters:
  ///     - diffableItem: The other item to check equality against while diffing.
  func isEqualToDiffableItem(diffableItem: QuickDiffable) -> Bool

  /// The identifier to use when checking identity while diffing.
  var diffIdentifier: String { get }
}

// MARK: Stack

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

// MARK: Entry

private final class Entry {
  var oldIndices = Stack<Int?>()
  var updated: Bool = false
}

// MARK: Record

private final class Record {

  init(entry: Entry) {
    self.entry = entry
  }

  var entry: Entry
  var correspondingIndex: Int? = nil
}

// MARK: QuickDiffIndexChangeset

/// A set of inserts, deletes, updates, and moves that define the changes between two arrays.
public struct QuickDiffIndexChangeset {

  public init(
    inserts: [Int] = [Int](),
    deletes: [Int] = [Int](),
    updates: [(Int, Int)] = [(Int, Int)](),
    moves: [(Int, Int)] = [(Int, Int)](),
    newIndices: [Int?] = [Int?]())
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
  public let newIndices: [Int?]
}

// MARK: QuickDiffIndexPathChangeset

public struct QuickDiffIndexPathChangeset {

  init(
    inserts: [NSIndexPath] = [NSIndexPath](),
    deletes: [NSIndexPath] = [NSIndexPath](),
    updates: [(NSIndexPath, NSIndexPath)] = [(NSIndexPath, NSIndexPath)](),
    moves: [(NSIndexPath, NSIndexPath)] = [(NSIndexPath, NSIndexPath)]())
  {
    self.inserts = inserts
    self.deletes = deletes
    self.updates = updates
    self.moves = moves
  }

  /// The inserted `NSIndexPath`s needed to get from the old array to the new array.
  public let inserts: [NSIndexPath]

  /// The deleted `NSIndexPath`s needed to get from the old array to the new array.
  public let deletes: [NSIndexPath]

  /// The updated `NSIndexPath`s needed to get from the old array to the new array.
  public let updates: [(NSIndexPath, NSIndexPath)]

  /// The moved `NSIndexPath`s needed to get from the old array to the new array.
  public let moves: [(NSIndexPath, NSIndexPath)]
}

// MARK: QuickDiffIndexSetChangeset

public struct QuickDiffIndexSetChangeset {

  public init(
    inserts: NSIndexSet,
    deletes: NSIndexSet,
    updates: [(Int, Int)],
    moves: [(Int, Int)],
    newIndices: [Int?])
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
  public let newIndices: [Int?]
}

// MARK: QuickDiff

/// A class with methods for diffing, creating sets of minimal changes between two arrays.
public final class QuickDiff {

  /// Diffs between two arrays of `QuickDiffable` items, and returns a `QuickDiffIndexPathChangeset`
  /// representing the minimal set of changes to get from the old array to the new array.
  ///
  /// - Parameters:
  ///     - oldArray: The array of old data
  ///     - newArray: The array of new data
  ///     - fromSection: The section the old array data exists within. Defaults to `0`.
  ///     - toSection: The section the new array data exists within. Defaults to `0`.
  public static func diffIndexPaths<T: QuickDiffable>(oldArray
    oldArray: [T],
    newArray: [T],
    fromSection: Int = 0,
    toSection: Int = 0) -> QuickDiffIndexPathChangeset
  {
    let indexChangeset = diff(oldArray: oldArray, newArray: newArray)

    let inserts: [NSIndexPath] = indexChangeset.inserts.map { index in
      return NSIndexPath(forItem: index, inSection: toSection)
    }

    let deletes: [NSIndexPath] = indexChangeset.deletes.map { index in
      return NSIndexPath(forItem: index, inSection: fromSection)
    }

    let updates: [(NSIndexPath, NSIndexPath)] = indexChangeset.updates.map { fromIndex, toIndex in
      return (NSIndexPath(forItem: fromIndex, inSection: fromSection),
              NSIndexPath(forItem: toIndex, inSection: toSection))
    }

    let moves: [(NSIndexPath, NSIndexPath)] = indexChangeset.moves.map { fromIndex, toIndex in
      return (NSIndexPath(forItem: fromIndex, inSection: fromSection),
              NSIndexPath(forItem: toIndex, inSection: toSection))
    }

    return QuickDiffIndexPathChangeset(
      inserts: inserts,
      deletes: deletes,
      updates: updates,
      moves: moves)
  }

  /// Diffs between two arrays of `QuickDiffable` items, and returns a `QuickDiffIndexSetChangeset`
  /// representing the minimal set of changes to get from the old array to the new array.
  ///
  /// - Parameters:
  ///     - oldArray: The array of old data
  ///     - newArray: The array of new data
  public static func diffIndexSets<T: QuickDiffable>(oldArray
    oldArray: [T],
    newArray: [T]) -> QuickDiffIndexSetChangeset
  {
    let indexChangeset = diff(oldArray: oldArray, newArray: newArray)

    let inserts = NSMutableIndexSet()
    indexChangeset.inserts.forEach { index in
      inserts.addIndex(index)
    }

    let deletes = NSMutableIndexSet()
    indexChangeset.deletes.forEach { index in
      deletes.addIndex(index)
    }

    return QuickDiffIndexSetChangeset(
      inserts: inserts,
      deletes: deletes,
      updates: indexChangeset.updates,
      moves: indexChangeset.moves,
      newIndices: indexChangeset.newIndices)
  }

  /// Diffs between two arrays of `QuickDiffable` items, and returns a `QuickDiffIndexChangeset`
  /// representing the minimal set of changes to get from the old array to the new array.
  ///
  /// - Parameters:
  ///     - oldArray: The array of old data
  ///     - newArray: The array of new data
  public static func diff<T: QuickDiffable>(oldArray
    oldArray: [T],
    newArray: [T]) -> QuickDiffIndexChangeset
  {
    let oldCount = oldArray.count
    let newCount = newArray.count

    var entries = [String: Entry]()

    var newResultsArray = [Record]()
    for i in 0..<newCount {
      let entry: Entry
      if let existingEntry = entries[newArray[i].diffIdentifier] {
        entry = existingEntry
      } else {
        entry = Entry()
      }
      entry.oldIndices.push(nil)
      entries[newArray[i].diffIdentifier] = entry
      newResultsArray.append(Record(entry: entry))
    }

    // Old array must be done in reverse to stack indices in correct order
    var oldResultsArray = [Record]()
    for i in (0..<oldCount).reverse() {
      let entry: Entry
      if let existingEntry = entries[oldArray[i].diffIdentifier] {
        entry = existingEntry
      } else {
        entry = Entry()
      }
      entry.oldIndices.push(i)
      entries[oldArray[i].diffIdentifier] = entry
      oldResultsArray.append(Record(entry: entry))
    }

    for i in 0..<newCount {
      let entry = newResultsArray[i].entry
      if let originalIndex = entry.oldIndices.pop() {

        let newItem = newArray[i]
        let oldItem = oldArray[originalIndex]

        if !oldItem.isEqualToDiffableItem(newItem) {
          entry.updated = true
        }

        newResultsArray[i].correspondingIndex = originalIndex
        oldResultsArray[originalIndex].correspondingIndex = i
      }
    }

    var inserts = [Int]()
    var updates = [(Int, Int)]()
    var deletes = [Int]()
    var moves = [(Int, Int)]()

    var deleteOffsets = [Int]()
    var insertOffsets = [Int]()

    var runningDeleteOffset: Int = 0

    for i in 0..<oldCount {
      deleteOffsets.append(runningDeleteOffset)

      let record = oldResultsArray[i]

      if record.correspondingIndex == nil {
        deletes.append(i)
        runningDeleteOffset += 1
      }
    }

    var runningInsertOffset: Int = 0

    for i in 0..<newCount {
      insertOffsets.append(runningInsertOffset)

      let record = newResultsArray[i]

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

    assert(oldCount + inserts.count - deletes.count == newCount,
           "Failed sanity check for old array count with changes matching new array count.")

    return QuickDiffIndexChangeset(
      inserts: inserts,
      deletes: deletes,
      updates: updates,
      moves: moves,
      newIndices: oldResultsArray.map { $0.correspondingIndex })
  }
}
