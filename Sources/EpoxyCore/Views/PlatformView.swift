// Created by Cal Stephens on 6/26/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import SwiftUI

#if canImport(UIKit)
import UIKit

public typealias UIViewOrNSView = UIView
public typealias UIViewControllerOrNSViewController = UIViewController
public typealias UIHostingControllerOrNSHostingController = UIHostingController
public typealias UIViewRepresentableOrNSViewRepresentable = UIViewRepresentable
public typealias UILayoutPriorityOrNSLayoutConstraintPriority = UILayoutPriority

extension UIViewRepresentableOrNSViewRepresentable {
  public typealias UIViewTypeOrNSViewType = UIViewType
}

#elseif canImport(AppKit)
import AppKit

public typealias UIViewOrNSView = NSView
public typealias UIViewControllerOrNSViewController = NSViewController
public typealias UIHostingControllerOrNSHostingController = NSHostingController
public typealias UIViewRepresentableOrNSViewRepresentable = NSViewRepresentable
public typealias UILayoutPriorityOrNSLayoutConstraintPriority = NSLayoutConstraint.Priority

extension UIViewRepresentableOrNSViewRepresentable {
  public typealias UIViewTypeOrNSViewType = NSViewType
}
#endif
