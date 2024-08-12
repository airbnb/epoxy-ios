// Created by Laura Skelton on 12/15/16
// Copyright © 2016 Airbnb Inc. All rights reserved.

import EpoxyCore
import Nimble
import Quick

// MARK: - Int + Diffable

extension Int: Diffable {
  public var diffIdentifier: AnyHashable {
    self
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherInt = otherDiffableItem as? Int else { return false }
    return self == otherInt
  }

}

// MARK: - TestDiffable

private struct TestDiffable {
  let identifier: Int
  let content: String
}

// MARK: Diffable

extension TestDiffable: Diffable {
  var diffIdentifier: AnyHashable {
    identifier
  }

  func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherTestDiffable = otherDiffableItem as? TestDiffable else { return false }
    return content == otherTestDiffable.content
  }

}

// MARK: - TestDiffableSection

private struct TestDiffableSection {
  let identifier: Int
  let items: [TestDiffable]
}

// MARK: DiffableSection

extension TestDiffableSection: DiffableSection {
  var diffableItems: [TestDiffable] {
    items
  }

  var diffIdentifier: AnyHashable {
    identifier
  }

  func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherTestDiffable = otherDiffableItem as? Self else { return false }
    return diffIdentifier == otherTestDiffable.diffIdentifier
  }

}

// MARK: - CollectionDiffSpec

final class CollectionDiffSpec: QuickSpec {

  override func spec() {
    let intArray = [1, 2, 3, 4, 5, 6, 7]

    let testDiffableArray = [
      TestDiffable(identifier: 1, content: "1"),
      TestDiffable(identifier: 2, content: "2"),
      TestDiffable(identifier: 3, content: "3"),
      TestDiffable(identifier: 4, content: "4"),
      TestDiffable(identifier: 5, content: "5"),
      TestDiffable(identifier: 6, content: "6"),
      TestDiffable(identifier: 7, content: "7"),
    ]

    let testSectionedDiffableArray = [
      TestDiffableSection(identifier: 1, items: testDiffableArray),
      TestDiffableSection(identifier: 2, items: testDiffableArray),
      TestDiffableSection(identifier: 3, items: testDiffableArray),
    ]

    describe("makeChangeset") {
      context("with called on an identical collection") {
        it("returns an empty changeset") {
          let changeset = intArray.makeChangeset(from: intArray)
          expect(changeset.inserts).to(beEmpty())
          expect(changeset.deletes).to(beEmpty())
          expect(changeset.updates).to(beEmpty())
          expect(changeset.moves).to(beEmpty())
          expect(changeset.isEmpty).to(beTrue())
          expect(changeset.duplicates).to(beEmpty())
        }

        context("with duplicate identifiers") {
          let intArray = [1, 1, 2, 3, 2, 4, 5, 6, 6, 6, 7, 6]

          it("returns the correct changeset") {
            let changeset = intArray.makeChangeset(from: intArray)
            expect(changeset.duplicates) == [
              [0, 1],
              [2, 4],
              [7, 8, 9, 11],
            ]
            expect(changeset.inserts).to(beEmpty())
            expect(changeset.deletes).to(beEmpty())
            expect(changeset.updates).to(beEmpty())
            expect(changeset.moves).to(beEmpty())
            expect(changeset.isEmpty).to(beTrue())
          }
        }
      }

      context("when called on a collection with insertions") {
        context("at the beginning") {
          let otherIntArray = [100, 1, 2, 3, 4, 5, 6, 7]

          it("returns the correct changeset") {
            let changeset = otherIntArray.makeChangeset(from: intArray)
            expect(changeset.inserts.count).to(equal(1))
            expect(changeset.inserts.first).to(equal(0))
            expect(changeset.deletes).to(beEmpty())
            expect(changeset.updates).to(beEmpty())
            expect(changeset.moves).to(beEmpty())
            expect(changeset.duplicates).to(beEmpty())
          }

          context("duplicating an existing identifier") {
            let otherIntArray = [1, 1, 2, 3, 4, 5, 6, 7]

            it("returns the correct changeset") {
              let changeset = otherIntArray.makeChangeset(from: intArray)
              expect(changeset.inserts.count).to(equal(1))
              expect(changeset.inserts.first).to(equal(1))
              expect(changeset.duplicates) == [[0, 1]]
              expect(changeset.deletes).to(beEmpty())
              expect(changeset.updates).to(beEmpty())
              expect(changeset.moves).to(beEmpty())
            }
          }
        }

        context("in the middle") {
          let otherIntArray = [1, 2, 3, 100, 4, 5, 6, 7]

          it("returns the correct changeset") {
            let changeset = otherIntArray.makeChangeset(from: intArray)
            expect(changeset.inserts.count).to(equal(1))
            expect(changeset.inserts.first).to(equal(3))
            expect(changeset.deletes).to(beEmpty())
            expect(changeset.updates).to(beEmpty())
            expect(changeset.moves).to(beEmpty())
            expect(changeset.duplicates).to(beEmpty())
          }

          context("duplicating an existing identifier") {
            let otherIntArray = [1, 2, 3, 4, 3, 5, 6, 7]

            it("returns the correct changeset") {
              let changeset = otherIntArray.makeChangeset(from: intArray)
              expect(changeset.inserts.count).to(equal(1))
              expect(changeset.inserts.first).to(equal(4))
              expect(changeset.duplicates) == [[2, 4]]
              expect(changeset.deletes).to(beEmpty())
              expect(changeset.updates).to(beEmpty())
              expect(changeset.moves).to(beEmpty())
            }
          }
        }

        context("at the end") {
          let otherIntArray = [1, 2, 3, 4, 5, 6, 7, 100]

          it("returns the correct changeset") {
            let changeset = otherIntArray.makeChangeset(from: intArray)
            expect(changeset.inserts.count).to(equal(1))
            expect(changeset.inserts.first).to(equal(7))
            expect(changeset.deletes).to(beEmpty())
            expect(changeset.updates).to(beEmpty())
            expect(changeset.moves).to(beEmpty())
            expect(changeset.duplicates).to(beEmpty())
          }

          context("duplicating an existing identifier") {
            let otherIntArray = [1, 2, 3, 4, 5, 6, 7, 7]

            it("returns the correct changeset") {
              let changeset = otherIntArray.makeChangeset(from: intArray)
              expect(changeset.inserts.count).to(equal(1))
              expect(changeset.inserts.first).to(equal(7))
              expect(changeset.duplicates) == [[6, 7]]
              expect(changeset.deletes).to(beEmpty())
              expect(changeset.updates).to(beEmpty())
              expect(changeset.moves).to(beEmpty())
            }
          }
        }
      }

      context("when called on a collection with deletes") {
        context("from the beginning") {
          let otherIntArray = [2, 3, 4, 5, 6, 7]

          it("returns the correct changeset") {
            let changeset = otherIntArray.makeChangeset(from: intArray)
            expect(changeset.deletes.count).to(equal(1))
            expect(changeset.deletes.first).to(equal(0))
            expect(changeset.inserts).to(beEmpty())
            expect(changeset.updates).to(beEmpty())
            expect(changeset.moves).to(beEmpty())
            expect(changeset.duplicates).to(beEmpty())
          }
        }

        context("from the middle") {
          let otherIntArray = [1, 2, 3, 5, 6, 7]

          it("returns the correct changeset") {
            let changeset = otherIntArray.makeChangeset(from: intArray)
            expect(changeset.deletes.count).to(equal(1))
            expect(changeset.deletes.first).to(equal(3))
            expect(changeset.inserts).to(beEmpty())
            expect(changeset.updates).to(beEmpty())
            expect(changeset.moves).to(beEmpty())
            expect(changeset.duplicates).to(beEmpty())
          }
        }

        context("from the end") {
          let otherIntArray = [1, 2, 3, 4, 5, 6]

          it("returns the correct changeset") {
            let changeset = otherIntArray.makeChangeset(from: intArray)
            expect(changeset.deletes.count).to(equal(1))
            expect(changeset.deletes.first).to(equal(6))
            expect(changeset.inserts).to(beEmpty())
            expect(changeset.updates).to(beEmpty())
            expect(changeset.moves).to(beEmpty())
            expect(changeset.duplicates).to(beEmpty())
          }
        }
      }

      context("when called on a collection with moves") {
        context("from the beginning to the end") {
          let otherIntArray = [2, 3, 4, 5, 6, 7, 1]

          it("returns the correct changeset") {
            let changeset = otherIntArray.makeChangeset(from: intArray)
            expect(changeset.moves.count).to(equal(7))

            let firstMove = changeset.moves.filter { startIndex, _ in
              startIndex == 0
            }
            expect(firstMove.first!.new).to(equal(6))

            let secondMove = changeset.moves.filter { startIndex, _ in
              startIndex == 1
            }
            expect(secondMove.first!.new).to(equal(0))
            expect(changeset.inserts).to(beEmpty())
            expect(changeset.updates).to(beEmpty())
            expect(changeset.deletes).to(beEmpty())
          }
        }

        context("from the beginning to the middle") {
          let otherIntArray = [2, 3, 4, 1, 5, 6, 7]

          it("returns the correct changeset") {
            let changeset = otherIntArray.makeChangeset(from: intArray)
            expect(changeset.moves.count).to(equal(4))

            let firstMove = changeset.moves.filter { startIndex, _ in
              startIndex == 0
            }
            expect(firstMove.first!.new).to(equal(3))

            let secondMove = changeset.moves.filter { startIndex, _ in
              startIndex == 1
            }
            expect(secondMove.first!.new).to(equal(0))
            expect(changeset.inserts).to(beEmpty())
            expect(changeset.updates).to(beEmpty())
            expect(changeset.deletes).to(beEmpty())
          }
        }

        context("from the middle to the beginning") {
          let otherIntArray = [3, 1, 2, 4, 5, 6, 7]

          it("returns the correct changeset") {
            let changeset = otherIntArray.makeChangeset(from: intArray)
            expect(changeset.moves.count).to(equal(3))

            let firstMove = changeset.moves.filter { startIndex, _ in
              startIndex == 0
            }
            expect(firstMove.first!.new).to(equal(1))

            let secondMove = changeset.moves.filter { startIndex, _ in
              startIndex == 1
            }
            expect(secondMove.first!.new).to(equal(2))

            let thirdMove = changeset.moves.filter { startIndex, _ in
              startIndex == 2
            }
            expect(thirdMove.first!.new).to(equal(0))
            expect(changeset.inserts).to(beEmpty())
            expect(changeset.updates).to(beEmpty())
            expect(changeset.deletes).to(beEmpty())
          }
        }

        context("from the middle to the end") {
          let otherIntArray = [1, 2, 4, 5, 6, 7, 3]

          it("returns the correct changeset") {
            let changeset = otherIntArray.makeChangeset(from: intArray)
            expect(changeset.moves.count).to(equal(5))

            let firstMove = changeset.moves.filter { startIndex, _ in
              startIndex == 2
            }
            expect(firstMove.first!.new).to(equal(6))

            let secondMove = changeset.moves.filter { startIndex, _ in
              startIndex == 3
            }
            expect(secondMove.first!.new).to(equal(2))

            let thirdMove = changeset.moves.filter { startIndex, _ in
              startIndex == 4
            }
            expect(thirdMove.first!.new).to(equal(3))
            expect(changeset.inserts).to(beEmpty())
            expect(changeset.updates).to(beEmpty())
            expect(changeset.deletes).to(beEmpty())
          }
        }

        context("from the middle of an array to the middle") {
          let otherIntArray = [1, 2, 4, 3, 5, 6, 7]

          it("returns the correct changeset") {
            let changeset = otherIntArray.makeChangeset(from: intArray)
            expect(changeset.moves.count).to(equal(2))

            let firstMove = changeset.moves.filter { startIndex, _ in
              startIndex == 2
            }
            expect(firstMove.first!.new).to(equal(3))

            let secondMove = changeset.moves.filter { startIndex, _ in
              startIndex == 3
            }
            expect(secondMove.first!.new).to(equal(2))

            expect(changeset.inserts).to(beEmpty())
            expect(changeset.updates).to(beEmpty())
            expect(changeset.deletes).to(beEmpty())
          }
        }

        context("from the end to the beginning") {
          let otherIntArray = [7, 1, 2, 3, 4, 5, 6]

          it("returns the correct changeset") {
            let changeset = otherIntArray.makeChangeset(from: intArray)
            expect(changeset.moves.count).to(equal(7))

            let firstMove = changeset.moves.filter { startIndex, _ in
              startIndex == 6
            }
            expect(firstMove.first!.new).to(equal(0))

            let secondMove = changeset.moves.filter { startIndex, _ in
              startIndex == 0
            }
            expect(secondMove.first!.new).to(equal(1))

            expect(changeset.inserts).to(beEmpty())
            expect(changeset.updates).to(beEmpty())
            expect(changeset.deletes).to(beEmpty())
          }
        }

        context("from the end to the middle") {
          let otherIntArray = [1, 2, 3, 7, 4, 5, 6]

          it("returns the correct changeset") {
            let changeset = otherIntArray.makeChangeset(from: intArray)
            expect(changeset.moves.count).to(equal(4))

            let firstMove = changeset.moves.filter { startIndex, _ in
              startIndex == 6
            }
            expect(firstMove.first!.new).to(equal(3))

            let secondMove = changeset.moves.filter { startIndex, _ in
              startIndex == 3
            }
            expect(secondMove.first!.new).to(equal(4))

            expect(changeset.inserts).to(beEmpty())
            expect(changeset.updates).to(beEmpty())
            expect(changeset.deletes).to(beEmpty())
          }
        }
      }

      context("when called on a collection with updates") {
        context("when an item is updated") {
          let otherTestDiffableArray = [
            TestDiffable(identifier: 1, content: "1"),
            TestDiffable(identifier: 2, content: "2"),
            TestDiffable(identifier: 3, content: "three"),
            TestDiffable(identifier: 4, content: "4"),
            TestDiffable(identifier: 5, content: "5"),
            TestDiffable(identifier: 6, content: "6"),
            TestDiffable(identifier: 7, content: "7"),
          ]

          it("returns the correct changeset") {
            let changeset = otherTestDiffableArray.makeChangeset(from: testDiffableArray)
            expect(changeset.updates.count).to(equal(1))
            let firstUpdate = changeset.updates.filter { startIndex, _ in
              startIndex == 2
            }
            expect(firstUpdate.first).toNot(beNil())
            expect(firstUpdate.first!.new).to(equal(2))
            expect(changeset.deletes).to(beEmpty())
            expect(changeset.inserts).to(beEmpty())
            expect(changeset.moves).to(beEmpty())
          }
        }

        context("when multiple items are updated") {
          let otherTestDiffableArray = [
            TestDiffable(identifier: 1, content: "1"),
            TestDiffable(identifier: 2, content: "2"),
            TestDiffable(identifier: 3, content: "three"),
            TestDiffable(identifier: 4, content: "4"),
            TestDiffable(identifier: 5, content: "five"),
            TestDiffable(identifier: 6, content: "6"),
            TestDiffable(identifier: 7, content: "7"),
          ]

          it("returns the correct changeset") {
            let changeset = otherTestDiffableArray.makeChangeset(from: testDiffableArray)
            expect(changeset.updates.count).to(equal(2))
            let firstUpdate = changeset.updates.filter { startIndex, _ in
              startIndex == 2
            }
            expect(firstUpdate.first).toNot(beNil())
            expect(firstUpdate.first!.new).to(equal(2))

            let secondUpdate = changeset.updates.filter { startIndex, _ in
              startIndex == 4
            }
            expect(secondUpdate.first).toNot(beNil())
            expect(secondUpdate.first!.new).to(equal(4))
            expect(changeset.deletes).to(beEmpty())
            expect(changeset.inserts).to(beEmpty())
            expect(changeset.moves).to(beEmpty())
          }
        }

        context("with no item updates") {
          let otherTestDiffableArray = [
            TestDiffable(identifier: 100, content: "1"),
            TestDiffable(identifier: 2, content: "2"),
            TestDiffable(identifier: 3, content: "3"),
            TestDiffable(identifier: 4, content: "4"),
            TestDiffable(identifier: 5, content: "5"),
            TestDiffable(identifier: 6, content: "6"),
            TestDiffable(identifier: 7, content: "7"),
          ]

          it("returns the correct changeset") {
            let changeset = otherTestDiffableArray.makeChangeset(from: testDiffableArray)
            expect(changeset.updates).to(beEmpty())
          }
        }
      }

      context("when called on a collection with updates and moves") {
        let otherTestDiffableArray = [
          TestDiffable(identifier: 1, content: "1"),
          TestDiffable(identifier: 3, content: "three"),
          TestDiffable(identifier: 2, content: "2"),
          TestDiffable(identifier: 4, content: "4"),
          TestDiffable(identifier: 5, content: "5"),
          TestDiffable(identifier: 6, content: "6"),
          TestDiffable(identifier: 7, content: "7"),
        ]

        it("returns the correct changeset") {
          let changeset = otherTestDiffableArray.makeChangeset(from: testDiffableArray)
          expect(changeset.updates.count).to(equal(1))
          let firstUpdate = changeset.updates.filter { startIndex, _ in
            startIndex == 2
          }
          expect(firstUpdate.first).toNot(beNil())
          expect(firstUpdate.first!.new).to(equal(1))

          expect(changeset.moves.count).to(equal(2))

          let firstMove = changeset.moves.filter { startIndex, _ in
            startIndex == 2
          }
          expect(firstMove.first).toNot(beNil())
          expect(firstMove.first!.new).to(equal(1))

          expect(changeset.deletes).to(beEmpty())
          expect(changeset.inserts).to(beEmpty())
        }
      }

      context("when called on a collection with deletes and inserts") {
        let otherTestDiffableArray = [
          TestDiffable(identifier: 1, content: "1"),
          TestDiffable(identifier: 100, content: "100"),
          TestDiffable(identifier: 3, content: "3"),
          TestDiffable(identifier: 4, content: "4"),
          TestDiffable(identifier: 5, content: "5"),
          TestDiffable(identifier: 6, content: "6"),
          TestDiffable(identifier: 7, content: "7"),
        ]

        it("returns the correct changeset") {
          let changeset = otherTestDiffableArray.makeChangeset(from: testDiffableArray)
          expect(changeset.inserts.count).to(equal(1))
          expect(changeset.inserts.first).to(equal(1))
          expect(changeset.deletes.count).to(equal(1))
          expect(changeset.deletes.first).to(equal(1))
          expect(changeset.updates).to(beEmpty())
          expect(changeset.moves).to(beEmpty())
        }
      }
    }

    describe("makeSectionedChangeset") {
      context("with called on an identical collection") {
        it("returns an empty changeset") {
          let changeset = testSectionedDiffableArray.makeSectionedChangeset(
            from: testSectionedDiffableArray)

          expect(changeset.itemChangeset.inserts).to(beEmpty())
          expect(changeset.itemChangeset.deletes).to(beEmpty())
          expect(changeset.itemChangeset.updates).to(beEmpty())
          expect(changeset.itemChangeset.moves).to(beEmpty())
          expect(changeset.itemChangeset.isEmpty).to(beTrue())
          expect(changeset.itemChangeset.duplicates).to(beEmpty())

          expect(changeset.sectionChangeset.inserts).to(beEmpty())
          expect(changeset.sectionChangeset.deletes).to(beEmpty())
          expect(changeset.sectionChangeset.updates).to(beEmpty())
          expect(changeset.sectionChangeset.moves).to(beEmpty())
          expect(changeset.sectionChangeset.isEmpty).to(beTrue())
          expect(changeset.sectionChangeset.duplicates).to(beEmpty())

          expect(changeset.isEmpty).to(beTrue())
        }

        context("with duplicate section identifiers") {
          let otherTestSectionedDiffableArray = [
            TestDiffableSection(identifier: 1, items: testDiffableArray),
            TestDiffableSection(identifier: 2, items: testDiffableArray),
            TestDiffableSection(identifier: 2, items: testDiffableArray),
            TestDiffableSection(identifier: 3, items: testDiffableArray),
            TestDiffableSection(identifier: 3, items: testDiffableArray),
            TestDiffableSection(identifier: 3, items: testDiffableArray),
          ]

          it("returns the correct changeset") {
            let changeset = otherTestSectionedDiffableArray.makeSectionedChangeset(
              from: otherTestSectionedDiffableArray)
            expect(changeset.sectionChangeset.duplicates) == [
              [1, 2],
              [3, 4, 5],
            ]
            expect(changeset.itemChangeset.duplicates).to(beEmpty())
            expect(changeset.isEmpty).to(beTrue())
          }
        }

        context("with duplicate item identifiers") {
          let otherTestDiffableArray = [
            TestDiffable(identifier: 1, content: "1"),
            TestDiffable(identifier: 2, content: "2"),
            TestDiffable(identifier: 2, content: "3"),
            TestDiffable(identifier: 4, content: "4"),
            TestDiffable(identifier: 4, content: "5"),
            TestDiffable(identifier: 4, content: "6"),
            TestDiffable(identifier: 7, content: "7"),
          ]

          let otherTestSectionedDiffableArray = [
            TestDiffableSection(identifier: 1, items: otherTestDiffableArray),
            TestDiffableSection(identifier: 2, items: testDiffableArray),
          ]

          it("returns the correct changeset") {
            let changeset = otherTestSectionedDiffableArray.makeSectionedChangeset(
              from: otherTestSectionedDiffableArray)
            expect(changeset.itemChangeset.duplicates) == [
              [[0, 1], [0, 2]],
              [[0, 3], [0, 4], [0, 5]],
            ]
            expect(changeset.sectionChangeset.duplicates).to(beEmpty())
            expect(changeset.isEmpty).to(beTrue())
          }
        }
      }

      context("with called on a collection with section insertions") {
        let otherTestSectionedDiffableArray = [
          TestDiffableSection(identifier: 1, items: testDiffableArray),
          TestDiffableSection(identifier: 2, items: testDiffableArray),
          TestDiffableSection(identifier: 3, items: testDiffableArray),
          TestDiffableSection(identifier: 4, items: testDiffableArray),
        ]

        it("returns the correct changeset") {
          let changeset = otherTestSectionedDiffableArray.makeSectionedChangeset(
            from: testSectionedDiffableArray)
          expect(changeset.itemChangeset.isEmpty).to(beTrue())

          expect(changeset.sectionChangeset.inserts).to(equal([3]))
          expect(changeset.sectionChangeset.deletes).to(beEmpty())
          expect(changeset.sectionChangeset.updates).to(beEmpty())
          expect(changeset.sectionChangeset.moves).to(beEmpty())
          expect(changeset.sectionChangeset.isEmpty).to(beFalse())
        }
      }

      context("with called on a collection with section deletions") {
        let otherTestSectionedDiffableArray = [
          TestDiffableSection(identifier: 1, items: testDiffableArray),
          TestDiffableSection(identifier: 2, items: testDiffableArray),
        ]

        it("returns the correct changeset") {
          let changeset = otherTestSectionedDiffableArray.makeSectionedChangeset(
            from: testSectionedDiffableArray)
          expect(changeset.itemChangeset.isEmpty).to(beTrue())

          expect(changeset.sectionChangeset.inserts).to(beEmpty())
          expect(changeset.sectionChangeset.deletes).to(equal([2]))
          expect(changeset.sectionChangeset.updates).to(beEmpty())
          expect(changeset.sectionChangeset.moves).to(beEmpty())
          expect(changeset.sectionChangeset.isEmpty).to(beFalse())
        }
      }

      context("with called on a collection with section moves") {
        let otherTestSectionedDiffableArray = [
          TestDiffableSection(identifier: 2, items: testDiffableArray),
          TestDiffableSection(identifier: 3, items: testDiffableArray),
          TestDiffableSection(identifier: 1, items: testDiffableArray),
        ]

        it("returns the correct changeset") {
          let changeset = otherTestSectionedDiffableArray.makeSectionedChangeset(
            from: testSectionedDiffableArray)
          expect(changeset.itemChangeset.isEmpty).to(beTrue())

          expect(changeset.sectionChangeset.moves).to(haveCount(3))

          expect(changeset.sectionChangeset.moves[0].old).to(equal(1))
          expect(changeset.sectionChangeset.moves[0].new).to(equal(0))

          expect(changeset.sectionChangeset.moves[1].old).to(equal(2))
          expect(changeset.sectionChangeset.moves[1].new).to(equal(1))

          expect(changeset.sectionChangeset.moves[2].old).to(equal(0))
          expect(changeset.sectionChangeset.moves[2].new).to(equal(2))

          expect(changeset.sectionChangeset.inserts).to(beEmpty())
          expect(changeset.sectionChangeset.deletes).to(beEmpty())
          expect(changeset.sectionChangeset.updates).to(beEmpty())
          expect(changeset.sectionChangeset.isEmpty).to(beFalse())
        }
      }
    }
  }
}
