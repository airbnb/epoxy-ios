// Created by eric_horacek on 10/8/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import SwiftUI

#if !os(macOS)
// MARK: - EpoxySwiftUIUIHostingController

/// A `UIHostingController` that hosts SwiftUI views within an Epoxy container, e.g. an Epoxy
/// `CollectionView`.
///
/// Exposed publicly to allow consumers to reason about these view controllers, e.g. to opt
/// collection view cells out of automated view controller impression tracking.
///
/// - SeeAlso: `EpoxySwiftUIHostingView`
open class EpoxySwiftUIHostingController<Content: View>: UIHostingController<Content> {

  // MARK: Lifecycle

  /// Creates a `UIHostingController` that optionally ignores the `safeAreaInsets` when laying out
  /// its contained `RootView`.
  public convenience init(rootView: Content, ignoresSafeArea: Bool, ignoresKeyboardAvoidance: Bool) {
    self.init(rootView: rootView)

    // We unfortunately need to call a private API to disable the safe area. We can also accomplish
    // this by dynamically subclassing this view controller's view at runtime and overriding its
    // `safeAreaInsets` property and returning `.zero`. An implementation of that logic is
    // available in this file in the `2d28b3181cca50b89618b54836f7a9b6e36ea78e` commit if this API
    // no longer functions in future SwiftUI versions.
    _disableSafeArea = ignoresSafeArea

    if ignoresKeyboardAvoidance {
      disableKeyboardAvoidance()
    }
  }

  // MARK: Open

  open override func viewDidLoad() {
    super.viewDidLoad()

    // A `UIHostingController` has a system background color by default as it's typically used in
    // full-screen use cases. Since we're using this view controller to place SwiftUI views within
    // other view controllers we default the background color to clear so we can see the views
    // below, e.g. to draw highlight states in a `CollectionView`.
    view.backgroundColor = .clear
  }

  // MARK: Private

  /// Creates a dynamic subclass of this hosting controller's view that disables its keyboard
  /// avoidance behavior.
  /// Setting `safeAreaRegions` to `.container` is preferred on iOS 16.4+, as this approach breaks on iOS 26.
  /// See [here](https://steipete.com/posts/disabling-keyboard-avoidance-in-swiftui-uihostingcontroller/) for more info.
  private func disableKeyboardAvoidance() {
    if #available(iOS 16.4, *) {
      self.safeAreaRegions = .container
      return
    }

    guard let viewClass = object_getClass(view) else {
      EpoxyLogger.shared.assertionFailure("Unable to determine class of \(String(describing: view))")
      return
    }

    let viewClassName = class_getName(viewClass)
    let viewSubclassName = String(cString: viewClassName).appending("_IgnoresKeyboard")

    // If subclass already exists, just set the class of `view` and return.
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

    let selector = NSSelectorFromString("keyboardWillShowWithNotification:")
    guard let method = class_getInstanceMethod(viewClass, selector) else {
      EpoxyLogger.shared.assertionFailure("Unable to locate method \(selector) on \(viewClass)")
      objc_disposeClassPair(viewSubclass)
      return
    }

    let keyboardWillShowOverride: @convention(block) (AnyObject, AnyObject) -> Void = { _, _ in }
    let implementation = imp_implementationWithBlock(keyboardWillShowOverride)
    let typeEncoding = method_getTypeEncoding(method)
    class_addMethod(viewSubclass, selector, implementation, typeEncoding)

    objc_registerClassPair(viewSubclass)
    object_setClass(view, viewSubclass)
  }
}
#endif
