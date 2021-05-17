// Created by Tyler Hedrick on 4/12/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Nimble
import Quick
@testable import EpoxyLayoutGroups
import UIKit

final class VGroupSpec: QuickSpec {

  override func spec() {
    let initialItems = [
      TestView.groupItem(dataID: 1),
      TestView.groupItem(dataID: 2)
    ]
    var group: VGroup!

    beforeEach {
      let view = UIView(frame: .init(x: 0, y: 0, width: 320, height: 500))
      group = VGroup(items: initialItems)
      group.install(in: view)
      group.constrainToSuperview()
    }

    it("should render the provided views") {
      expect(group.items[0].dataID).to(be(1))
      expect(group.constrainableContainers[0].wrapped is TestView).to(beTrue())
      expect(group.items[1].dataID).to(be(2))
      expect(group.constrainableContainers[1].wrapped is TestView).to(beTrue())
    }

    // MARK: set items - no diffs

    describe("when setItems is called with the same items") {
      it("does not create new views") {
        let currentContainer1 = group.constrainableContainers[0]
        let currentContainer2 = group.constrainableContainers[1]
        group.setItems {
          TestView.groupItem(dataID: 1)
          TestView.groupItem(dataID: 2)
        }
        expect(currentContainer1.isEqual(to: group.constrainableContainers[0])).to(beTrue())
        expect(currentContainer2.isEqual(to: group.constrainableContainers[1])).to(beTrue())
      }
    }

    // MARK: set items - deletion

    describe("when setItems is called with an item deleted") {
      it("deletes that item") {
        let currentContainer = group.constrainableContainers[0]
        group.setItems {
          TestView.groupItem(dataID: 2)
        }
        expect(currentContainer.isEqual(to: group.constrainableContainers[0])).to(beFalse())
        expect(group.constrainableContainers).to(haveCount(1))
        expect(group.items[0].dataID).to(be(2))
      }
    }

    // MARK: set items - addition

    describe("when setItems is called with an item added") {
      it("adds that item") {
        group.setItems {
          TestView.groupItem(dataID: 1)
          TestView.groupItem(dataID: 2)
          TestView.groupItem(dataID: 3)
        }
        expect(group.constrainableContainers).to(haveCount(3))
        expect(group.items[2].dataID).to(be(3))
      }
    }

    // MARK: set items - move

    describe("when setItems is called with items moved") {
      it("moves those items") {
        let currentContainer1 = group.constrainableContainers[0]
        let currentContainer2 = group.constrainableContainers[1]
        group.setItems {
          TestView.groupItem(dataID: 2)
          TestView.groupItem(dataID: 1)
        }
        expect(group.constrainableContainers).to(haveCount(2))
        expect(group.items[0].dataID).to(be(2))
        expect(group.items[1].dataID).to(be(1))
        expect(currentContainer1.isEqual(to: group.constrainableContainers[1])).to(beTrue())
        expect(currentContainer2.isEqual(to: group.constrainableContainers[0])).to(beTrue())
      }
    }

    // MARK: set items - content change

    describe("when setItems is called with the items that have content changes") {
      beforeEach {
        group = VGroup() {
          TestLabel.groupItem(dataID: 1, content: .init(text: "Title"))
        }
      }

      it("does not create new views and updates the content") {
        let currentContainer1 = group.constrainableContainers[0]
        group.setItems {
          TestLabel.groupItem(dataID: 1, content: .init(text: "New title"))
        }
        expect(currentContainer1.isEqual(to: group.constrainableContainers[0])).to(beTrue())
        expect((currentContainer1.wrapped as! TestLabel).text).to(be("New title"))
      }
    }
  }
}
