// Created by Tyler Hedrick on 5/6/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

@testable import Epoxy
import XCTest

class EpoxyModelBuilderTests: XCTestCase {

  var builder: BaseEpoxyModelBuilder<UIView, String>!

  override func setUp() {
    super.setUp()
    builder = BaseEpoxyModelBuilder<UIView, String>(
      data: "data",
      dataID: "data_id")
  }

  func testBaseModel() {
    let model = builder.build()
    XCTAssertEqual(model.dataID, "data_id")
    XCTAssertEqual(model.data, "data")
  }

  func testAlternateStyleId() {
    let model = builder.alternateStyleID("style_id").build()
    XCTAssertEqual(model.reuseID, "\(type(of: UIView.self))_style_id")
  }

  func testUserInfoFullSet() {
    let key = EpoxyUserInfoKey.init(rawValue: "test_full_dict")
    let userInfo = [key: 5]
    let model = builder.userInfo(userInfo).build()
    XCTAssertEqual(model.userInfo[key] as! Int, 5)
  }

  func testSettingIndividualValuesOnUserInfo() {
    let key = EpoxyUserInfoKey.init(rawValue: "test_setting_values")
    let model = builder.setUserInfoValue(6, for: key).build()
    XCTAssertEqual(model.userInfo[key] as! Int, 6)

    let newKey = EpoxyUserInfoKey.init(rawValue: "test_full_dict")
    let userInfo = [newKey: 7]
    let otherModel = builder.userInfo(userInfo).build()
    XCTAssertNil(otherModel.userInfo[key])
    XCTAssertEqual(otherModel.userInfo[newKey] as! Int, 7)
  }

  func testSubscripts() {
    let key = EpoxyUserInfoKey(rawValue: "subscript")
    builder?[key] = 5
    XCTAssertEqual(builder[key], 5)

    let model = builder.build()
    XCTAssertEqual(model.userInfo[key] as! Int, 5)
  }
}
