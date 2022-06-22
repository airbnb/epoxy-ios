// Created by gil_birman on 11/20/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import CoreGraphics
import Foundation
import UIKit

// MARK: - KeyboardPositionWatcher

/// Watches for changes to the keyboard position and triggers a closure within an animation
/// transaction so that the consumer can animate it's UI in-sync with the keyboard.
public class KeyboardPositionWatcher {

  // MARK: Lifecycle

  public init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShowOrHide),
      name: UIResponder.keyboardWillShowNotification,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShowOrHide),
      name: UIResponder.keyboardWillHideNotification,
      object: nil)
  }

  // MARK: Public

  /// Whether the keyboard position observation is enabled.
  ///
  /// If the keyboard is currently visible and `enabled` is `false`, setting it to `true` will cause
  /// all observers to be invoked with the current offset.
  public var enabled = true {
    didSet { updateEnabled(from: oldValue) }
  }

  /// Calls the given closure whenever the keyboard shows or hides with the distance that it
  /// overlaps the provided view.
  ///
  /// This closure is called from within an animation transaction so any animatable properties will
  /// be animated.
  ///
  /// The given `overlap` is the height of the keyboard's overlap with the bounds of the
  /// `containingView`, from to the top of the keyboard to the max Y of the view's bounds.
  public func observeOverlap(
    in containingView: UIView?,
    _ observer: @escaping (_ overlap: CGFloat) -> Void)
  {
    guard let view = containingView else { return }
    observers[ObjectIdentifier(view)] = Observer(observer: observer, view: view)
  }

  /// Adjusts the `contentInset.bottom` and `scrollIndicatorInsets.bottom` of the given scroll view
  /// as the keyboard is shown and hidden.
  public func adjustBottomContentInset(of scrollView: UIScrollView?) {
    guard let scrollView = scrollView else { return }

    var previousOverlap: CGFloat = 0

    observeOverlap(in: scrollView) { [weak scrollView] overlap in
      guard let scrollView = scrollView, scrollView.keyboardAdjustsBottomContentInset else { return }

      var insets = scrollView.insets(for: overlap)

      // Store the previous insets when the keyboard appears and reapply when disappeared.
      if overlap > 0, previousOverlap == 0 {
        scrollView.originalBottomInsets = scrollView.bottomInsets
      } else if overlap == 0, previousOverlap > 0, let saved = scrollView.originalBottomInsets {
        insets = saved
        scrollView.originalBottomInsets = nil
      }

      scrollView.bottomInsets = insets

      previousOverlap = overlap
    }
  }

  /// Stops calling keyboard show and hide observers for a given view.
  public func stopObserving(in containingView: UIView?) {
    guard let view = containingView else { return }
    observers[ObjectIdentifier(view)] = nil
  }

  // MARK: Private

  /// A specific observer of keyboard notifications for a given view.
  private class Observer {

    // MARK: Lifecycle

    init(observer: @escaping (CGFloat) -> Void, view: UIView) {
      self.view = view
      self.observer = observer
    }

    // MARK: Internal

    let observer: (CGFloat) -> Void

    /// We don't want to strongly retain the views in case the watcher outlives the view.
    private(set) weak var view: UIView?

  }

  /// The observers, keyed by their view's identifier.
  private var observers: [ObjectIdentifier: Observer] = [:]

  /// The current frame of the keyboard, in the main screen's coordinate space.
  private var keyboardFrame: CGRect?

  @objc
  private func keyboardWillShowOrHide(notification: Foundation.Notification) {
    keyboardFrame = notification.keyboardFrame
    updateObservers()
  }

  /// Calls each observer with their relevant overlap.
  private func updateObservers() {
    guard enabled, let keyboardFrame = keyboardFrame else { return }

    let observers = validObservers()
    guard !observers.isEmpty else { return }

    // Handle the keyboard frame being `.zero` when floating on iPad as an overlap of zero.
    guard keyboardFrame != .zero else {
      observers.forEach { $0.observer(0) }
      return
    }

    let screen = UIScreen.main

    for (view, observer) in observers {
      let overlap = overlap(for: view, keyboardFrame: keyboardFrame, in: screen)
      observer(overlap)
    }
  }

  /// Returns the keyboard's overlap with a given view.
  private func overlap(
    for view: UIView,
    keyboardFrame: CGRect,
    in screen: UIScreen)
    -> CGFloat
  {
    // If the keyboard is offscreen (hidden), always consider it to have a zero overlap to ensure we
    // don't consider slightly offscreen views as still having keyboard overlap.
    guard keyboardFrame.intersects(screen.bounds) else { return 0 }

    let keyboardFrameInView = screen.coordinateSpace.convert(keyboardFrame, to: view)
    let viewBounds = view.bounds
    let intersection = viewBounds.intersection(keyboardFrameInView)

    if intersection == .null {
      return 0
    } else {
      return viewBounds.maxY - intersection.minY
    }
  }

  /// Returns the observers with views that have not been deallocated, and culls the ones that have.
  private func validObservers() -> [(view: UIView, observer: (CGFloat) -> Void)] {
    var validObservers = [(view: UIView, observer: (CGFloat) -> Void)]()
    for (key, value) in observers {
      if let view = value.view {
        validObservers.append((view: view, observer: value.observer))
      } else {
        observers[key] = nil
      }
    }
    return validObservers
  }

  private func updateEnabled(from oldValue: Bool) {
    guard oldValue != enabled else { return }
    updateObservers()
  }

}

// MARK: - Notification

extension Notification {
  /// The frame of the keyboard, if this is a keyboard notification, else `nil`.
  @nonobjc
  fileprivate var keyboardFrame: CGRect? {
    userInfo?[UIResponder.keyboardFrameEndUserInfoKey].map { $0 as AnyObject }?.cgRectValue
  }
}

// MARK: - BottomInsets

/// The bottom insets on a scroll view that can be adjusted to have its content avoid the keyboard.
private struct BottomInsets {

  // MARK: Lifecycle

  init(
    content: CGFloat,
    verticalScrollIndicator: CGFloat,
    horizontalScrollIndicator: CGFloat)
  {
    self.content = content
    self.verticalScrollIndicator = verticalScrollIndicator
    self.horizontalScrollIndicator = horizontalScrollIndicator
  }

  init(inset: CGFloat) {
    content = inset
    verticalScrollIndicator = inset
    horizontalScrollIndicator = inset
  }

  // MARK: Internal

  var content: CGFloat
  var verticalScrollIndicator: CGFloat
  var horizontalScrollIndicator: CGFloat

}

// MARK: - UIScrollView

extension UIScrollView {

  // MARK: Public

  /// Whether a `KeyboardPositionWatcher` can adjust this scroll view's bottom content inset.
  ///
  /// Defaults to `true`.
  @nonobjc
  public var keyboardAdjustsBottomContentInset: Bool {
    get {
      objc_getAssociatedObject(self, &Keys.adjustsKeyboardPosition) as? Bool ?? true
    }
    set {
      objc_setAssociatedObject(self, &Keys.adjustsKeyboardPosition, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
  }

  /// The amount that the `contentInset.bottom` of this scroll view has been adjusted to accommodate
  /// for the keyboard by a `KeyboardPositionWatcher`, else `nil` if no adjustment has occurred.
  @nonobjc
  public var keyboardContentInsetAdjustment: CGFloat? {
    guard let originalBottomInsets = originalBottomInsets else { return nil }
    return max(contentInset.bottom - originalBottomInsets.content, 0)
  }

  // MARK: Fileprivate

  /// The bottom insets that are adjusted to have this scroll view's content avoid the keyboard.
  fileprivate var bottomInsets: BottomInsets {
    get {
      BottomInsets(
        content: contentInset.bottom,
        verticalScrollIndicator: verticalScrollIndicatorInsets.bottom,
        horizontalScrollIndicator: horizontalScrollIndicatorInsets.bottom)
    }
    set {
      contentInset.bottom = newValue.content
      verticalScrollIndicatorInsets.bottom = newValue.verticalScrollIndicator
      horizontalScrollIndicatorInsets.bottom = newValue.horizontalScrollIndicator
    }
  }

  /// The original bottom insets of this scroll view from before the keyboard was displayed,
  /// populated while the keyboard is visible and `nil` otherwise.
  fileprivate var originalBottomInsets: BottomInsets? {
    get {
      objc_getAssociatedObject(self, &Keys.originalBottomInsets) as? BottomInsets
    }
    set {
      objc_setAssociatedObject(self, &Keys.originalBottomInsets, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
  }

  /// Returns the bottom insets that can be used to have this scroll view's content avoid the given
  /// overlap distance, accounting for the safe area adjustment of the content inset or scroll
  /// indicator insets.
  fileprivate func insets(for overlap: CGFloat) -> BottomInsets {
    // Subtract out the inset that the `contentInsetAdjustmentBehavior` is applying to the content
    // insets since that inset will remain after setting the content inset.
    let contentAdjustment = max(0, adjustedContentInset.bottom - contentInset.bottom)
    let content = max(0, overlap - contentAdjustment)

    // Subtract out the inset that the `safeAreaInsets.bottom` is applying to the indicator insets
    // since that inset will remain after setting the indicator insets.
    let scrollIndicator: CGFloat
    if automaticallyAdjustsScrollIndicatorInsets {
      scrollIndicator = max(0, overlap - safeAreaInsets.bottom)
    } else {
      scrollIndicator = overlap
    }

    return .init(
      content: content,
      verticalScrollIndicator: scrollIndicator,
      horizontalScrollIndicator: scrollIndicator)
  }

}

// MARK: - Keys

/// Associated object keys.
private enum Keys {
  static var adjustsKeyboardPosition = 0
  static var originalBottomInsets = 0
}
