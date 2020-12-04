// Created by Tyler Hedrick on 5/21/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Epoxy
import EpoxyCollectionView
import XCTest
import UIKit

class CollectionViewTests: XCTestCase {

  var collectionView: CollectionView!

  struct Flag {
    var epoxyModel = false
    var anyEpoxyModel = false

    var bothCalled: Bool {
      epoxyModel && anyEpoxyModel
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

    let model = EpoxyModel(dataID: "dataID", content: "")
      .configureView { context in
        context.view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        context.view.heightAnchor.constraint(equalToConstant: 50).isActive = true
      }
      .didSelect { [weak self] _ in
        self?.didSelectBlockCalled.epoxyModel = true
      }
      .willDisplay { [weak self] in
        self?.willDisplayBlockCalled.epoxyModel = true
      }
      .didEndDisplaying { [weak self] in
        self?.didEndDisplayingBlockCalled.epoxyModel = true
      }
      .eraseToAnyEpoxyModel()
      .didSelect { [weak self] _, _ in
        self?.didSelectBlockCalled.anyEpoxyModel = true
      }
      .willDisplay { [weak self] in
        self?.willDisplayBlockCalled.anyEpoxyModel = true
      }
      .didEndDisplaying { [weak self] in
        self?.didEndDisplayingBlockCalled.anyEpoxyModel = true
      }

    collectionView.setSections([EpoxySection(items: [model])], animated: false)
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
