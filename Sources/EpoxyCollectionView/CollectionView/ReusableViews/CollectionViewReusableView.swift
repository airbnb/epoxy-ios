//  Created by Laura Skelton on 9/8/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// An internal collection reusable view class for use in a `CollectionView`.
public final class CollectionViewReusableView: UICollectionReusableView {

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
  }

  @available(*, unavailable)
  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public private(set) var view: UIView?

  /// Pass a view for this view's element kind and reuseID that the view will pin to its edges.
  public func setViewIfNeeded(view: UIView) {
    if self.view != nil {
      return
    }
    view.translatesAutoresizingMaskIntoConstraints = false
    // Use the existing view size so that we don't have to wait for auto layout to give this
    // wrapped view an initial size.
    view.frame = bounds
    addSubview(view)
    NSLayoutConstraint.activate([
      view.leadingAnchor.constraint(equalTo: leadingAnchor),
      view.trailingAnchor.constraint(equalTo: trailingAnchor),
      view.topAnchor.constraint(equalTo: topAnchor),
      view.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
    self.view = view
  }

  override public func preferredLayoutAttributesFitting(
    _ layoutAttributes: UICollectionViewLayoutAttributes)
    -> UICollectionViewLayoutAttributes
  {
    guard let fittingPrioritiesProvider = layoutAttributes as? FittingPrioritiesProvidingLayoutAttributes else {
      return super.preferredLayoutAttributesFitting(layoutAttributes)
    }

    let horizontalFittingPriority = fittingPrioritiesProvider.horizontalFittingPriority
    let verticalFittingPriority = fittingPrioritiesProvider.verticalFittingPriority

    let size: CGSize
    if horizontalFittingPriority != .required || verticalFittingPriority != .required {
      // Self-sizing is required in at least one dimension.
      size = super.systemLayoutSizeFitting(
        layoutAttributes.size,
        withHorizontalFittingPriority: horizontalFittingPriority,
        verticalFittingPriority: verticalFittingPriority)
    } else {
      // No self-sizing is required; respect whatever size the layout determined.
      size = layoutAttributes.size
    }

    layoutAttributes.size = size

    return layoutAttributes
  }

  // MARK: Internal

  /// The item path of the supplementary view from its last configuration update. Used to associate the view with the underlying data. When collection
  /// view provides view display callbacks, if it is mid update, we need this to see if the view came from pre-update data or
  /// post-update data.
  var itemPath: SupplementaryItemPath?

}
