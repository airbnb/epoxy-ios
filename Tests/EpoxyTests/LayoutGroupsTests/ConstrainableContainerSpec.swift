// Created by Tyler Hedrick on 5/26/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Nimble
import Quick
@testable import EpoxyLayoutGroups
import UIKit

final class ConstraniableContainerSpec: QuickSpec {

  override func spec() {
    var constrainable: Constrainable!

    beforeEach {
      constrainable = TestView()
        .accessibilityAlignment(.trailing)
        .horizontalAlignment(.center)
        .verticalAlignment(.top)
        .padding(5)
    }

    describe("when initializing a ConstrainableContainer with another Constrainable") {
      it("inherits the values of the provided Constrainable") {
        let wrapper = ConstrainableContainer(constrainable)
        expect(wrapper.accessibilityAlignment).to(equal(.trailing))
        expect(wrapper.horizontalAlignment).to(equal(.center))
        expect(wrapper.verticalAlignment).to(equal(.top))
        expect(wrapper.padding).to(equal(NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)))
      }
    }

  }

}
