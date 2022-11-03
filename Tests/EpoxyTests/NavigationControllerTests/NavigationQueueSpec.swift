// Created by eric_horacek on 10/26/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import EpoxyCore
import Nimble
import Quick
import UIKit

@testable import EpoxyNavigationController

// MARK: - NavigationQueueSpec

// swiftlint:disable implicitly_unwrapped_optional

final class NavigationQueueSpec: QuickSpec {

  override func spec() {
    enum NavigationID {
      case one, two
    }

    var queue: NavigationQueue!
    var presenter: MockNavigationController!
    var presented: UIViewController!
    var didShow: [UIViewController]!
    var didHide: [Void]!
    var didAdd: [UIViewController]!
    var didRemove: [Void]!

    var boolAddedBacking: Bool!
    var boolModel: NavigationModel!

    var optionalAddedBacking: Int?
    var optionalModel: NavigationModel!

    beforeEach {
      queue = NavigationQueue()
      presenter = MockNavigationController()
      presented = UIViewController()
      didShow = []
      didHide = []
      didAdd = []
      didRemove = []

      boolAddedBacking = true
      boolModel = NavigationModel(
        dataID: NavigationID.one,
        makeViewController: { presented },
        remove: { boolAddedBacking = false })
        .didShow { didShow.append($0) }
        .didHide { didHide.append(()) }
        .didAdd { didAdd.append($0) }
        .didRemove { didRemove.append(()) }

      optionalAddedBacking = 1
      optionalModel = NavigationModel(
        params: optionalAddedBacking,
        dataID: NavigationID.one,
        makeViewController: { _ in presented },
        remove: { optionalAddedBacking = nil })
        .didShow { didShow.append($0) }
        .didHide { didHide.append(()) }
        .didAdd { didAdd.append($0) }
        .didRemove { didRemove.append(()) }
    }

    afterEach {
      _ = queue
      queue = nil
      presenter = nil
      presented = nil

      didShow = nil
      didHide = nil
      didAdd = nil
      didRemove = nil

      boolAddedBacking = nil
      boolModel = nil

      optionalAddedBacking = nil
      optionalModel = nil
    }

    describe("enqueue") {
      context("with an empty stack") {
        context("with a currently presented model") {
          it("should dismiss") {
            queue.enqueue([boolModel], animated: true, from: presenter)

            expect(presenter.stack?.viewControllers).to(haveCount(1))
            expect(presenter.stack?.viewControllers.first) === presented

            presenter.completeTransition()

            queue.enqueue([], animated: true, from: presenter)

            expect(presenter.stack?.viewControllers).to(haveCount(0))
          }
        }
      }

      context("with a non-empty stack") {
        context("when not currently transitioning") {
          context("with a bool backing") {
            context("with a true value") {
              it("should add the model") {
                queue.enqueue([boolModel], animated: true, from: presenter)

                expect(presenter.stack?.viewControllers).to(haveCount(1))
                expect(presenter.stack?.viewControllers.first) === presented
              }

              context("with a made navigation controller") {
                var navigationController: UINavigationController!

                beforeEach {
                  navigationController = UINavigationController()
                  boolModel = NavigationModel(
                    dataID: NavigationID.one,
                    makeViewController: { navigationController },
                    remove: { boolAddedBacking = false })
                    .didShow { didShow.append($0) }
                    .didHide { didHide.append(()) }
                    .didAdd { didAdd.append($0) }
                    .didRemove { didRemove.append(()) }
                }

                it("should present the wrapper view controller") {
                  queue.enqueue([boolModel], animated: true, from: presenter)

                  expect(presenter.stack?.viewControllers).to(haveCount(1))
                  expect(presenter.stack?.viewControllers.first) === presenter.wrapper
                  expect(presenter.stack?.viewControllers.first) !== navigationController
                }

                it("should call didShow with the wrapped view controller") {
                  queue.enqueue([boolModel], animated: true, from: presenter)
                  presenter.completeTransition()
                  expect(didShow.first) === navigationController
                }

                it("should call didAdd with the wrapped view controller") {
                  queue.enqueue([boolModel], animated: true, from: presenter)
                  presenter.completeTransition()
                  expect(didAdd.first) === navigationController
                }
              }

              context("followed by a model with a true bool backing") {
                context("with the same data ID") {
                  it("should stay added") {
                    queue.enqueue([boolModel], animated: true, from: presenter)

                    expect(presenter.stack?.viewControllers).to(haveCount(1))
                    expect(presenter.stack?.viewControllers.first) === presented

                    presenter.completeTransition()

                    let anotherViewController = UIViewController()
                    let anotherBoolModel = NavigationModel(
                      dataID: NavigationID.one,
                      makeViewController: { anotherViewController },
                      remove: { boolAddedBacking = false })

                    queue.enqueue([anotherBoolModel], animated: true, from: presenter)

                    expect(presenter.stack?.viewControllers).to(haveCount(1))
                    expect(presenter.stack?.viewControllers.first) === presented
                    expect(presenter.stack?.viewControllers.first) !== anotherViewController
                  }
                }

                context("with a different data ID") {
                  it("should add the new model") {
                    queue.enqueue([boolModel], animated: true, from: presenter)

                    expect(presenter.stack?.viewControllers).to(haveCount(1))
                    expect(presenter.stack?.viewControllers.first) === presented

                    presenter.completeTransition()

                    let anotherViewController = UIViewController()
                    let anotherBoolModel = NavigationModel(
                      dataID: NavigationID.two,
                      makeViewController: { anotherViewController },
                      remove: { boolAddedBacking = false })

                    queue.enqueue([anotherBoolModel], animated: true, from: presenter)

                    expect(presenter.stack?.viewControllers).to(haveCount(1))
                    expect(presenter.stack?.viewControllers.first) !== presented
                    expect(presenter.stack?.viewControllers.first) === anotherViewController
                  }
                }
              }

              context("followed by a nil model") {
                it("should dismiss") {
                  queue.enqueue([boolModel], animated: true, from: presenter)

                  expect(presenter.stack?.viewControllers).to(haveCount(1))
                  expect(presenter.stack?.viewControllers.first) === presented

                  presenter.completeTransition()

                  boolAddedBacking = false

                  boolModel = NavigationModel(
                    dataID: NavigationID.one,
                    makeViewController: { presented },
                    remove: { boolAddedBacking = false })

                  queue.enqueue([], animated: true, from: presenter)

                  expect(presenter.stack?.viewControllers).to(haveCount(0))
                }
              }
            }

            context("with a nil model") {
              it("should not present the model") {
                queue.enqueue([], animated: true, from: presenter)

                expect(presenter.stack?.viewControllers).to(haveCount(0))
              }

              it("should present a subsequent model") {
                queue.enqueue([], animated: true, from: presenter)

                expect(presenter.stack?.viewControllers).to(haveCount(0))

                presenter.completeTransition()

                boolAddedBacking = true

                boolModel = NavigationModel(
                  dataID: NavigationID.one,
                  makeViewController: { presented },
                  remove: { boolAddedBacking = false })

                queue.enqueue([boolModel], animated: true, from: presenter)

                expect(presenter.stack?.viewControllers).to(haveCount(1))
                expect(presenter.stack?.viewControllers.first) === presented
              }
            }

            context("with a nil view controller") {
              beforeEach {
                boolModel = NavigationModel(
                  dataID: NavigationID.one,
                  makeViewController: { nil },
                  remove: { boolAddedBacking = false })
              }

              it("should not present the model") {
                queue.enqueue([boolModel], animated: true, from: presenter)

                expect(presenter.stack?.viewControllers).to(haveCount(0))
              }

              it("should present a subsequent model") {
                queue.enqueue([boolModel], animated: true, from: presenter)

                expect(presenter.stack?.viewControllers).to(haveCount(0))

                presenter.completeTransition()

                boolAddedBacking = true

                boolModel = NavigationModel(
                  dataID: NavigationID.one,
                  makeViewController: { presented },
                  remove: { boolAddedBacking = false })

                queue.enqueue([boolModel], animated: true, from: presenter)

                expect(presenter.stack?.viewControllers).to(haveCount(1))
                expect(presenter.stack?.viewControllers.first) === presented
              }
            }
          }

          context("with a optional backing") {
            context("with a Equatable value") {
              context("with a non-nil value") {
                it("should present the model") {
                  queue.enqueue([optionalModel], animated: true, from: presenter)

                  expect(presenter.stack?.viewControllers).to(haveCount(1))
                  expect(presenter.stack?.viewControllers.first) === presented
                }

                context("followed by a model with a non-nil value") {
                  context("with the same value") {
                    it("should stay added") {
                      queue.enqueue([optionalModel], animated: true, from: presenter)

                      expect(presenter.stack?.viewControllers).to(haveCount(1))
                      expect(presenter.stack?.viewControllers.first) === presented

                      presenter.completeTransition()

                      queue.enqueue([optionalModel], animated: true, from: presenter)

                      expect(presenter.stack?.viewControllers).to(haveCount(1))
                      expect(presenter.stack?.viewControllers.first) === presented
                    }
                  }

                  context("with a different value") {
                    it("should add the new value") {
                      queue.enqueue([optionalModel], animated: true, from: presenter)

                      expect(presenter.stack?.viewControllers).to(haveCount(1))
                      expect(presenter.stack?.viewControllers.first) === presented

                      presenter.completeTransition()

                      let otherPresented = UIViewController()
                      var otherPresentedBacking: Int? = 2
                      let otherModel = NavigationModel(
                        params: otherPresentedBacking,
                        dataID: NavigationID.one,
                        makeViewController: { _ in otherPresented },
                        remove: { otherPresentedBacking = nil })

                      queue.enqueue([otherModel], animated: true, from: presenter)

                      expect(presenter.stack?.viewControllers).to(haveCount(1))
                      expect(presenter.stack?.viewControllers.first) === otherPresented
                      expect(presenter.stack?.viewControllers.first) !== presented
                    }
                  }
                }
              }

              context("with a nil model") {
                it("should not present the model") {
                  queue.enqueue([], animated: true, from: presenter)

                  expect(presenter.stack?.viewControllers).to(haveCount(0))
                }

                context("followed by a model with a non-nil value") {
                  it("should present") {
                    queue.enqueue([], animated: true, from: presenter)

                    expect(presenter.stack?.viewControllers).to(haveCount(0))

                    presenter.completeTransition()

                    optionalAddedBacking = 1

                    optionalModel = NavigationModel(
                      params: optionalAddedBacking,
                      dataID: NavigationID.one,
                      makeViewController: { _ in presented },
                      remove: { optionalAddedBacking = nil })

                    queue.enqueue([optionalModel], animated: true, from: presenter)

                    expect(presenter.stack?.viewControllers).to(haveCount(1))
                    expect(presenter.stack?.viewControllers.first) === presented
                  }
                }

                context("followed by a model with a nil view controller") {
                  context("with the same value") {
                    it("should not show the view controllers") {
                      queue.enqueue([], animated: true, from: presenter)

                      expect(presenter.stack?.viewControllers).to(haveCount(0))

                      presenter.completeTransition()

                      optionalAddedBacking = 1

                      optionalModel = NavigationModel(
                        params: optionalAddedBacking,
                        dataID: NavigationID.one,
                        makeViewController: { _ in nil },
                        remove: { optionalAddedBacking = nil })

                      queue.enqueue([optionalModel], animated: true, from: presenter)

                      expect(presenter.stack?.viewControllers).to(haveCount(0))
                    }
                  }
                }
              }

              context("with a nil view controller") {
                context("followed by a model with a different value and a nil view controller") {
                  it("should not show the view controllers") {
                    queue.enqueue([optionalModel], animated: true, from: presenter)

                    expect(presenter.stack?.viewControllers).to(haveCount(1))
                    expect(presenter.stack?.viewControllers.first) === presented

                    presenter.completeTransition()

                    optionalAddedBacking = 2
                    optionalModel = NavigationModel(
                      params: optionalAddedBacking,
                      dataID: NavigationID.one,
                      makeViewController: { _ in nil },
                      remove: { optionalAddedBacking = nil })

                    queue.enqueue([optionalModel], animated: true, from: presenter)

                    expect(presenter.stack?.viewControllers).to(haveCount(0))
                  }
                }

                context("followed by a model with a different value and a non-nil view controller") {
                  it("should not show the view controllers") {
                    optionalModel = NavigationModel(
                      params: optionalAddedBacking,
                      dataID: NavigationID.one,
                      makeViewController: { _ in nil },
                      remove: { optionalAddedBacking = nil })

                    queue.enqueue([optionalModel], animated: true, from: presenter)

                    expect(presenter.stack?.viewControllers).to(haveCount(0))

                    presenter.completeTransition()

                    optionalAddedBacking = 2
                    optionalModel = NavigationModel(
                      params: optionalAddedBacking,
                      dataID: NavigationID.one,
                      makeViewController: { _ in presented },
                      remove: { optionalAddedBacking = nil })

                    queue.enqueue([optionalModel], animated: true, from: presenter)

                    expect(presenter.stack?.viewControllers).to(haveCount(1))
                    expect(presenter.stack?.viewControllers.first) === presented
                  }
                }
              }

              context("with a nil view controller") {
                beforeEach {
                  optionalModel = NavigationModel(
                    params: optionalAddedBacking,
                    dataID: NavigationID.one,
                    makeViewController: { _ in nil },
                    remove: { optionalAddedBacking = nil })
                }

                it("should not present the model") {
                  queue.enqueue([optionalModel], animated: true, from: presenter)

                  expect(presenter.stack?.viewControllers).to(haveCount(0))
                }

                context("followed by a model with a non-nil value") {
                  it("should present") {
                    queue.enqueue([optionalModel], animated: true, from: presenter)

                    expect(presenter.stack?.viewControllers).to(haveCount(0))

                    presenter.completeTransition()

                    optionalAddedBacking = 1

                    optionalModel = NavigationModel(
                      params: optionalAddedBacking,
                      dataID: NavigationID.one,
                      makeViewController: { _ in presented },
                      remove: { optionalAddedBacking = nil })

                    queue.enqueue([optionalModel], animated: true, from: presenter)

                    expect(presenter.stack?.viewControllers).to(haveCount(1))
                    expect(presenter.stack?.viewControllers.first) === presented
                  }
                }
              }
            }
          }

          context("with multiple models") {
            var anotherAddedBacking: Bool!
            var anotherPresented: UIViewController!
            var anotherModel: NavigationModel!
            var anotherDidShow: [UIViewController]!
            var anotherDidRemove: [Void]!

            var yetAnotherAddedBacking: Bool!
            var yetAnotherPresented: UIViewController!
            var yetAnotherModel: NavigationModel!
            var yetAnotherDidShow: [UIViewController]!
            var yetAnotherDidHide: [Void]!
            var yetAnotherDidAdd: [UIViewController]!
            var yetAnotherDidRemove: [Void]!

            beforeEach {
              anotherDidShow = []
              anotherDidRemove = []
              anotherAddedBacking = true
              anotherPresented = UIViewController()
              anotherModel = NavigationModel(
                dataID: NavigationID.two,
                makeViewController: { anotherPresented },
                remove: { anotherAddedBacking = false })
                .didShow { anotherDidShow.append($0) }
                .didRemove { anotherDidRemove.append(()) }

              yetAnotherDidShow = []
              yetAnotherDidRemove = []
              yetAnotherDidAdd = []
              yetAnotherDidHide = []
              yetAnotherAddedBacking = true
              yetAnotherPresented = UIViewController()
              yetAnotherModel = NavigationModel(
                dataID: "3",
                makeViewController: { yetAnotherPresented },
                remove: { yetAnotherAddedBacking = false })
                .didShow { yetAnotherDidShow.append($0) }
                .didHide { yetAnotherDidHide.append(()) }
                .didAdd { yetAnotherDidAdd.append($0) }
                .didRemove { yetAnotherDidRemove.append(()) }
            }

            afterEach {
              _ = anotherAddedBacking
              anotherAddedBacking = nil
              anotherPresented = nil
              anotherModel = nil
              anotherDidRemove = nil
              anotherDidShow = nil

              _ = yetAnotherAddedBacking
              yetAnotherAddedBacking = nil
              yetAnotherPresented = nil
              yetAnotherModel = nil
              yetAnotherDidShow = nil
              yetAnotherDidHide = nil
              yetAnotherDidAdd = nil
              yetAnotherDidRemove = nil
            }

            context("when moving models") {
              var expected: [UIViewController]!

              beforeEach {
                let models: [NavigationModel] = [optionalModel, anotherModel, yetAnotherModel]
                queue.enqueue(models, animated: true, from: presenter)

                expected = [presented, anotherPresented, yetAnotherPresented]
                expect(presenter.stack?.viewControllers.elementsEqual(expected, by: ===)).to(beTrue())

                presenter.completeTransition()

                let subsequentModels: [NavigationModel] = models.reversed()
                queue.enqueue(subsequentModels, animated: true, from: presenter)
              }

              afterEach {
                expected = nil
              }

              it("should move view controllers corresponding to moved models") {
                let subsequentExpected: [UIViewController] = expected.reversed()
                expect(presenter.stack?.viewControllers.elementsEqual(subsequentExpected, by: ===)).to(beTrue())
              }

              it("should call didShow for the new top") {
                expect(didShow).to(haveCount(0))

                presenter.completeTransition()

                expect(didShow).to(haveCount(1))
              }

              it("should call didHide for the old top") {
                expect(yetAnotherDidHide).to(haveCount(0))

                presenter.completeTransition()

                expect(yetAnotherDidHide).to(haveCount(1))
              }
            }

            context("when inserting models") {
              beforeEach {
                let models: [NavigationModel] = [anotherModel]
                queue.enqueue(models, animated: true, from: presenter)

                let expected = [anotherPresented]
                expect(presenter.stack?.viewControllers.elementsEqual(expected, by: ===)).to(beTrue())

                presenter.completeTransition()

                let subsequentModels: [NavigationModel] = [optionalModel, anotherModel, yetAnotherModel]
                queue.enqueue(subsequentModels, animated: true, from: presenter)
              }

              it("should insert view controllers corresponding to inserted models") {
                let subsequentExpected: [UIViewController] = [presented, anotherPresented, yetAnotherPresented]
                expect(presenter.stack?.viewControllers.elementsEqual(subsequentExpected, by: ===)).to(beTrue())
              }

              it("should call didAdd for the inserted models") {
                expect(didAdd).to(haveCount(0))
                expect(yetAnotherDidAdd).to(haveCount(0))

                presenter.completeTransition()

                expect(didAdd).to(haveCount(1))
                expect(yetAnotherDidAdd).to(haveCount(1))
              }
            }

            context("when removing models") {
              beforeEach {
                let models: [NavigationModel] = [optionalModel, anotherModel, yetAnotherModel]
                queue.enqueue(models, animated: true, from: presenter)

                let expected = [presented, anotherPresented, yetAnotherPresented]
                expect(presenter.stack?.viewControllers.elementsEqual(expected, by: ===)).to(beTrue())

                presenter.completeTransition()

                let subsequentModels: [NavigationModel] = [anotherModel]
                queue.enqueue(subsequentModels, animated: true, from: presenter)
              }

              it("should remove view controllers corresponding to removed models") {
                let subsequentExpected: [UIViewController] = [anotherPresented]
                expect(presenter.stack?.viewControllers.elementsEqual(subsequentExpected, by: ===)).to(beTrue())
              }

              it("should call didRemove for the removed models") {
                expect(didRemove).to(haveCount(0))
                expect(yetAnotherDidRemove).to(haveCount(0))

                presenter.completeTransition()

                expect(didRemove).to(haveCount(1))
                expect(yetAnotherDidRemove).to(haveCount(1))
              }

              it("should call didShow for the new top") {
                expect(anotherDidShow).to(haveCount(0))

                presenter.completeTransition()

                expect(anotherDidShow).to(haveCount(1))
              }

              it("should call didHide for the old top") {
                expect(yetAnotherDidHide).to(haveCount(0))

                presenter.completeTransition()

                expect(yetAnotherDidHide).to(haveCount(1))
              }
            }
          }
        }

        context("when currently transitioning") {
          beforeEach {
            presenter.coordinator = StubTransitionCoordinator()
          }

          it("should not add the model") {
            queue.enqueue([optionalModel], animated: true, from: presenter)

            expect(presenter.stack?.viewControllers).to(beNil())
          }

          context("with a transition coordinator") {
            it("should add the model on its completion") {
              queue.enqueue([optionalModel], animated: true, from: presenter)

              expect(presenter.stack?.viewControllers).to(beNil())

              presenter.completeTransition()

              expect(presenter.stack?.viewControllers).to(haveCount(1))
              expect(presenter.stack?.viewControllers.first) === presented
            }
          }
        }

        context("non-animated") {
          it("should add the model") {
            queue.enqueue([optionalModel], animated: false, from: presenter)

            expect(presenter.stack?.viewControllers).to(haveCount(1))
            expect(presenter.stack?.viewControllers.first) === presented
          }
        }

        context("when setting a model during a pop transition") {
          beforeEach {
            queue.enqueue([optionalModel], animated: true, from: presenter)
            presenter.completeTransition()

            expect(presenter.stack?.viewControllers).to(haveCount(1))
            expect(presenter.stack?.viewControllers.first) === presented

            // Clear this out after the presentation has completed.
            presenter.stack = nil
          }

          context("with the same model") {
            it("should skip an equivalent set model during a pop") {
              let coordinator = StubTransitionCoordinator()
              presenter.coordinator = coordinator

              queue.enqueue([optionalModel], animated: true, from: presenter)

              queue.didPop([presented], animated: true, from: presenter)

              presenter.completeTransition()

              expect(presenter.stack?.viewControllers).to(beEmpty())
            }
          }

          context("with a different model") {
            var anotherBoolModel: NavigationModel!
            var anotherViewController: UIViewController!

            beforeEach {
              anotherViewController = UIViewController()
              anotherBoolModel = NavigationModel(
                dataID: NavigationID.two,
                makeViewController: { anotherViewController },
                remove: { boolAddedBacking = false })
            }

            it("should show a new set model during a pop once complete") {
              let coordinator = StubTransitionCoordinator()
              presenter.coordinator = coordinator

              queue.enqueue([anotherBoolModel], animated: true, from: presenter)

              queue.didPop([presented], animated: true, from: presenter)

              presenter.completeTransition()

              expect(presenter.stack?.viewControllers).to(haveCount(1))
              expect(presenter.stack?.viewControllers.first) === anotherViewController
            }
          }
        }
      }
    }

    describe("didPop") {
      context("with a stack") {
        context("with an optional model at the top") {
          beforeEach {
            let models: [NavigationModel] = [optionalModel]
            queue.enqueue(models, animated: true, from: presenter)

            expect(presenter.stack?.viewControllers).to(haveCount(1))
            expect(presenter.stack?.viewControllers.first) === presented

            presenter.completeTransition()
          }

          context("animated") {
            it("should set the backing of the top model to nil") {
              expect(optionalAddedBacking) == 1

              let coordinator = StubTransitionCoordinator()
              presenter.coordinator = coordinator

              queue.didPop([presented], animated: true, from: presenter)

              coordinator.complete()
              presenter.coordinator = nil

              expect(optionalAddedBacking).to(beNil())
            }
          }

          context("non-animated") {
            it("should remove the top model") {
              expect(optionalAddedBacking) == 1

              queue.didPop([presented], animated: false, from: presenter)

              expect(optionalAddedBacking).to(beNil())
            }

            it("should call didHide for the popped model") {
              expect(didHide).to(haveCount(0))

              queue.didPop([presented], animated: false, from: presenter)

              expect(didHide).to(haveCount(1))
            }

            it("should call didRemove for the popped model") {
              expect(didRemove).to(haveCount(0))

              queue.didPop([presented], animated: false, from: presenter)

              expect(didRemove).to(haveCount(1))
            }

            it("should call didRemove once for the popped model after setting the updated stack") {
              expect(didRemove).to(haveCount(0))

              queue.didPop([presented], animated: false, from: presenter)

              expect(didRemove).to(haveCount(1))

              queue.enqueue([], animated: false, from: presenter)

              expect(didRemove).to(haveCount(1))
            }
          }
        }

        context("with an bool model at the top") {
          beforeEach {
            let models: [NavigationModel] = [boolModel]
            queue.enqueue(models, animated: true, from: presenter)

            expect(presenter.stack?.viewControllers).to(haveCount(1))
            expect(presenter.stack?.viewControllers.first) === presented

            presenter.completeTransition()
          }

          context("animated") {
            it("should set the backing of the top model to false") {
              expect(boolAddedBacking) == true

              let coordinator = StubTransitionCoordinator()
              presenter.coordinator = coordinator

              queue.didPop([presented], animated: true, from: presenter)

              coordinator.complete()
              presenter.coordinator = nil

              expect(boolAddedBacking) == false
            }
          }
        }

        context("with an model that's not in the stack") {
          context("with a model at the top") {
            beforeEach {
              let models: [NavigationModel] = [optionalModel]
              queue.enqueue(models, animated: true, from: presenter)

              expect(presenter.stack?.viewControllers).to(haveCount(1))
              expect(presenter.stack?.viewControllers.first) === presented

              presenter.completeTransition()
            }

            it("should throw an assertion") {
              let previous = EpoxyLogger.shared
              defer { EpoxyLogger.shared = previous }
              var failures = [String]()
              let stub = EpoxyLogger(assertionFailure: { message, _, _ in failures.append(message()) })
              EpoxyLogger.shared = stub

              expect(failures).to(beEmpty())
              queue.didPop([UIViewController()], animated: true, from: presenter)
              expect(failures).to(haveCount(1))
            }
          }

          context("with no model at the top") {
            it("should throw an assertion") {
              let previous = EpoxyLogger.shared
              defer { EpoxyLogger.shared = previous }
              var failures = [String]()
              let stub = EpoxyLogger(assertionFailure: { message, _, _ in failures.append(message()) })
              EpoxyLogger.shared = stub

              expect(failures).to(beEmpty())
              queue.didPop([UIViewController()], animated: true, from: presenter)
              expect(failures).to(haveCount(1))
            }
          }
        }
      }
    }
  }

}

// MARK: - MockNavigationController

final class MockNavigationController: NavigationInterface {

  var topViewController: UIViewController?

  var coordinator: StubTransitionCoordinator? = nil

  var stack: (viewControllers: [UIViewController], animated: Bool)?

  var wrappedNavigation: UINavigationController?
  var wrapper = UIViewController()

  var transitionCoordinator: UIViewControllerTransitionCoordinator? {
    coordinator
  }

  func setStack(_ stack: [UIViewController], animated: Bool) {
    if animated {
      coordinator = StubTransitionCoordinator()
    }
    self.stack = (viewControllers: stack, animated: animated)
  }

  func completeTransition() {
    let coordinator = coordinator
    self.coordinator = nil
    coordinator?.complete()
  }

  func wrapNavigation(_ navigationController: UINavigationController) -> UIViewController {
    wrappedNavigation = navigationController
    return wrapper
  }

}
