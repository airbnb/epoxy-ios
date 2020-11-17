// Created by Tyler Hedrick on 5/6/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

@testable import Epoxy
import XCTest

class EpoxySectionBuilderTests: XCTestCase {

  var builder: EpoxySectionBuilder!
  let model1: EpoxyableModel = EpoxyModel<UIView, String>(
    data: "",
    dataID: "model_1",
    configureView: { _ in })
  let model2: EpoxyableModel = EpoxyModel<UIView, String>(
    data: "",
    dataID: "model_2",
    configureView: { _ in })
  let supplementaryModel = SupplementaryViewEpoxyModel<UIView, String>(
    elementKind: "test_kind",
    data: "",
    dataID: "supplementary_id",
    builder: { return UIView(frame: .zero) },
    configurer: { _, _, _ in })

  override func setUp() {
    builder = EpoxySectionBuilder(dataID: "section_id")
  }

  func testBaseSection() {
    let section = builder.build()
    XCTAssertEqual(section.items.count, 0)
    XCTAssertEqual(section.dataID, "section_id")
  }

  func testSettingItems() {
    let section = builder.with(items: [model1]).build()
    XCTAssertEqual(section.items.count, 1)
    XCTAssertNotNil(section.items.first)
    XCTAssertEqual(section.items.first!.dataID, "model_1")
  }

  func testAppendingItem() {
    let section = builder.with(appendedItem: model1).build()
    XCTAssertEqual(section.items.count, 1)
    XCTAssertNotNil(section.items.first)
    XCTAssertEqual(section.items.first!.dataID, "model_1")
  }

  func testAppendingItems() {
    let section = builder.with(appendedItems: [model1]).build()
    XCTAssertEqual(section.items.count, 1)
    XCTAssertNotNil(section.items.first)
    XCTAssertEqual(section.items.first!.dataID, "model_1")
  }

  func testInsertingItem() {
    let updatedBuilder = builder.with(appendedItem: model1).with(item: model2, insertedAt: 0)
    let section = updatedBuilder.build()
    XCTAssertEqual(section.items.count, 2)
    XCTAssertEqual(section.items[0].dataID, "model_2")
    XCTAssertEqual(section.items[1].dataID, "model_1")
  }

  func testUserInfoFullSet() {
    let key = EpoxyUserInfoKey.init(rawValue: "test_full_dict")
    let userInfo = [key: 5]
    let section = builder.with(userInfo: userInfo).build()
    XCTAssertEqual(section.userInfo[key] as! Int, 5)
  }

  func testSettingIndividualValuesOnUserInfo() {
    let key = EpoxyUserInfoKey.init(rawValue: "test_setting_values")
    let section = builder.withSetUserInfoValue(6, for: key).build()
    XCTAssertEqual(section.userInfo[key] as! Int, 6)

    let newKey = EpoxyUserInfoKey.init(rawValue: "test_full_dict")
    let userInfo = [newKey: 7]
    let otherSection = builder.with(userInfo: userInfo).build()
    XCTAssertNil(otherSection.userInfo[key])
    XCTAssertEqual(otherSection.userInfo[newKey] as! Int, 7)
  }

  func testSubscripts() {
    let key = EpoxyUserInfoKey(rawValue: "subscript")
    builder?[key] = 5
    XCTAssertEqual(builder[key], 5)

    let section = builder.build()
    XCTAssertEqual(section.userInfo[key] as! Int, 5)
  }

  func testSettingSupplementaryModelsAsGroup() {
    let section = builder.withCollectionView(supplementaryModels: ["models": [supplementaryModel]]).build()
    XCTAssertEqual(section.collectionViewSupplementaryModels?["models"]?.first?.dataID, "supplementary_id")
  }

}
