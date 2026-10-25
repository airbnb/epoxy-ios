// Created by sean_saathoff on 10/23/26.
// Copyright © 2026 Airbnb Inc. All rights reserved.

import EpoxyBars
import UIKit
import XCTest

// MARK: - KeyboardPositionWatcherTests

// swiftlint:disable implicitly_unwrapped_optional

@MainActor
final class KeyboardPositionWatcherTests: XCTestCase {

  // MARK: Internal

  // MARK: Setup/Teardown

  override func setUp() {
    super.setUp()
    window = UIWindow(frame: UIScreen.main.bounds)
    scrollView = UIScrollView(frame: window.bounds)
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.contentInset.bottom = bottomBarInset
    window.addSubview(scrollView)
    window.isHidden = false
    watcher = KeyboardPositionWatcher()
    watcher.adjustBottomContentInset(of: scrollView)
  }

  override func tearDown() {
    window.isHidden = true
    watcher = nil
    scrollView = nil
    window = nil
    super.tearDown()
  }

  func testShowInsetsContentAboveKeyboard() {
    postKeyboardNotification(UIResponder.keyboardWillShowNotification, isOnscreen: true)
    XCTAssertEqual(scrollView.contentInset.bottom, keyboardHeight)
  }

  func testShowThenHideRestoresOriginalInset() {
    postKeyboardNotification(UIResponder.keyboardWillShowNotification, isOnscreen: true)
    postKeyboardNotification(UIResponder.keyboardWillHideNotification, isOnscreen: false)
    XCTAssertEqual(scrollView.contentInset.bottom, bottomBarInset)
  }

  func testHideWithoutShowKeepsOriginalInset() {
    postKeyboardNotification(UIResponder.keyboardWillHideNotification, isOnscreen: false)
    XCTAssertEqual(scrollView.contentInset.bottom, bottomBarInset)
  }

  /// Dismissing the keyboard with `keyboardDismissMode = .onDrag` posts a second hide once the
  /// first responder resigns.
  func testSecondHideAfterShowKeepsOriginalInset() {
    postKeyboardNotification(UIResponder.keyboardWillShowNotification, isOnscreen: true)
    postKeyboardNotification(UIResponder.keyboardWillHideNotification, isOnscreen: false)
    postKeyboardNotification(UIResponder.keyboardWillHideNotification, isOnscreen: false)
    XCTAssertEqual(scrollView.contentInset.bottom, bottomBarInset)
  }

  // MARK: Private

  private let bottomBarInset: CGFloat = 80
  private let keyboardHeight: CGFloat = 300

  private var window: UIWindow!
  private var scrollView: UIScrollView!
  private var watcher: KeyboardPositionWatcher!

  private func postKeyboardNotification(_ name: Notification.Name, isOnscreen: Bool) {
    let screenBounds = UIScreen.main.bounds
    let keyboardFrame = CGRect(
      x: 0,
      y: isOnscreen ? screenBounds.maxY - keyboardHeight : screenBounds.maxY,
      width: screenBounds.width,
      height: keyboardHeight)
    NotificationCenter.default.post(
      name: name,
      object: nil,
      userInfo: [UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: keyboardFrame)])
  }

}
