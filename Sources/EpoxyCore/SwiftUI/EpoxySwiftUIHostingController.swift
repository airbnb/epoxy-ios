// Created by eric_horacek on 10/8/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import SwiftUI

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
  public convenience init(rootView: Content, ignoreSafeArea: Bool) {
    self.init(rootView: rootView)

    if ignoreSafeArea {
      disableSafeArea()
    }
  }

  // MARK: Private

  /// Creates a dynamic subclass of this hosting controller's view that ignores its safe area
  /// insets by overriding `safeAreaInsets` and returning `.zero`.
  ///
  /// This isn't possible at compile time since we can't override methods in a private view type.
  ///
  /// There's a private API that accomplishes this: `_disableSafeArea`, but we can't safely override
  /// it as the behavior may change out from under us.
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
