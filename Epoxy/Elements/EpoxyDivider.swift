//  Created by Laura Skelton on 12/3/16.
//  Copyright © 2016 com.airbnb. All rights reserved.

import UIKit

// MARK: - EpoxyDivider

/// A divider for use in a TableView or CollectionView
public class EpoxyDivider: UIView {

  // MARK: Lifecycle

  public init(epoxyLogger: EpoxyLogging) {
    self.epoxyLogger = epoxyLogger
    super.init(frame: .zero)
    contentMode = .redraw
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

  /// The top padding of the divider.
  public var topPadding: CGFloat = 0 {
    didSet {
      if topPadding != oldValue {
        setNeedsDisplay()
        invalidateIntrinsicContentSize()
      }
    }
  }

  /// The bottom padding of the divider.
  public var bottomPadding: CGFloat = 0 {
    didSet {
      if bottomPadding != oldValue {
        setNeedsDisplay()
        invalidateIntrinsicContentSize()
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
    return CGSize(width: UIView.noIntrinsicMetric, height: height + topPadding + bottomPadding)
  }

  public override func draw(_ rect: CGRect) {
    guard let color = color else {
      epoxyLogger.epoxyAssert(false, "You shouldn't be using a divider without a color")
      return
    }

    let context = UIGraphicsGetCurrentContext()!
    context.clear(rect)
    var dividerRect = rect
    dividerRect.origin.x = leadingPadding
    dividerRect.size.width -= leadingPadding + trailingPadding
    dividerRect.origin.y = topPadding
    dividerRect.size.height = height

    context.setFillColor(color.cgColor)
    context.fill(dividerRect)
  }

  // MARK: Private

  private let epoxyLogger: EpoxyLogging
}
