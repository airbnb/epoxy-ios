// Created by eric_horacek on 10/22/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Nimble
import Quick
import UIKit

@testable import EpoxyPresentations

// MARK: - PresentationQueueSpec

final class PresentationQueueSpec: QuickSpec {

  override func spec() {
    enum PresentationID {
      case one, two
    }

    var queue: PresentationQueue!
    var presenter: MockPresentingViewController!
    var presented: MockPresentedViewController!

    var didPresent: [Void]!
    var didDismiss: [Void]!

    var boolPresentedBacking: Bool!
    var boolModel: PresentationModel!

    var optionalPresentedBacking: Int?
    var optionalModel: PresentationModel!

    var presentationContext: PresentationModel.Presentation.Context?

    beforeEach {
      queue = PresentationQueue()
      presenter = MockPresentingViewController()
      presented = MockPresentedViewController()

      didPresent = []
      didDismiss = []

      let presentation = PresentationModel.Presentation { presented in
        { context in
          presentationContext = context
          return PresentationModel.Presentation.system.present(presented)(context)
        }
      }

      boolPresentedBacking = true
      boolModel = PresentationModel(
        dataID: PresentationID.one,
        presentation: presentation,
        makeViewController: { presented },
        dismiss: { boolPresentedBacking = false })
        .didPresent { didPresent.append(()) }
        .didDismiss { didDismiss.append(()) }

      optionalPresentedBacking = 1
      optionalModel = PresentationModel(
        params: optionalPresentedBacking,
        dataID: PresentationID.one,
        presentation: presentation,
        makeViewController: { _ in presented },
        dismiss: { optionalPresentedBacking = nil })
        .didPresent { didPresent.append(()) }
        .didDismiss { didDismiss.append(()) }
    }

    afterEach {
      _ = queue
      queue = nil
      presenter = nil
      presented = nil

      didPresent = nil
      didDismiss = nil

      boolPresentedBacking = nil
      boolModel = nil

      optionalPresentedBacking = nil
      optionalModel = nil

      presentationContext = nil
    }

    describe("enqueue") {
      context("with a nil model") {
        context("with a currently presented model") {
          it("should dismiss") {
            presenter.setPresentation(boolModel, animated: true)

            expect(presenter.present?.presented) === presented
            expect(presenter.dismiss).to(beNil())

            presenter.completeTransition()
            presented.presenting = presenter

            presenter.setPresentation(nil, animated: true)

            expect(presenter.dismiss).toNot(beNil())
          }
        }

        context("with no currently presented model") {
          it("should have no effect") {
            presenter.setPresentation(nil, animated: true)
            expect(presenter.present).to(beNil())
            expect(presenter.dismiss).to(beNil())
          }
        }
      }

      context("with a non-nil model") {
        context("when not currently transitioning") {
          it("should present the model") {
            presenter.setPresentation(boolModel, animated: true)

            expect(presenter.present?.presented) === presented
          }

          context("with no params and a nil view controller") {
            it("should not present the model") {
              boolModel = PresentationModel(
                dataID: PresentationID.one,
                presentation: .system,
                makeViewController: { nil },
                dismiss: { boolPresentedBacking = false })

              presenter.setPresentation(boolModel, animated: true)

              expect(presenter.present?.presented).to(beNil())
            }
          }

          context("with params and a nil view controller") {
            it("should not present the model") {
              optionalPresentedBacking = nil
              optionalModel = PresentationModel(
                params: optionalPresentedBacking,
                dataID: PresentationID.one,
                presentation: .system,
                makeViewController: { _ in nil },
                dismiss: { optionalPresentedBacking = nil })

              presenter.setPresentation(optionalModel, animated: true)

              expect(presenter.present?.presented).to(beNil())
            }
          }

          context("on dismissal") {
            context("with a bool backing") {
              it("should set the backing to false") {
                presenter.setPresentation(boolModel, animated: true)

                expect(presenter.present?.presented) === presented
                expect(boolPresentedBacking) == true

                presentationContext?.didDismiss()

                expect(boolPresentedBacking) == false
              }
            }

            context("with an optional backing") {
              it("should set the backing to nil") {
                presenter.setPresentation(optionalModel, animated: true)

                expect(presenter.present?.presented) === presented
                expect(optionalPresentedBacking) == 1

                presentationContext?.didDismiss()

                expect(optionalPresentedBacking).to(beNil())
              }
            }
          }

          context("with the same dataID as the current model") {
            var otherPresented: MockPresentedViewController!
            var otherBoolPresentedBacking: Bool!
            var otherBoolModel: PresentationModel!
            var otherOptionalPresentedBacking: Int?
            var otherOptionalModel: PresentationModel!

            beforeEach {
              otherPresented = MockPresentedViewController()
              otherBoolPresentedBacking = true
              otherBoolModel = PresentationModel(
                dataID: PresentationID.one,
                presentation: .system,
                makeViewController: { otherPresented },
                dismiss: { otherBoolPresentedBacking = false })
              otherOptionalPresentedBacking = 2
              otherOptionalModel = PresentationModel(
                params: otherOptionalPresentedBacking,
                dataID: PresentationID.one,
                presentation: .system,
                makeViewController: { _ in otherPresented },
                dismiss: { otherOptionalPresentedBacking = nil })
            }

            afterEach {
              _ = otherBoolPresentedBacking
              otherPresented = nil
              otherBoolModel = nil
              otherOptionalModel = nil
              otherOptionalPresentedBacking = nil
            }

            context("when currently presented") {
              context("when a nil model") {
                it("should dismiss the current model") {
                  presenter.setPresentation(boolModel, animated: true)

                  expect(presenter.present?.presented) === presented
                  expect(presenter.dismiss).to(beNil())

                  presenter.completeTransition()
                  presented.presenting = presenter

                  presenter.setPresentation(nil, animated: true)

                  expect(presenter.dismiss).toNot(beNil())
                }
              }

              context("when a non-nil model") {
                context("with a bool backing") {
                  it("should keep the current presentation") {
                    presenter.setPresentation(boolModel, animated: true)

                    expect(presenter.present?.presented) === presented
                    expect(presenter.dismiss).to(beNil())

                    presenter.completeTransition()
                    presented.presenting = presenter

                    presenter.setPresentation(otherBoolModel, animated: true)

                    expect(presenter.present?.presented) === presented
                  }

                  it("should not set the previous model bool to false") {
                    presenter.setPresentation(boolModel, animated: true)

                    expect(presenter.present?.presented) === presented
                    expect(presenter.dismiss).to(beNil())

                    presenter.completeTransition()
                    presented.presenting = presenter

                    presenter.setPresentation(otherBoolModel, animated: true)

                    expect(boolPresentedBacking) == true
                  }
                }

                context("with an optional backing") {
                  context("with equal values") {
                    it("should keep the current presentation") {
                      presenter.setPresentation(optionalModel, animated: true)

                      expect(presenter.present?.presented) === presented
                      expect(presenter.dismiss).to(beNil())

                      presenter.completeTransition()
                      presented.presenting = presenter

                      presenter.setPresentation(otherOptionalModel, animated: true)

                      expect(presenter.present?.presented) === presented
                    }
                  }

                  context("with unequal values") {
                    it("should present the new model") {
                      presenter.setPresentation(optionalModel, animated: true)

                      expect(presenter.present?.presented) === presented
                      expect(presenter.dismiss).to(beNil())

                      presenter.completeTransition()
                      presented.presenting = presenter

                      presenter.setPresentation(otherOptionalModel, animated: true)

                      presenter.dismiss?.completion?()
                      presenter.completeTransition()

                      expect(presenter.present?.presented) === otherPresented
                    }

                    it("should not set the previous model params to nil") {
                      presenter.setPresentation(optionalModel, animated: true)

                      expect(presenter.present?.presented) === presented
                      expect(presenter.dismiss).to(beNil())

                      presenter.completeTransition()
                      presented.presenting = presenter

                      presenter.setPresentation(otherOptionalModel, animated: true)

                      presenter.dismiss?.completion?()

                      expect(optionalPresentedBacking).toNot(beNil())
                    }
                  }
                }
              }
            }

            context("when currently dismissed") {
              context("with a non-nil model") {
                it("should present the new model") {
                  presenter.setPresentation(boolModel, animated: true)

                  expect(presenter.present?.presented) === presented
                  expect(presenter.dismiss).to(beNil())

                  presenter.completeTransition()
                  presented.presenting = presenter

                  presentationContext?.didDismiss()

                  presenter.setPresentation(otherBoolModel, animated: true)

                  expect(presenter.present?.presented) === otherPresented
                }
              }

              context("with a nil view controller") {
                beforeEach {
                  otherBoolModel = PresentationModel(
                    dataID: PresentationID.one,
                    presentation: .system,
                    makeViewController: { nil },
                    dismiss: { otherBoolPresentedBacking = false })
                }

                it("should keep the current dismissal") {
                  presenter.setPresentation(boolModel, animated: true)

                  expect(presenter.present?.presented) === presented
                  expect(presenter.dismiss).to(beNil())

                  presenter.completeTransition()
                  presented.presenting = presenter
                  presenter.present = nil

                  presentationContext?.didDismiss()

                  presenter.setPresentation(otherBoolModel, animated: true)

                  expect(presenter.present?.presented).to(beNil())
                }
              }
            }
          }

          context("with a different dataID from the current model") {
            var otherModel: PresentationModel!
            var otherPresented: MockPresentedViewController!

            beforeEach {
              otherPresented = MockPresentedViewController()
              otherModel = PresentationModel(
                params: optionalPresentedBacking,
                dataID: PresentationID.two,
                presentation: .system,
                makeViewController: { _ in otherPresented },
                dismiss: { optionalPresentedBacking = nil })
            }

            afterEach {
              otherModel = nil
              otherPresented = nil
            }

            it("should dismiss the previous model") {
              presenter.setPresentation(boolModel, animated: true)

              expect(presenter.present?.presented) === presented
              expect(presenter.dismiss).to(beNil())

              presenter.completeTransition()
              presented.presenting = presenter

              presenter.setPresentation(otherModel, animated: true)

              expect(presenter.dismiss).toNot(beNil())
            }

            it("should set the previous model's backing to dismissed") {
              presenter.setPresentation(boolModel, animated: true)

              expect(presenter.present?.presented) === presented
              expect(presenter.dismiss).to(beNil())

              presenter.completeTransition()
              presented.presenting = presenter

              presenter.setPresentation(otherModel, animated: true)

              presentationContext?.didDismiss()
              presenter.dismiss?.completion?()
              presenter.completeTransition()

              expect(boolPresentedBacking) == false
            }

            context("when still presented") {
              it("should present the different model") {
                presenter.setPresentation(boolModel, animated: true)

                expect(presenter.present?.presented) === presented
                expect(presenter.dismiss).to(beNil())

                presenter.completeTransition()
                presented.presenting = presenter

                presenter.setPresentation(otherModel, animated: true)
                presenter.dismiss?.completion?()
                presenter.completeTransition()

                expect(presenter.present?.presented) === otherPresented
              }
            }

            context("when no longer presented") {
              it("should present the different model") {
                presenter.setPresentation(boolModel, animated: true)

                expect(presenter.present?.presented) === presented
                expect(presenter.dismiss).to(beNil())

                presenter.completeTransition()
                presented.presenting = presenter
                presentationContext?.didDismiss()

                presenter.setPresentation(otherModel, animated: true)

                presenter.dismiss?.completion?()

                expect(presenter.present?.presented) === otherPresented
              }
            }

            context("with an active a dismissal transition") {
              it("should present the model on its completion") {
                presenter.setPresentation(boolModel, animated: true)

                presenter.completeTransition()
                expect(presenter.present?.presented) === presented

                presenter.coordinator = StubTransitionCoordinator()

                presenter.setPresentation(otherModel, animated: true)
                expect(presenter.present?.presented) === presented

                presented.presenting = presenter
                // Complete twice: once to complete the dismissal and another to complete the
                // subsequent presentation
                presenter.completeTransition()
                presenter.completeTransition()

                expect(presenter.present?.presented) === otherPresented
              }
            }
          }
        }

        context("when currently transitioning") {
          it("should not present the model") {
            presenter.coordinator = StubTransitionCoordinator()

            presenter.setPresentation(boolModel, animated: true)

            expect(presenter.present?.presented).to(beNil())
          }

          context("with a transition coordinator") {
            it("should present the model on its completion") {
              let coordinator = StubTransitionCoordinator()
              presenter.coordinator = coordinator

              presenter.setPresentation(boolModel, animated: true)

              presenter.completeTransition()

              expect(presenter.present?.presented) === presented
            }
          }

          context("when setting a model during a dismissal transition") {
            beforeEach {
              presenter.setPresentation(boolModel, animated: true)
              presenter.completeTransition()

              expect(presenter.present?.presented) === presented
              // Clear this out after the presentation has completed.
              presenter.present = nil
            }

            context("with the same model") {
              it("should skip an equivalent set model during dismissal") {
                let coordinator = StubTransitionCoordinator()
                presenter.coordinator = coordinator

                presenter.setPresentation(boolModel, animated: true)

                presentationContext?.didDismiss()

                presenter.completeTransition()

                expect(presenter.present?.presented).to(beNil())
              }
            }

            context("with a different model") {
              var otherModel: PresentationModel!
              var otherPresented: MockPresentedViewController!

              beforeEach {
                otherPresented = MockPresentedViewController()
                otherModel = PresentationModel(
                  params: optionalPresentedBacking,
                  dataID: PresentationID.two,
                  presentation: .system,
                  makeViewController: { _ in otherPresented },
                  dismiss: { optionalPresentedBacking = nil })
              }

              it("should present a new set model during dismissal once complete") {
                let coordinator = StubTransitionCoordinator()
                presenter.coordinator = coordinator

                presenter.setPresentation(otherModel, animated: true)

                presentationContext?.didDismiss()

                presenter.completeTransition()

                expect(presenter.present?.presented) === otherPresented
              }
            }
          }
        }
      }
    }

    describe("PresentationModel") {
      describe("didPresent") {
        it("should be called on presentation with the presented view controller") {
          presenter.setPresentation(boolModel, animated: true)

          expect(presenter.present?.presented) === presented

          presentationContext?.didPresent()

          expect(didPresent).to(haveCount(1))
          expect(didPresent.first) == ()
        }
      }

      describe("didDismiss") {
        it("should be called on dismissal") {
          presenter.setPresentation(optionalModel, animated: true)

          expect(presenter.present?.presented) === presented

          presentationContext?.didDismiss()

          expect(didDismiss).to(haveCount(1))
          expect(didDismiss.first) == ()
        }
      }
    }
  }

}

// MARK: - MockPresentedViewController

final class MockPresentedViewController: UIViewController {

  var presenting: UIViewController?

  override var presentingViewController: UIViewController? {
    presenting
  }

}

// MARK: - MockPresentingViewController

final class MockPresentingViewController: UIViewController {

  var coordinator: StubTransitionCoordinator? = nil

  var dismiss: (animated: Bool, completion: (() -> Void)?)?

  var present: (
    presented: UIViewController,
    animated: Bool,
    completion: (() -> Void)?)?

  override var transitionCoordinator: UIViewControllerTransitionCoordinator? {
    coordinator
  }

  override func present(
    _ viewControllerToPresent: UIViewController,
    animated: Bool,
    completion: (() -> Void)? = nil)
  {
    coordinator = StubTransitionCoordinator()
    present = (presented: viewControllerToPresent, animated: animated, completion: completion)
  }

  override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
    coordinator = StubTransitionCoordinator()
    dismiss = (animated: animated, completion: completion)
  }

  func completeTransition() {
    let coordinator = self.coordinator
    self.coordinator = nil
    coordinator?.complete()
  }

}
