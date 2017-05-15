//  Created by Laura Skelton on 12/3/16.
//  Copyright © 2016 com.airbnb. All rights reserved.

import UIKit

// MARK: - Divider

/// A divider for use in a TableView
public class Divider: UIView {

  // MARK: Lifecycle

  public init() {
    super.init(frame: .zero)
    isOpaque = false
    translatesAutoresizingMaskIntoConstraints = false
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  /// The height of the divider.
  public var height: CGFloat = 0 {
    didSet {
      if height != oldValue {
        setNeedsDisplay()
        invalidateIntrinsicContentSize()
      }
    }
  }

  /// The leading padding of the divider.
  public var leadingPadding: CGFloat = 0 {
    didSet {
      if leadingPadding != oldValue {
        setNeedsDisplay()
      }
    }
  }

  /// The trailing padding of the divider.
  public var trailingPadding: CGFloat = 0 {
    didSet {
      if trailingPadding != oldValue {
        setNeedsDisplay()
      }
    }
  }

  /// The color of the divider.
  public var color: UIColor? {
    didSet {
      if color != oldValue {
        setNeedsDisplay()
      }
    }
  }

  public override var intrinsicContentSize: CGSize {
    return CGSize(width: UIViewNoIntrinsicMetric, height: height)
  }

  public override func draw(_ rect: CGRect) {
    guard let color = color else {
      assert(false, "You shouldn't be using a divider without a color")
      return
    }

    let context = UIGraphicsGetCurrentContext()!
    context.clear(rect)
    var dividerRect = rect
    dividerRect.origin.x = leadingPadding
    dividerRect.size.width -= leadingPadding + trailingPadding

    context.setFillColor(color.cgColor)
    context.fill(dividerRect)
  }
}
