// Created by Tyler Hedrick on 5/21/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Epoxy
import EpoxyCollectionView
import XCTest
import UIKit

class CollectionViewTests: XCTestCase {

  var collectionView: CollectionView!

  struct Flag {
    var model = false
    var anyModel = false

    var bothCalled: Bool {
      model && anyModel
    }
  }

  // state flags
  var itemWillDisplayBlockCalled = Flag()
  var itemDidEndDisplayingBlockCalled = Flag()
  var itemDidSelectBlockCalled = Flag()
  var supplementaryItemWillDisplayBlockCalled = Flag()
  var supplementaryItemDidEndDisplayingBlockCalled = Flag()

  override func setUp() {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 50, height: 50)
    collectionView = CollectionView(collectionViewLayout: layout)
    collectionView.frame = CGRect(x: 0, y: 0, width: 350, height: 350)

    let item = ItemModel(dataID: "dataID", content: "")
      .configureView { context in
        context.view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        context.view.heightAnchor.constraint(equalToConstant: 50).isActive = true
      }
      .didSelect { [weak self] _ in
        self?.itemDidSelectBlockCalled.model = true
      }
      .willDisplay { [weak self] _ in
        self?.itemWillDisplayBlockCalled.model = true
      }
      .didEndDisplaying { [weak self] _ in
        self?.itemDidEndDisplayingBlockCalled.model = true
      }
      .eraseToAnyItemModel()
      .didSelect { [weak self] _ in
        self?.itemDidSelectBlockCalled.anyModel = true
      }
      .willDisplay { [weak self] _ in
        self?.itemWillDisplayBlockCalled.anyModel = true
      }
      .didEndDisplaying { [weak self] _ in
        self?.itemDidEndDisplayingBlockCalled.anyModel = true
      }

    let supplementaryItem = SupplementaryItemModel(dataID: "dataID", content: "")
      .configureView { context in
        context.view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        context.view.heightAnchor.constraint(equalToConstant: 50).isActive = true
      }
      .willDisplay { [weak self] _ in
        self?.supplementaryItemWillDisplayBlockCalled.model = true
      }
      .didEndDisplaying { [weak self] _ in
        self?.supplementaryItemDidEndDisplayingBlockCalled.model = true
      }
      .eraseToAnySupplementaryItemModel()
      .willDisplay { [weak self] _ in
        self?.supplementaryItemWillDisplayBlockCalled.anyModel = true
      }
      .didEndDisplaying { [weak self] _ in
        self?.supplementaryItemDidEndDisplayingBlockCalled.anyModel = true
      }

    let section = SectionModel(items: [item])
      .supplementaryItems([UICollectionView.elementKindSectionHeader: [supplementaryItem]])

    collectionView.setSections([section], animated: false)
    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.layoutIfNeeded()
  }

  override func tearDown() {
    itemWillDisplayBlockCalled = .init()
    itemDidEndDisplayingBlockCalled = .init()
    itemDidSelectBlockCalled = .init()
  }

  func testItemWillDisplayBlocksAreCalledWhenTheCellAppears() {
    collectionView.delegate?.collectionView?(
      collectionView,
      willDisplay: CollectionViewCell(),
      forItemAt: IndexPath(item: 0, section: 0))
    XCTAssertTrue(itemWillDisplayBlockCalled.bothCalled)
  }

  func testItemDidEndDisplayingBlocksAreCalledWhenTheCellDisappears() {
    collectionView.delegate?.collectionView?(
      collectionView,
      didEndDisplaying: CollectionViewCell(),
      forItemAt: IndexPath(item: 0, section: 0))
    XCTAssertTrue(itemDidEndDisplayingBlockCalled.bothCalled)
  }

  func testItemDidSelectBlocksAreCalledWhenTheCellIsSelected() {
    collectionView.delegate?.collectionView?(
      collectionView,
      didSelectItemAt: IndexPath(item: 0, section: 0))
    XCTAssertTrue(itemDidSelectBlockCalled.bothCalled)
  }

  func testSupplementaryItemWillDisplayBlocksAreCalledWhenTheReusableViewAppears() {
    collectionView.delegate?.collectionView?(
      collectionView,
      willDisplaySupplementaryView: CollectionViewReusableView(),
      forElementKind: UICollectionView.elementKindSectionHeader,
      at: IndexPath(item: 0, section: 0))
    XCTAssertTrue(supplementaryItemWillDisplayBlockCalled.bothCalled)
  }

  func testSupplementaryItemDidEndDisplayingBlocksAreCalledWhenReusableViewCellDisappears() {
    collectionView.delegate?.collectionView?(
      collectionView,
      didEndDisplayingSupplementaryView: CollectionViewReusableView(),
      forElementOfKind: UICollectionView.elementKindSectionHeader,
      at: IndexPath(item: 0, section: 0))
    XCTAssertTrue(supplementaryItemDidEndDisplayingBlockCalled.bothCalled)
  }

}
