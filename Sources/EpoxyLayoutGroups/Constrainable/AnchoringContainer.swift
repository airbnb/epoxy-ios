// Created by Tyler Hedrick on 6/11/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - AnchoringContainer

/// Defines a container that has an anchoring constrainable
/// Conforming to this protocol automatically implements the anchor
/// requirements for Constrainable
public protocol AnchoringContainer {
  var anchor: Constrainable { get }
}

extension Constrainable where Self: AnchoringContainer {
  public var leadingAnchor: NSLayoutXAxisAnchor { anchor.leadingAnchor }
  public var trailingAnchor: NSLayoutXAxisAnchor { anchor.trailingAnchor }
  public var leftAnchor: NSLayoutXAxisAnchor { anchor.leftAnchor }
  public var rightAnchor: NSLayoutXAxisAnchor { anchor.rightAnchor }
  public var topAnchor: NSLayoutYAxisAnchor { anchor.topAnchor }
  public var bottomAnchor: NSLayoutYAxisAnchor { anchor.bottomAnchor }
  public var widthAnchor: NSLayoutDimension { anchor.widthAnchor }
  public var heightAnchor: NSLayoutDimension { anchor.heightAnchor }
  public var centerXAnchor: NSLayoutXAxisAnchor { anchor.centerXAnchor }
  public var centerYAnchor: NSLayoutYAxisAnchor { anchor.centerYAnchor }
  public var firstBaselineAnchor: NSLayoutYAxisAnchor { anchor.firstBaselineAnchor }
  public var lastBaselineAnchor: NSLayoutYAxisAnchor { anchor.lastBaselineAnchor }
}
