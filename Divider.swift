//  Created by Laura Skelton on 12/3/16.
//  Copyright © 2016 com.airbnb. All rights reserved.

import UIKit

// MARK: - Divider

/// A divider for use in a TableView
public class Divider: UIView {

  // MARK: Lifecycle

  public init() {
    dividerView = UIView()
    super.init(frame: CGRectZero)

    translatesAutoresizingMaskIntoConstraints = false
    setUp()
    setUpConstraints()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  /// Sets the height of the divider.
  ///
  /// - Parameters:
  ///     - height: The height of the divider.
  public func setHeight(height: CGFloat) {
    dividerHeightConstraint.constant = height
  }

  /// Sets the leading padding of the divider.
  ///
  /// - Parameters:
  ///     - leadingPadding: The leadingPadding of the divider.
  public func setLeadingPadding(leadingPadding: CGFloat) {
    dividerLeadingConstraint.constant = leadingPadding
  }

  /// Sets the trailing padding of the divider.
  ///
  /// - Parameters:
  ///     - trailingPadding: The trailingPadding of the divider.
  public func setTrailingPadding(trailingPadding: CGFloat) {
    dividerTrailingConstraint.constant = -trailingPadding
  }

  /// Sets the color of the divider.
  ///
  /// - Parameters:
  ///     - color: The color of the divider.
  public func setColor(color: UIColor?) {
    dividerView.backgroundColor = color
  }

  // MARK: Private

  private let dividerView: UIView
  private var dividerHeightConstraint: NSLayoutConstraint!
  private var dividerLeadingConstraint: NSLayoutConstraint!
  private var dividerTrailingConstraint: NSLayoutConstraint!

  private func setUp() {
    addSubview(dividerView)
  }

  private func setUpConstraints() {
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    dividerView.constrainToSuperview(attributes: [.top, .bottom])
    dividerHeightConstraint = dividerView.constrain(dimension: .height, to: 1)
    dividerLeadingConstraint = dividerView.constrain(attribute: .leading, to: .leading, of: self)
    dividerTrailingConstraint = dividerView.constrain(attribute: .trailing, to: .trailing, of: self)
  }
}
