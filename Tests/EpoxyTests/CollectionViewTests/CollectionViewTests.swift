// Created by Tyler Hedrick on 5/21/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Epoxy
import EpoxyCollectionView
import XCTest
import UIKit

class CollectionViewTests: XCTestCase {

  var collectionView: CollectionView!

  struct Flag {
    var itemModel = false
    var anyItemModel = false

    var bothCalled: Bool {
      itemModel && anyItemModel
    }
  }

  // state flags
  var willDisplayBlockCalled = Flag()
  var didEndDisplayingBlockCalled = Flag()
  var didSelectBlockCalled = Flag()

  override func setUp() {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 50, height: 50)
    collectionView = CollectionView(collectionViewLayout: layout)
    collectionView.frame = CGRect(x: 0, y: 0, width: 350, height: 350)

    let model = ItemModel(dataID: "dataID", content: "")
      .configureView { context in
        context.view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        context.view.heightAnchor.constraint(equalToConstant: 50).isActive = true
      }
      .didSelect { [weak self] _ in
        self?.didSelectBlockCalled.itemModel = true
      }
      .willDisplay { [weak self] in
        self?.willDisplayBlockCalled.itemModel = true
      }
      .didEndDisplaying { [weak self] in
        self?.didEndDisplayingBlockCalled.itemModel = true
      }
      .eraseToAnyItemModel()
      .didSelect { [weak self] _, _ in
        self?.didSelectBlockCalled.anyItemModel = true
      }
      .willDisplay { [weak self] in
        self?.willDisplayBlockCalled.anyItemModel = true
      }
      .didEndDisplaying { [weak self] in
        self?.didEndDisplayingBlockCalled.anyItemModel = true
      }

    collectionView.setSections([SectionModel(items: [model])], animated: false)
    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.layoutIfNeeded()
  }

  override func tearDown() {
    willDisplayBlockCalled = .init()
    didEndDisplayingBlockCalled = .init()
    didSelectBlockCalled = .init()
  }

  func testWillDisplayBlocksAreCalledWhenTheCellAppears() {
    collectionView.delegate?.collectionView?(
      collectionView,
      willDisplay: CollectionViewCell(),
      forItemAt: IndexPath(item: 0, section: 0))
    XCTAssertTrue(willDisplayBlockCalled.bothCalled)
  }

  func testDidEndDisplayingBlocksAreCalledWhenTheCellDisappears() {
    collectionView.delegate?.collectionView?(
      collectionView,
      didEndDisplaying: CollectionViewCell(),
      forItemAt: IndexPath(item: 0, section: 0))
    XCTAssertTrue(didEndDisplayingBlockCalled.bothCalled)
  }

  func testDidSelectBlocksAreCalledWhenTheCellIsSelected() {
    collectionView.delegate?.collectionView?(
      collectionView,
      didSelectItemAt: IndexPath(item: 0, section: 0))
    XCTAssertTrue(didSelectBlockCalled.bothCalled)
  }

}
