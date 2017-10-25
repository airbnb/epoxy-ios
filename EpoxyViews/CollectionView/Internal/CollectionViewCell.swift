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

  public var selectedBackgroundColor: UIColor?

  override public var isSelected: Bool {
    didSet {
      updateVisualHighlightState(isSelected)
    }
  }

  override public var isHighlighted: Bool {
    didSet {
      updateVisualHighlightState(isHighlighted)
    }
  }

  /// Pass a view for this cell's reuseID that the cell will pin to the edges of its `contentView`.
  public func setViewIfNeeded(view: UIView) {
    guard self.view == nil else {
      return
    }
    view.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(view)
    view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    self.view = view
    normalViewBackgroundColor = view.backgroundColor
  }

  override public func preferredLayoutAttributesFitting(
    _ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes
  {
    guard let collectionViewLayoutAttributes = layoutAttributes as? CollectionViewLayoutAttributes else {
      return super.preferredLayoutAttributesFitting(layoutAttributes)
    }

    let horizontalFittingPriority = collectionViewLayoutAttributes.widthSizeMode == .dynamic
      ? UILayoutPriorityFittingSizeLevel
      : UILayoutPriorityRequired

    let verticalFittingPriority = collectionViewLayoutAttributes.heightSizeMode == .dynamic
      ? UILayoutPriorityFittingSizeLevel
      : UILayoutPriorityRequired

    let size = super.systemLayoutSizeFitting(
      layoutAttributes.size,
      withHorizontalFittingPriority: horizontalFittingPriority,
      verticalFittingPriority: verticalFittingPriority)

    layoutAttributes.size = size

    return layoutAttributes
  }

  // MARK: Private

  private var normalViewBackgroundColor: UIColor?

  private func updateVisualHighlightState(_ isVisuallyHighlighted: Bool) {
    if selectedBackgroundColor == nil { return }

    /// This is a temporary solution to support DLSComponentLibrary views that have a background color.
    /// This only works if subviews have a clear background color.
    if isVisuallyHighlighted {
      view?.backgroundColor = selectedBackgroundColor
    } else {
      view?.backgroundColor = normalViewBackgroundColor
    }
  }

}
