//  Created by Laura Skelton on 9/8/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// An internal cell class for use in a `CollectionView`.
public final class CollectionViewReusableView: UICollectionReusableView {

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public private(set) var view: UIView?

  /// Pass a view for this view's element kind and reuseID that the cell will pin to the edges of its `contentView`.
  public func setViewIfNeeded(view: UIView) {
    if self.view != nil {
      return
    }
    view.translatesAutoresizingMaskIntoConstraints = false
    addSubview(view)
    let constraints = [
      view.leadingAnchor.constraint(equalTo: leadingAnchor),
      view.trailingAnchor.constraint(equalTo: trailingAnchor),
      view.topAnchor.constraint(equalTo: topAnchor),
      view.bottomAnchor.constraint(equalTo: bottomAnchor),
    ]
    NSLayoutConstraint.activate(constraints)
    self.view = view
  }

  override public func preferredLayoutAttributesFitting(
    _ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes
  {
    guard let collectionViewLayoutAttributes = layoutAttributes as? CollectionViewLayoutAttributes else {
      return super.preferredLayoutAttributesFitting(layoutAttributes)
    }

    let size = super.systemLayoutSizeFitting(
      layoutAttributes.size,
      withHorizontalFittingPriority: collectionViewLayoutAttributes.widthSizeMode.fittingPriority,
      verticalFittingPriority: collectionViewLayoutAttributes.heightSizeMode.fittingPriority)

    layoutAttributes.size = size

    return layoutAttributes
  }
}
