// Created by Tyler Hedrick on 4/12/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Nimble
import Quick
@testable import EpoxyLayoutGroups
import UIKit

final class GroupItemSpec: QuickSpec {

  override func spec() {
    var groupItem: GroupItem<TestLabel>!

    beforeEach {
      groupItem = TestLabel.groupItem(dataID: 1, content: .init(text: "text"))
    }

    describe("when modifiers are applied") {
      it("applies them at the time of creation") {
        let updatedItem = groupItem
          .accessibilityAlignment(.center)
          .horizontalAlignment(.center)
          .padding(.init(7))
          .verticalAlignment(.center)
        let constrainable = updatedItem.makeConstrainable()
        expect(constrainable is ConstrainableContainer).to(beTrue())
        expect((constrainable as! ConstrainableContainer).accessibilityAlignment)
          .to(equal(VGroup.ItemAlignment.center))
        expect((constrainable as! ConstrainableContainer).horizontalAlignment)
          .to(equal(VGroup.ItemAlignment.center))
        expect((constrainable as! ConstrainableContainer).padding)
          .to(equal(NSDirectionalEdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7)))
        expect((constrainable as! ConstrainableContainer).verticalAlignment)
          .to(equal(HGroup.ItemAlignment.center))
      }

      it("changes the diff identifier value - vertical alignment") {
        let updatedItem = groupItem.verticalAlignment(.center)
        expect(groupItem.diffIdentifier).toNot(equal(updatedItem.diffIdentifier))
      }

      it("changes the diff identifier value - horizontal alignment") {
        let updatedItem = groupItem.horizontalAlignment(.center)
        expect(groupItem.diffIdentifier).toNot(equal(updatedItem.diffIdentifier))
      }

      it("changes the diff identifier value - accessibility alignment") {
        let updatedItem = groupItem.accessibilityAlignment(.center)
        expect(groupItem.diffIdentifier).toNot(equal(updatedItem.diffIdentifier))
      }

      it("changes the diff identifier value - padding") {
        let updatedItem = groupItem.padding(.init(7))
        expect(groupItem.diffIdentifier).toNot(equal(updatedItem.diffIdentifier))
      }
    }

    it("uses content to calculate equality") {
      let other = TestLabel.groupItem(dataID: 1, content: .init(text: "Different"))
      expect(groupItem.isDiffableItemEqual(to: other)).to(beFalse())

      let otherEqual = TestLabel.groupItem(dataID: 1, content: .init(text: "text"))
      expect(groupItem.isDiffableItemEqual(to: otherEqual)).to(beTrue())
    }
  }

}
