//  Created by Laura Skelton on 5/19/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// An internal cell class for use in a `CollectionView`.
public final class CollectionViewCell: UICollectionViewCell, EpoxyCell {

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

  /// Pass a view for this cell's reuseID that the cell will pin to the edges of its `contentView`.
  public func setViewIfNeeded(view: UIView) {
    if self.view != nil {
      return
    }
    view.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(view)
    view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    let bottomConstraint = view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    bottomConstraint.priority = UILayoutPriorityDefaultHigh - 1 // Needed to allow cell to properly size itself. This should not be changed. See equivalent code in `TableViewCell`
    bottomConstraint.isActive = true
    self.view = view
  }

  override public func preferredLayoutAttributesFitting(
    _ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes
  {
    guard let collectionViewLayoutAttributes = layoutAttributes as? CollectionViewLayoutAttributes else {
      return super.preferredLayoutAttributesFitting(layoutAttributes)
    }

    let horizontalFittingPriority = collectionViewLayoutAttributes.widthSizeMode == .dynamic
      ? UILayoutPriorityDefaultHigh
      : UILayoutPriorityRequired

    let verticalFittingPriority = collectionViewLayoutAttributes.heightSizeMode == .dynamic
      ? UILayoutPriorityDefaultHigh
      : UILayoutPriorityRequired

    let size = super.systemLayoutSizeFitting(
      layoutAttributes.size,
      withHorizontalFittingPriority: horizontalFittingPriority,
      verticalFittingPriority: verticalFittingPriority)

    layoutAttributes.size = size

    return layoutAttributes
  }

}
