// Created by eric_horacek on 3/15/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import Nimble
import Quick
import UIKit

final class EpoxyModelBuilderArraySpec: QuickSpec {
  typealias TestBuilder = EpoxyModelArrayBuilder<Int>

  struct BuilderTest {
    init(@TestBuilder _ build: @escaping () -> [Int]) {
      models = build()
    }
    var models: [Int]
  }

  override func spec() {
    context("with a single model expression") {
      it("should build the model") {
        let builder = BuilderTest {
          1
        }
        expect(builder.models) == [1]
      }
    }

    context("with multiple model expressions") {
      it("should build the models") {
        let builder = BuilderTest {
          1
          2
        }
        expect(builder.models) == [1, 2]
      }
    }

    context("with an array expression of models") {
      context("when non-empty") {
        it("should include the array models") {
          let builder = BuilderTest {
            [1, 2, 3]
            4
          }
          expect(builder.models) == [1, 2, 3, 4]
        }
      }

      context("when empty") {
        it("should omit the array models") {
          let builder = BuilderTest {
            []
            4
          }
          expect(builder.models) == [4]
        }
      }
    }

    context("with an optional expression of models") {
      context("that evaluates to a non-nil value") {
        it("should include the optional model") {
          let optionalInt: Int? = 1
          let builder = BuilderTest {
            optionalInt
            2
          }
          expect(builder.models) == [1, 2]
        }
      }

      context("that evaluates to a nil value") {
        it("should omit the optional model") {
          let optionalInt: Int? = nil
          let builder = BuilderTest {
            optionalInt
            2
          }
          expect(builder.models) == [2]
        }
      }
    }

    context("with an if condition") {
      context("when the condition is false") {
        it("should not include the model in the condition") {
          let condition = false
          let builder = BuilderTest {
            if condition {
              1
            }
            2
          }
          expect(builder.models) == [2]
        }
      }

      context("when the condition is true") {
        it("should include the model in the condition") {
          let condition = true
          let builder = BuilderTest {
            if condition {
              1
            }
            2
          }
          expect(builder.models) == [1, 2]
        }
      }
    }

    context("with an if-else condition") {
      context("when the condition is false") {
        it("should include the model in the else condition") {
          let condition = false
          let builder = BuilderTest {
            if condition {
              1
            } else {
              2
            }
            3
          }
          expect(builder.models) == [2, 3]
        }
      }

      context("when the condition is true") {
        it("should include the model in the if condition") {
          let condition = true
          let builder = BuilderTest {
            if condition {
              1
            } else {
              2
            }
            3
          }
          expect(builder.models) == [1, 3]
        }
      }
    }

    context("with a for loop") {
      it("should include the models in the loop") {
        let builder = BuilderTest {
          for dataID in 1...10 where dataID % 2 == 0 {
            dataID
          }
        }
        expect(builder.models) == [2, 4, 6, 8, 10]
      }
    }

    context("with no models") {
      it("should build an empty array") {
        let builder = BuilderTest {}
        expect(builder.models) == []
      }
    }
  }
}
