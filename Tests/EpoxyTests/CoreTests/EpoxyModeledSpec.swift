// Created by eric_horacek on 12/1/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore
import Nimble
import Quick

// MARK: - EpoxyModeledSpec

// swiftlint:disable implicitly_unwrapped_optional

final class EpoxyModeledSpec: QuickSpec {
  override func spec() {
    var model: TestModel!

    beforeEach {
      model = TestModel()
    }

    describe("subscript") {
      describe("get") {
        context("when not previously set to a value") {
          it("should return the default value") {
            expect(model.testString) == "defaultValue"
          }
        }

        context("when previously set to a value") {
          beforeEach {
            model.testString = "value"
          }

          it("should return the previously set value") {
            expect(model.testString) == "value"
          }
        }
      }

      describe("set") {
        context("when updated to a new value") {
          context("with a replace updateStrategy") {
            it("should update the value") {
              model.testString = "value"
              expect(model.testString) == "value"
            }
          }

          context("with a chain updateStrategy") {
            context("with an arity of 0") {
              context("on the initial set") {
                it("should update the value") {
                  var called = false
                  model.testArity0Closure = { called = true }
                  model.testArity0Closure?()
                  expect(called) == true
                }
              }

              context("on a subsequent set") {
                it("should chain the old closure and the new closure") {
                  var calledOld = false
                  var calledNew = false
                  model.testArity0Closure = {
                    expect(calledNew) == false
                    calledOld = true
                  }
                  model.testArity0Closure = {
                    expect(calledOld) == true
                    calledNew = true
                  }
                  model.testArity0Closure?()
                  expect(calledOld) == true
                  expect(calledNew) == true
                }
              }
            }

            context("with an arity of 1") {
              context("on the initial set") {
                it("should update the value") {
                  var called = false
                  model.testArity1Closure = { _ in
                    called = true
                  }
                  model.testArity1Closure?("")
                  expect(called) == true
                }
              }

              context("on a subsequent set") {
                it("should chain the old closure and the new closure") {
                  var calledOld = false
                  var calledNew = false
                  model.testArity1Closure = { _ in
                    expect(calledNew) == false
                    calledOld = true
                  }
                  model.testArity1Closure = { _ in
                    expect(calledOld) == true
                    calledNew = true
                  }
                  model.testArity1Closure?("")
                  expect(calledOld) == true
                  expect(calledNew) == true
                }
              }
            }

            context("with an arity of 2") {
              context("on the initial set") {
                it("should update the value") {
                  var called = false
                  model.testArity2Closure = { _, _ in
                    called = true
                  }
                  model.testArity2Closure?("", "")
                  expect(called) == true
                }
              }

              context("on a subsequent set") {
                it("should chain the old closure and the new closure") {
                  var calledOld = false
                  var calledNew = false
                  model.testArity2Closure = { _, _ in
                    expect(calledNew) == false
                    calledOld = true
                  }
                  model.testArity2Closure = { _, _ in
                    expect(calledOld) == true
                    calledNew = true
                  }
                  model.testArity2Closure?("", "")
                  expect(calledOld) == true
                  expect(calledNew) == true
                }
              }
            }

            context("with an arity of 3") {
              context("on the initial set") {
                it("should update the value") {
                  var called = false
                  model.testArity3Closure = { _, _, _ in
                    called = true
                  }
                  model.testArity3Closure?("", "", "")
                  expect(called) == true
                }
              }

              context("on a subsequent set") {
                it("should chain the old closure and the new closure") {
                  var calledOld = false
                  var calledNew = false
                  model.testArity3Closure = { _, _, _ in
                    expect(calledNew) == false
                    calledOld = true
                  }
                  model.testArity3Closure = { _, _, _ in
                    expect(calledOld) == true
                    calledNew = true
                  }
                  model.testArity3Closure?("", "", "")
                  expect(calledOld) == true
                  expect(calledNew) == true
                }
              }
            }

            context("with an arity of 4") {
              context("on the initial set") {
                it("should update the value") {
                  var called = false
                  model.testArity4Closure = { _, _, _, _ in
                    called = true
                  }
                  model.testArity4Closure?("", "", "", "")
                  expect(called) == true
                }
              }

              context("on a subsequent set") {
                it("should chain the old closure and the new closure") {
                  var calledOld = false
                  var calledNew = false
                  model.testArity4Closure = { _, _, _, _ in
                    expect(calledNew) == false
                    calledOld = true
                  }
                  model.testArity4Closure = { _, _, _, _ in
                    expect(calledOld) == true
                    calledNew = true
                  }
                  model.testArity4Closure?("", "", "", "")
                  expect(calledOld) == true
                  expect(calledNew) == true
                }
              }
            }
          }
        }
      }
    }

    describe("copy(updating:to:)") {
      it("should return a new model with the property updated to the new value") {
        let newModel = model.testString("newValue")
        expect(model.testString) != newModel.testString
        expect(newModel.testString) == "newValue"
      }
    }

    describe("merging(_:)") {
      context("when merging into an empty model") {
        context("with a replace updateStrategy") {
          it("should return a new model with the properties of the other model") {
            let otherModel = TestModel().testString("newValue")
            let mergedModel = model.merging(otherModel)
            expect(mergedModel.testString) == "newValue"
          }
        }

        context("with a chain updateStrategy") {
          it("should return a new model with the properties of the other model") {
            var called = false

            let otherModel = TestModel().testArity0Closure { called = true }

            let mergedModel = model.merging(otherModel)
            mergedModel.testArity0Closure?()

            expect(called) == true
          }
        }
      }

      context("when merging into a populated model") {
        context("with a replace updateStrategy") {
          it("should return a new model with the properties of the other model") {
            model.testString = "oldValue"
            let otherModel = TestModel().testString("newValue")
            let mergedModel = model.merging(otherModel)
            expect(mergedModel.testString) == "newValue"
          }
        }

        context("with a chain updateStrategy") {
          it("should return a new model with the properties of the other model") {
            var calledOld = false
            var calledNew = false

            model.testArity0Closure = { calledOld = true }
            let otherModel = TestModel().testArity0Closure { calledNew = true }
            let mergedModel = model.merging(otherModel)
            mergedModel.testArity0Closure?()

            expect(calledOld) == true
            expect(calledNew) == true
          }
        }
      }
    }
  }
}

// MARK: - TestStringProviding

private protocol TestStringProviding {
  var testString: String? { get }
}

// MARK: - TestArity0ClosureProviding

private protocol TestArity0ClosureProviding {
  var testArity0Closure: (() -> Void)? { get }
}

// MARK: - TestArity1ClosureProviding

private protocol TestArity1ClosureProviding {
  var testArity1Closure: ((String) -> Void)? { get }
}

// MARK: - TestArity2ClosureProviding

private protocol TestArity2ClosureProviding {
  var testArity2Closure: ((String, String) -> Void)? { get }
}

// MARK: - TestArity3ClosureProviding

private protocol TestArity3ClosureProviding {
  var testArity3Closure: ((String, String, String) -> Void)? { get }
}

// MARK: - TestArity4ClosureProviding

private protocol TestArity4ClosureProviding {
  var testArity4Closure: ((String, String, String, String) -> Void)? { get }
}

// MARK: - EpoxyModeled

extension EpoxyModeled where Self: TestStringProviding {
  var testString: String? {
    get { self[testStringProperty] }
    set { self[testStringProperty] = newValue }
  }

  var testStringProperty: EpoxyModelProperty<String?> {
    .init(keyPath: \Self.testString, defaultValue: "defaultValue", updateStrategy: .replace)
  }

  func testString(_ value: String?) -> Self {
    copy(updating: testStringProperty, to: value)
  }

}

extension EpoxyModeled where Self: TestArity0ClosureProviding {
  var testArity0Closure: (() -> Void)? {
    get { self[testArity0ClosureProperty] }
    set { self[testArity0ClosureProperty] = newValue }
  }

  var testArity0ClosureProperty: EpoxyModelProperty<(() -> Void)?> {
    EpoxyModelProperty(
      keyPath: \Self.testArity0Closure,
      defaultValue: nil,
      updateStrategy: .chain())
  }

  func testArity0Closure(_ value: (() -> Void)?) -> Self {
    copy(updating: testArity0ClosureProperty, to: value)
  }

}

extension EpoxyModeled where Self: TestArity1ClosureProviding {
  var testArity1Closure: ((String) -> Void)? {
    get { self[testArity1ClosureProperty] }
    set { self[testArity1ClosureProperty] = newValue }
  }

  var testArity1ClosureProperty: EpoxyModelProperty<((String) -> Void)?> {
    EpoxyModelProperty(
      keyPath: \Self.testArity1Closure,
      defaultValue: nil,
      updateStrategy: .chain())
  }

  func testArity1Closure(_ value: ((String) -> Void)?) -> Self {
    copy(updating: testArity1ClosureProperty, to: value)
  }

}

extension EpoxyModeled where Self: TestArity2ClosureProviding {
  var testArity2Closure: ((String, String) -> Void)? {
    get { self[testArity2ClosureProperty] }
    set { self[testArity2ClosureProperty] = newValue }
  }

  var testArity2ClosureProperty: EpoxyModelProperty<((String, String) -> Void)?> {
    EpoxyModelProperty(
      keyPath: \Self.testArity2Closure,
      defaultValue: nil,
      updateStrategy: .chain())
  }

  func testArity2Closure(_ value: ((String, String) -> Void)?) -> Self {
    copy(updating: testArity2ClosureProperty, to: value)
  }

}

extension EpoxyModeled where Self: TestArity3ClosureProviding {
  var testArity3Closure: ((String, String, String) -> Void)? {
    get { self[testArity3ClosureProperty] }
    set { self[testArity3ClosureProperty] = newValue }
  }

  var testArity3ClosureProperty: EpoxyModelProperty<((String, String, String) -> Void)?> {
    EpoxyModelProperty(
      keyPath: \Self.testArity3Closure,
      defaultValue: nil,
      updateStrategy: .chain())
  }

  func testArity3Closure(_ value: ((String, String, String) -> Void)?) -> Self {
    copy(updating: testArity3ClosureProperty, to: value)
  }

}

extension EpoxyModeled where Self: TestArity4ClosureProviding {
  var testArity4Closure: ((String, String, String, String) -> Void)? {
    get { self[testArity4ClosureProperty] }
    set { self[testArity4ClosureProperty] = newValue }
  }

  var testArity4ClosureProperty: EpoxyModelProperty<((String, String, String, String) -> Void)?> {
    EpoxyModelProperty(
      keyPath: \Self.testArity4Closure,
      defaultValue: nil,
      updateStrategy: .chain())
  }

  func testArity4Closure(_ value: ((String, String, String, String) -> Void)?) -> Self {
    copy(updating: testArity4ClosureProperty, to: value)
  }

}

// MARK: - TestModel

private struct TestModel: EpoxyModeled {
  var storage = EpoxyModelStorage()
}

// MARK: TestStringProviding

extension TestModel: TestStringProviding { }

// MARK: TestArity0ClosureProviding

extension TestModel: TestArity0ClosureProviding { }

// MARK: TestArity1ClosureProviding

extension TestModel: TestArity1ClosureProviding { }

// MARK: TestArity2ClosureProviding

extension TestModel: TestArity2ClosureProviding { }

// MARK: TestArity3ClosureProviding

extension TestModel: TestArity3ClosureProviding { }

// MARK: TestArity4ClosureProviding

extension TestModel: TestArity4ClosureProviding { }
