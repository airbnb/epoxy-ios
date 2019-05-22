// Created by Tyler Hedrick on 5/21/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

@testable import Epoxy
import XCTest

class CollectionViewTests: XCTestCase {

  var collectionView: CollectionView!

  // state flags
  var willDisplayBlockCalled: Bool = false
  var didEndDisplayingBlockCalled: Bool = false
  var didSelectBlockCalled: Bool = false

  override func setUp() {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 50, height: 50)
    collectionView = CollectionView(collectionViewLayout: layout)
    collectionView.frame = CGRect(x: 0, y: 0, width: 350, height: 350)

    let model = BaseEpoxyModelBuilder(data: "", dataID: "dataID")
      .with(configurer: { view, _, _, _ in
        view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
      })
      .with(selectionHandler: { [weak self] _, _, _ in
        self?.didSelectBlockCalled = true
      })
      .withWillDisplay { [weak self] _, _ in
        self?.willDisplayBlockCalled = true
      }
      .withDidEndDisplaying { [weak self] _, _ in
        self?.didEndDisplayingBlockCalled = true
      }
      .build()

    collectionView.setSections([EpoxySection(items: [model])], animated: false)
    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.layoutIfNeeded()
  }

  override func tearDown() {
    willDisplayBlockCalled = false
    didEndDisplayingBlockCalled = false
    didSelectBlockCalled = false
  }

  func testWillDisplayBlocksAreCalledWhenTheCellAppears() {
    collectionView.delegate?.collectionView?(
      collectionView,
      willDisplay: CollectionViewCell(frame: .zero),
      forItemAt: IndexPath(item: 0, section: 0))
    XCTAssertTrue(willDisplayBlockCalled)
  }

  func testDidEndDisplayingBlocksAreCalledWhenTheCellDisappears() {
    collectionView.delegate?.collectionView?(
      collectionView,
      didEndDisplaying: CollectionViewCell(frame: .zero),
      forItemAt: IndexPath(item: 0, section: 0))
    XCTAssertTrue(didEndDisplayingBlockCalled)
  }

  func testDidSelectBlocksAreCalledWhenTheCellIsSelected() {
    collectionView.delegate?.collectionView?(
      collectionView,
      didSelectItemAt: IndexPath(item: 0, section: 0))
    XCTAssertTrue(didSelectBlockCalled)
  }

}
