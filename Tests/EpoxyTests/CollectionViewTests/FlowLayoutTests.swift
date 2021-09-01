// Created by Tyler Hedrick on 1/20/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCollectionView
import EpoxyCore
import Nimble
import Quick
import XCTest

final class FlowLayoutSpec: QuickSpec {

  override func spec() {
    let itemModel = ItemModel(dataID: DefaultDataID.noneProvided)
      .setContent { context in
        context.view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        context.view.heightAnchor.constraint(equalToConstant: 50).isActive = true
      }

    var collectionView: CollectionView!
    var layout: UICollectionViewFlowLayout!

    beforeEach {
      layout = UICollectionViewFlowLayout()
      layout.minimumLineSpacing = 1
      layout.minimumInteritemSpacing = 2
      layout.itemSize = CGSize(width: 1, height: 1)
      layout.headerReferenceSize = .init(width: 2, height: 2)
      layout.footerReferenceSize = .init(width: 3, height: 3)
      layout.sectionInset = .init(top: 1, left: 1, bottom: 1, right: 1)
      collectionView = CollectionView(layout: layout)
      collectionView.frame = CGRect(x: 0, y: 0, width: 350, height: 350)
    }

    describe("when the items provide no information") {
      beforeEach {
        collectionView.setSections([SectionModel(dataID: DefaultDataID.noneProvided, items: [itemModel])], animated: false)
      }
      it("uses the itemSize from the UICollectionViewFlowLayout") {
        let itemSize = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          sizeForItemAt: IndexPath(item: 0, section: 0))
        expect(itemSize).to(equal(layout.itemSize))
      }

      it("uses the sectionInset from the UICollectionViewFlowLayout") {
        let sectionInset = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          insetForSectionAt: 0)
        expect(sectionInset).to(equal(layout.sectionInset))
      }

      it("uses the minimumLineSpacing from the UICollectionViewFlowLayout") {
        let lineSpacing = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          minimumLineSpacingForSectionAt: 0)
        expect(lineSpacing).to(equal(layout.minimumLineSpacing))
      }

      it("uses the minimumInteritemSpacing from the UICollectionViewFlowLayout") {
        let interitemSpacing = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          minimumInteritemSpacingForSectionAt: 0)
        expect(interitemSpacing).to(equal(layout.minimumInteritemSpacing))
      }

      it("uses the headerSize from the UICollectionViewFlowLayout") {
        let headerSize = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          referenceSizeForHeaderInSection: 0)
        expect(headerSize).to(equal(layout.headerReferenceSize))
      }

      it("uses the footerSize from the UICollectionViewFlowLayout") {
        let footerSize = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          referenceSizeForFooterInSection: 0)
        expect(footerSize).to(equal(layout.footerReferenceSize))
      }
    }

    describe("when the items and the sections provide item sizes") {
      beforeEach {
        let itemModel = itemModel.flowLayoutItemSize(.init(width: 5, height: 5))
        let section = SectionModel(dataID: DefaultDataID.noneProvided, items: [itemModel])
          .flowLayoutItemSize(CGSize(width: 6, height: 6))
        collectionView.setSections([section], animated: false)
      }

      it("prioritizes the item size over the section") {
        let itemSize = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          sizeForItemAt: IndexPath(item: 0, section: 0))
        expect(itemSize).to(equal(CGSize(width: 5, height: 5)))
      }
    }

    describe("when the section provides item sizes") {
      beforeEach {
        let section = SectionModel(dataID: DefaultDataID.noneProvided, items: [itemModel])
          .flowLayoutItemSize(CGSize(width: 6, height: 6))
        collectionView.setSections([section], animated: false)
      }

      it("prioritizes the section item size over the default size or the UICollectionViewLayout size") {
        let itemSize = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          sizeForItemAt: IndexPath(item: 0, section: 0))
        expect(itemSize).to(equal(CGSize(width: 6, height: 6)))
      }
    }

    describe("when the section models provide values") {
      beforeEach {
        let section = SectionModel(dataID: DefaultDataID.noneProvided, items: [itemModel])
          .flowLayoutSectionInset(.init(top: 7, left: 7, bottom: 7, right: 7))
          .flowLayoutMinimumLineSpacing(8)
          .flowLayoutMinimumInteritemSpacing(9)
          .flowLayoutHeaderReferenceSize(CGSize(width: 10, height: 10))
          .flowLayoutFooterReferenceSize(CGSize(width: 11, height: 11))
        collectionView.setSections([section], animated: false)
      }

      it("uses the sectionInset from the section model") {
        let sectionInset = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          insetForSectionAt: 0)
        expect(sectionInset).to(equal(UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)))
      }

      it("uses the minimumLineSpacing from the section model") {
        let lineSpacing = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          minimumLineSpacingForSectionAt: 0)
        expect(lineSpacing).to(equal(8))
      }

      it("uses the minimumInteritemSpacing from the section model") {
        let interitemSpacing = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          minimumInteritemSpacingForSectionAt: 0)
        expect(interitemSpacing).to(equal(9))
      }

      it("uses the headerSize from the section model") {
        let headerSize = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          referenceSizeForHeaderInSection: 0)
        expect(headerSize).to(equal(CGSize(width: 10, height: 10)))
      }

      it("uses the footerSize from the section model") {
        let footerSize = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          referenceSizeForFooterInSection: 0)
        expect(footerSize).to(equal(CGSize(width: 11, height: 11)))
      }
    }

    describe("when the section models provide values and there is a delegate") {
      let layoutDelegate = ProxyDelegate()
      beforeEach {
        let section = SectionModel(dataID: DefaultDataID.noneProvided, items: [itemModel])
          .flowLayoutSectionInset(.init(top: 7, left: 7, bottom: 7, right: 7))
          .flowLayoutMinimumLineSpacing(8)
          .flowLayoutMinimumInteritemSpacing(9)
          .flowLayoutHeaderReferenceSize(CGSize(width: 10, height: 10))
          .flowLayoutFooterReferenceSize(CGSize(width: 11, height: 11))
        collectionView.setSections([section], animated: false)
        collectionView.layoutDelegate = layoutDelegate
      }

      it("uses the sectionInset from the delegate") {
        let sectionInset = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          insetForSectionAt: 0)
        expect(sectionInset).to(equal(layoutDelegate.sectionInset))
      }

      it("uses the minimumLineSpacing from the delegate") {
        let lineSpacing = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          minimumLineSpacingForSectionAt: 0)
        expect(lineSpacing).to(equal(layoutDelegate.minimumLineSpacing))
      }

      it("uses the minimumInteritemSpacing from the delegate") {
        let interitemSpacing = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          minimumInteritemSpacingForSectionAt: 0)
        expect(interitemSpacing).to(equal(layoutDelegate.minimumInteritemSpacing))
      }

      it("uses the headerSize from the delegate") {
        let headerSize = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          referenceSizeForHeaderInSection: 0)
        expect(headerSize).to(equal(layoutDelegate.headerSize))
      }

      it("uses the footerSize from the delegate") {
        let footerSize = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          referenceSizeForFooterInSection: 0)
        expect(footerSize).to(equal(layoutDelegate.footerSize))
      }
    }

    describe("when the sections, items, and layout provide no information") {
      beforeEach {
        layout = UICollectionViewFlowLayout()
        collectionView = CollectionView(layout: layout)
        collectionView.frame = CGRect(x: 0, y: 0, width: 350, height: 350)
        collectionView.setSections([SectionModel(dataID: DefaultDataID.noneProvided, items: [itemModel])], animated: false)
      }
      it("uses the default sizes") {
        let itemSize = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          sizeForItemAt: IndexPath(item: 0, section: 0))
        expect(itemSize).to(equal(CGSize(width: 50, height: 50)))
      }

      it("uses the default section insets") {
        let sectionInset = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          insetForSectionAt: 0)
        expect(sectionInset).to(equal(.zero))
      }

      it("uses the default line spacing") {
        let lineSpacing = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          minimumLineSpacingForSectionAt: 0)
        expect(lineSpacing).to(equal(10))
      }

      it("uses the default interitem spacing") {
        let interitemSpacing = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          minimumInteritemSpacingForSectionAt: 0)
        expect(interitemSpacing).to(equal(10))
      }

      it("uses the default header size") {
        let headerSize = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          referenceSizeForHeaderInSection: 0)
        expect(headerSize).to(equal(.zero))
      }

      it("uses the default footer size") {
        let footerSize = collectionView.collectionView(
          collectionView,
          layout: collectionView.collectionViewLayout,
          referenceSizeForFooterInSection: 0)
        expect(footerSize).to(equal(.zero))
      }
    }
  }
}
