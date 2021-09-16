// Created by eric_horacek on 9/16/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - SwiftUIHostingViewReuseID

/// The ID that's dictates the reuse behavior of a `SwiftUIHostingView`.
public enum SwiftUIHostingViewReuseID: Hashable {
  /// Instances of a `SwiftUIHostingView` with `RootView`s of same type can be reused within the
  /// Epoxy container.
  case reusable
  /// Instances of a `SwiftUIHostingView` with `RootView`s of same type can only reused within the
  /// Epoxy container when they have identical `reuseID`s.
  case unique(reuseID: AnyHashable)
}

// MARK: - CallbackContextEpoxyModeled

extension CallbackContextEpoxyModeled
  where
  Self: WillDisplayProviding & DidEndDisplayingProviding,
  CallbackContext: ViewProviding & AnimatedProviding
{
  /// Updates the appearance state of a `SwiftUIHostingView` in coordination with the `willDisplay`
  /// and `didEndDisplaying` callbacks of this `EpoxyableModel`.
  ///
  /// - Note: You should only need to call then from the implementation of a concrete
  ///   `EpoxyableModel` convenience vendor method, e.g. `SwiftUI.View.itemModel(…)`.
  public func linkDisplayLifecycle<RootView: View>() -> Self
    where
    CallbackContext.View == SwiftUIHostingView<RootView>
  {
    willDisplay { context in
      context.view.handleWillDisplay(animated: context.animated)
    }
    .didEndDisplaying { context in
      context.view.handleDidEndDisplaying(animated: context.animated)
    }
  }
}

// MARK: - SwiftUIHostingView

public final class SwiftUIHostingView<RootView: View>: UIView, EpoxyableView {

  // MARK: Lifecycle

  public init(style: Style) {
    // Ignore the safe area to ensure the view isn't laid out incorrectly when being sized while
    // overlapping the safe area.
    viewController = UIHostingController(
      rootView: style.initialContent.rootView,
      ignoreSafeArea: true)

    dataID = style.initialContent.dataID ?? DefaultDataID.noneProvided as AnyHashable

    super.init(frame: .zero)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public struct Style: Hashable {
    public init(reuseID: SwiftUIHostingViewReuseID, initialContent: Content) {
      self.reuseID = reuseID
      self.initialContent = initialContent
    }

    public var reuseID: SwiftUIHostingViewReuseID
    public var initialContent: Content

    public static func == (lhs: Style, rhs: Style) -> Bool {
      lhs.reuseID == rhs.reuseID
    }
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(reuseID)
    }
  }

  public struct Content: Equatable {
    public init(rootView: RootView, dataID: AnyHashable?) {
      self.rootView = rootView
      self.dataID = dataID
    }

    public var rootView: RootView
    public var dataID: AnyHashable?

    public static func == (lhs: Content, rhs: Content) -> Bool {
      // The content should never be equal since we need the `rootView` to be updated on every
      // content change.
      false
    }
  }

  public override func didMoveToWindow() {
    super.didMoveToWindow()

    // We'll only be able to discover a valid parent `viewController` once we're added to a window,
    // so we do so here in addition to the `handleWillDisplay(…)` method.
    if window != nil {
      addViewControllerIfNeeded()
    }
  }

  public func setContent(_ content: Content, animated: Bool) {
    // The view controller must be added to the view controller hierarchy to measure its content.
    if window != nil {
      addViewControllerIfNeeded()
    }

    viewController.rootView = content.rootView
    dataID = content.dataID ?? DefaultDataID.noneProvided as AnyHashable

    /// This is required to ensure that views with new content are properly resized.
    viewController.view.invalidateIntrinsicContentSize()
  }

  public override func layoutMarginsDidChange() {
    super.layoutMarginsDidChange()

    // TODO: Pass through layout margins to the contained SwiftUI view.
  }

  // MARK: Internal

  func handleWillDisplay(animated: Bool) {
    guard state != .appeared, window != nil else { return }
    transition(to: .appearing(animated: animated))
    transition(to: .appeared)
  }

  func handleDidEndDisplaying(animated: Bool) {
    guard state != .disappeared else { return }
    transition(to: .disappearing(animated: animated))
    transition(to: .disappeared)
  }

  // MARK: Private

  private let viewController: UIHostingController<RootView>
  private var dataID: AnyHashable
  private var state: AppearanceState = .disappeared

  /// Updates the appearance state of the `viewController`.
  private func transition(to state: AppearanceState) {
    guard state != self.state else { return }

    // See "Handling View-Related Notifications" section for the state machine diagram.
    // https://developer.apple.com/documentation/uikit/uiviewcontroller
    switch (to: state, from: self.state) {
    case (to: .appearing(let animated), from: .disappeared):
      viewController.beginAppearanceTransition(true, animated: animated)
      addViewControllerIfNeeded()
    case (to: .disappearing(let animated), from: .appeared):
      viewController.beginAppearanceTransition(false, animated: animated)
    case (to: .disappeared, from: .disappearing):
      removeViewControllerIfNeeded()
      viewController.endAppearanceTransition()
    case (to: .appeared, from: .appearing):
      viewController.endAppearanceTransition()
    case (to: .disappeared, from: .appeared):
      viewController.beginAppearanceTransition(false, animated: true)
      removeViewControllerIfNeeded()
      viewController.endAppearanceTransition()
    case (to: .appeared, from: .disappearing(let animated)):
      viewController.beginAppearanceTransition(true, animated: animated)
      viewController.endAppearanceTransition()
    case (to: .disappeared, from: .appearing(let animated)):
      viewController.beginAppearanceTransition(false, animated: animated)
      removeViewControllerIfNeeded()
      viewController.endAppearanceTransition()
    case (to: .appeared, from: .disappeared):
      viewController.beginAppearanceTransition(true, animated: false)
      addViewControllerIfNeeded()
      viewController.endAppearanceTransition()
    case (to: .appearing(let animated), from: .appeared):
      viewController.beginAppearanceTransition(false, animated: animated)
      viewController.beginAppearanceTransition(true, animated: animated)
    case (to: .appearing(let animated), from: .disappearing):
      viewController.beginAppearanceTransition(true, animated: animated)
    case (to: .disappearing(let animated), from: .disappeared):
      viewController.beginAppearanceTransition(true, animated: animated)
      addViewControllerIfNeeded()
      viewController.beginAppearanceTransition(false, animated: animated)
    case (to: .disappearing(let animated), from: .appearing):
      viewController.beginAppearanceTransition(false, animated: animated)
    case (to: .appearing, from: .appearing),
         (to: .appeared, from: .appeared),
         (to: .disappearing, from: .disappearing),
         (to: .disappeared, from: .disappeared):
      // This should never happen since we guard on identical states.
      EpoxyLogger.shared.assertionFailure("Impossible state change from \(self.state) to \(state)")
    }

    self.state = state
  }

  private func addViewControllerIfNeeded() {
    guard let nextViewController = superview?.next(UIViewController.self) else {
      EpoxyLogger.shared.assertionFailure(
        """
        Unable to add a UIHostingController view, could not locate a UIViewController in the \
        responder chain for view with ID \(dataID) of type \(RootView.self).
        """)
      return
    }

    guard viewController.parent !== nextViewController else { return }

    // If in a different parent, we need to first remove from it before we add.
    if viewController.parent != nil {
      removeViewControllerIfNeeded()
    }

    addViewController(to: nextViewController)

    state = .appeared
  }

  private func addViewController(to parent: UIViewController) {
    viewController.willMove(toParent: parent)
    parent.addChild(viewController)
    addSubview(viewController.view)
    viewController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      viewController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
      viewController.view.topAnchor.constraint(equalTo: topAnchor),
      viewController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
      viewController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
    viewController.didMove(toParent: parent)
  }

  private func removeViewControllerIfNeeded() {
    guard viewController.parent != nil else { return }

    viewController.willMove(toParent: nil)
    viewController.view.removeFromSuperview()
    viewController.removeFromParent()
    viewController.didMove(toParent: nil)
  }
}

// MARK: - AppearanceState

/// The appearance state of a `UIHostingController` contained within a `SwiftUIHostingView`.
private enum AppearanceState: Equatable {
  case appearing(animated: Bool)
  case appeared
  case disappearing(animated: Bool)
  case disappeared
}

// MARK: - UIResponder

extension UIResponder {
  /// Recursively traverses the responder chain upwards from this responder to its next responder
  /// until the a responder of the given type is located, else returns `nil`.
  @nonobjc
  fileprivate func next<ResponderType>(_ type: ResponderType.Type) -> ResponderType? {
    self as? ResponderType ?? next?.next(type)
  }
}

// MARK: - UIHostingController

extension UIHostingController {
  /// Creates a `UIHostingController` that optionally ignores the `safeAreaInsets` when laying out
  /// its contained `RootView`.
  convenience public init(rootView: Content, ignoreSafeArea: Bool) {
    self.init(rootView: rootView)

    if ignoreSafeArea {
      disableSafeArea()
    }
  }

  /// Creates a dynamic subclass of this hosting controller's view that ignores its safe area
  /// insets by overriding `safeAreaInsets` and returning `.zero`.
  ///
  /// This isn't possible at compile time since we're can't override methods in a private view type.
  private func disableSafeArea() {
    guard let viewClass = object_getClass(view) else {
      EpoxyLogger.shared.assertionFailure(
        "Unable to determine class of \(String(describing: view))")
      return
    }

    let viewClassName = class_getName(viewClass)
    let viewSubclassName = String(cString: viewClassName).appending("_EpoxySafeAreaOverride")

    // The subclass already exists, just set the class of `view` and return.
    if let subclass = NSClassFromString(viewSubclassName) {
      object_setClass(view, subclass)
      return
    }

    guard let viewSubclassNameUTF8 = (viewSubclassName as NSString).utf8String else {
      EpoxyLogger.shared.assertionFailure("Unable to get utf8String of \(viewSubclassName)")
      return
    }

    guard let viewSubclass = objc_allocateClassPair(viewClass, viewSubclassNameUTF8, 0) else {
      EpoxyLogger.shared.assertionFailure(
        "Unable to subclass \(viewClass) with \(viewSubclassNameUTF8)")
      return
    }

    let selector = #selector(getter: UIView.safeAreaInsets)
    guard let method = class_getInstanceMethod(UIView.self, selector) else {
      EpoxyLogger.shared.assertionFailure("Unable to locate method \(selector) on \(UIView.self)")
      objc_disposeClassPair(viewSubclass)
      return
    }

    let safeAreaInsetsOverride: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in .zero }
    let implementation = imp_implementationWithBlock(safeAreaInsetsOverride)
    let typeEncoding = method_getTypeEncoding(method)
    class_addMethod(viewSubclass, selector, implementation, typeEncoding)

    objc_registerClassPair(viewSubclass)
    object_setClass(view, viewSubclass)
  }
}
