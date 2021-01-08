// Created by eric_horacek on 1/8/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Nimble
import Quick
import UIKit
import EpoxyCore
import EpoxyCollectionView

// MARK: - CollectionViewSpec

final class CollectionViewSpec: QuickSpec {
  override func spec() {
    let itemModel = ItemModel(dataID: DefaultDataID.noneProvided, content: "")
      .configureView { context in
        context.view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        context.view.heightAnchor.constraint(equalToConstant: 50).isActive = true
      }

    let supplementaryItemModel = SupplementaryItemModel(dataID: DefaultDataID.noneProvided, content: "")
      .configureView { context in
        context.view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        context.view.heightAnchor.constraint(equalToConstant: 50).isActive = true
      }

    var collectionView: CollectionView!

    beforeEach {
      let layout = UICollectionViewFlowLayout()
      layout.itemSize = CGSize(width: 50, height: 50)
      collectionView = CollectionView(collectionViewLayout: layout)
      collectionView.frame = CGRect(x: 0, y: 0, width: 350, height: 350)
    }

    describe("visibility") {
      describe("of an item") {
        var itemWillDisplay: [ItemModel<UIView, String>.CallbackContext]!
        var itemDidEndDisplaying: [ItemModel<UIView, String>.CallbackContext]!
        var erasedItemWillDisplay: [AnyItemModel.CallbackContext]!
        var erasedItemDidEndDisplaying: [AnyItemModel.CallbackContext]!

        beforeEach {
          let item = itemModel
            .willDisplay { itemWillDisplay.append($0) }
            .didEndDisplaying { itemDidEndDisplaying.append($0) }
            .eraseToAnyItemModel()
            .willDisplay { erasedItemWillDisplay.append($0) }
            .didEndDisplaying { erasedItemDidEndDisplaying.append($0) }

          itemWillDisplay = []
          itemDidEndDisplaying = []
          erasedItemWillDisplay = []
          erasedItemDidEndDisplaying = []

          let section = SectionModel(items: [item])
          collectionView.setSections([section], animated: false)
        }

        afterEach {
          itemWillDisplay = nil
          itemDidEndDisplaying = nil
          erasedItemWillDisplay = nil
          erasedItemDidEndDisplaying = nil
        }

        context("before its view appears") {
          it("should not call willAppear") {
            expect(itemWillDisplay).to(haveCount(0))
            expect(erasedItemWillDisplay).to(haveCount(0))
          }

          it("should not call didEndDisplaying") {
            expect(itemDidEndDisplaying).to(haveCount(0))
            expect(erasedItemDidEndDisplaying).to(haveCount(0))
          }
        }

        context("when its view appears") {
          beforeEach {
            collectionView.delegate?.collectionView?(
              collectionView,
              willDisplay: CollectionViewCell(),
              forItemAt: IndexPath(item: 0, section: 0))
          }

          it("should call willAppear") {
            expect(itemWillDisplay).to(haveCount(1))
            expect(erasedItemWillDisplay).to(haveCount(1))
          }
        }

        context("when its view disappears") {
          beforeEach {
            collectionView.delegate?.collectionView?(
              collectionView,
              didEndDisplaying: CollectionViewCell(),
              forItemAt: IndexPath(item: 0, section: 0))
          }

          it("should call didEndDisplaying") {
            expect(itemDidEndDisplaying).to(haveCount(1))
            expect(erasedItemDidEndDisplaying).to(haveCount(1))
          }
        }
      }

      describe("of a supplementary item") {
        var itemWillDisplay: [SupplementaryItemModel<UIView, String>.CallbackContext]!
        var itemDidEndDisplaying: [SupplementaryItemModel<UIView, String>.CallbackContext]!
        var erasedItemWillDisplay: [AnySupplementaryItemModel.CallbackContext]!
        var erasedItemDidEndDisplaying: [AnySupplementaryItemModel.CallbackContext]!

        beforeEach {
          let item = supplementaryItemModel
            .willDisplay { itemWillDisplay.append($0) }
            .didEndDisplaying { itemDidEndDisplaying.append($0) }
            .eraseToAnySupplementaryItemModel()
            .willDisplay { erasedItemWillDisplay.append($0) }
            .didEndDisplaying { erasedItemDidEndDisplaying.append($0) }

          itemWillDisplay = []
          itemDidEndDisplaying = []
          erasedItemWillDisplay = []
          erasedItemDidEndDisplaying = []

          let section = SectionModel(items: [ItemModel(dataID: "dataID", content: "")])
            .supplementaryItems(ofKind: UICollectionView.elementKindSectionHeader, [item])
          collectionView.setSections([section], animated: false)
        }

        afterEach {
          itemWillDisplay = nil
          itemDidEndDisplaying = nil
          erasedItemWillDisplay = nil
          erasedItemDidEndDisplaying = nil
        }

        context("before its view appears") {
          it("should not call willAppear") {
            expect(itemWillDisplay).to(haveCount(0))
            expect(erasedItemWillDisplay).to(haveCount(0))
          }

          it("should not call didEndDisplaying") {
            expect(itemDidEndDisplaying).to(haveCount(0))
            expect(erasedItemDidEndDisplaying).to(haveCount(0))
          }
        }

        context("when its view appears") {
          beforeEach {
            collectionView.delegate?.collectionView?(
              collectionView,
              willDisplaySupplementaryView: CollectionViewReusableView(),
              forElementKind: UICollectionView.elementKindSectionHeader,
              at: IndexPath(item: 0, section: 0))
          }

          it("should call willAppear") {
            expect(itemWillDisplay).to(haveCount(1))
            expect(erasedItemWillDisplay).to(haveCount(1))
          }
        }

        context("when its view disappears") {
          beforeEach {
            collectionView.delegate?.collectionView?(
              collectionView,
              didEndDisplayingSupplementaryView: CollectionViewReusableView(),
              forElementOfKind: UICollectionView.elementKindSectionHeader,
              at: IndexPath(item: 0, section: 0))
          }

          it("should call didEndDisplaying") {
            expect(itemDidEndDisplaying).to(haveCount(1))
            expect(erasedItemDidEndDisplaying).to(haveCount(1))
          }
        }
      }

      describe("of a section") {
        context("with an item and a supplementary item") {
          var sectionWillDisplay: [SectionModel.CallbackContext]!
          var sectionDidEndDisplaying: [SectionModel.CallbackContext]!

          beforeEach {
            let section = SectionModel(items: [itemModel])
              .supplementaryItems(ofKind: UICollectionView.elementKindSectionHeader, [supplementaryItemModel])
              .willDisplay { sectionWillDisplay.append($0) }
              .didEndDisplaying { sectionDidEndDisplaying.append($0) }

            sectionWillDisplay = []
            sectionDidEndDisplaying = []

            collectionView.setSections([section], animated: false)
          }

          afterEach {
            sectionWillDisplay = nil
            sectionDidEndDisplaying = nil
          }

          context("before its items views appears") {
            it("should not call willAppear") {
              expect(sectionWillDisplay).to(haveCount(0))
            }

            it("should not call didEndDisplaying") {
              expect(sectionDidEndDisplaying).to(haveCount(0))
            }
          }

          context("when its first items view appears") {
            beforeEach {
              collectionView.delegate?.collectionView?(
                collectionView,
                willDisplay: CollectionViewCell(),
                forItemAt: IndexPath(item: 0, section: 0))
            }

            it("should call willAppear") {
              expect(sectionWillDisplay).to(haveCount(1))
            }

            it("should not call didEndDisplay") {
              expect(sectionDidEndDisplaying).to(haveCount(0))
            }

            context("and subsequently disappears") {
              beforeEach {
                collectionView.delegate?.collectionView?(
                  collectionView,
                  didEndDisplaying: CollectionViewCell(),
                  forItemAt: IndexPath(item: 0, section: 0))
              }

              it("should call didEndDisplaying") {
                expect(sectionDidEndDisplaying).to(haveCount(1))
              }

              context("and then reappears") {
                beforeEach {
                  collectionView.delegate?.collectionView?(
                    collectionView,
                    willDisplay: CollectionViewCell(),
                    forItemAt: IndexPath(item: 0, section: 0))
                }

                it("should call willAppear again") {
                  expect(sectionWillDisplay).to(haveCount(2))
                }

                it("should not call didEndDisplay again") {
                  expect(sectionDidEndDisplaying).to(haveCount(1))
                }
              }
            }

            context("and then its second item appears") {
              beforeEach {
                collectionView.delegate?.collectionView?(
                  collectionView,
                  willDisplaySupplementaryView: CollectionViewReusableView(),
                  forElementKind: UICollectionView.elementKindSectionHeader,
                  at: IndexPath(item: 0, section: 0))
              }

              it("should not call willAppear again") {
                expect(sectionWillDisplay).to(haveCount(1))
              }

              context("and then both disappear") {
                beforeEach {
                  collectionView.delegate?.collectionView?(
                    collectionView,
                    didEndDisplaying: CollectionViewCell(),
                    forItemAt: IndexPath(item: 0, section: 0))
                  collectionView.delegate?.collectionView?(
                    collectionView,
                    didEndDisplayingSupplementaryView: CollectionViewReusableView(),
                    forElementOfKind: UICollectionView.elementKindSectionHeader,
                    at: IndexPath(item: 0, section: 0))
                }

                it("should not call willAppear again") {
                  expect(sectionWillDisplay).to(haveCount(1))
                }

                it("should call didEndDisplaying") {
                  expect(sectionDidEndDisplaying).to(haveCount(1))
                }
              }
            }
          }
        }
      }
    }

    describe("item selection") {
      var itemDidSelect: [ItemModel<UIView, String>.CallbackContext]!
      var erasedItemDidSelect: [AnyItemModel.CallbackContext]!

      beforeEach {
        let item = itemModel
          .didSelect { itemDidSelect.append($0) }
          .eraseToAnyItemModel()
          .didSelect { erasedItemDidSelect.append($0) }

        itemDidSelect = []
        erasedItemDidSelect = []

        let section = SectionModel(items: [item])
        collectionView.setSections([section], animated: false)
        // Required to prevent a index path out of bounds exception during selection.
        collectionView.layoutIfNeeded()
      }

      afterEach {
        itemDidSelect = nil
        erasedItemDidSelect = nil
      }

      context("before its view is selected") {
        it("should not call didSelect") {
          expect(itemDidSelect).to(haveCount(0))
          expect(erasedItemDidSelect).to(haveCount(0))
        }
      }

      context("when its view is selected") {
        beforeEach {
          collectionView.delegate?.collectionView?(
            collectionView,
            didSelectItemAt: IndexPath(item: 0, section: 0))
        }

        it("should call didSelect") {
          expect(itemDidSelect).to(haveCount(1))
          expect(erasedItemDidSelect).to(haveCount(1))
        }
      }
    }
  }
}
