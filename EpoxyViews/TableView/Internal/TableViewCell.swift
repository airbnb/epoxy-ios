//  Created by Laura Skelton on 12/3/16.
//  Copyright © 2016 com.airbnb. All rights reserved.

import UIKit
import DLSPrimitives

/// An internal cell class for use in a `TableView`. It handles displaying a `Divider` and
/// wraps view classes passed to it.
public final class TableViewCell: UITableViewCell, EpoxyCell {

  // MARK: Lifecycle

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setUpViews()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var selectedBackgroundColor: UIColor?

  public private(set) var view: UIView?

  /// Pass a view for this cell's reuseID that the cell will pin to the edges of its `contentView`.
  public func setViewIfNeeded(view: UIView) {
    if self.view != nil { return }
    view.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(view)
    let constraints = [
      view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      view.topAnchor.constraint(equalTo: contentView.topAnchor)
    ]

    let bottomConstraint = view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    bottomConstraint.priority = UILayoutPriorityDefaultHigh - 1

    NSLayoutConstraint.activate(constraints + [bottomConstraint])

    self.view = view

    if let dividerView = dividerView {
      contentView.bringSubview(toFront: dividerView)
    }
  }

  public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)
    updateVisualHighlightState(highlighted, animated: true)
  }

  public override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    updateVisualHighlightState(selected, animated: animated)
  }

  // MARK: Internal

  private(set) var dividerView: UIView?

  /// Pass a `ViewMaker` that generates a `Divider` for this cell's reuseID that the cell will pin to the bottom of its `contentView`.
  func makeDividerViewIfNeeded(with dividerViewMaker: () -> UIView) {
    if self.dividerView != nil {
      return
    }
    let dividerView = dividerViewMaker()
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(dividerView)
    dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    dividerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    self.dividerView = dividerView
  }

  // MARK: Private

  private var normalViewBackgroundColor: UIColor?

  private func setUpViews() {
    #if swift(>=3.2)
    if #available(iOS 11.0, *) {
      contentView.insetsLayoutMarginsFromSafeArea = false
      insetsLayoutMarginsFromSafeArea = false
    }
    #endif
    backgroundColor = .clear
    selectionStyle = .none
  }

  private func updateVisualHighlightState(_ isVisuallyHighlighted: Bool) {
    if selectedBackgroundColor == nil { return }

    /// This is a temporary solution to support DLSComponentLibrary views that have a background color.
    /// Using the system animation sets the backgrounds of every subview to clear, which we don't want.
    if isVisuallyHighlighted {
      if (normalViewBackgroundColor == nil) {
        normalViewBackgroundColor = view?.backgroundColor
      }
      view?.backgroundColor = selectedBackgroundColor
    } else {
      view?.backgroundColor = normalViewBackgroundColor
    }
  }

  private func updateVisualHighlightState(_ isVisuallyHighlighted: Bool, animated: Bool) {
    if animated {
      UIView.animate(
        withDuration: Motion.durationShort,
        animations: {
          self.updateVisualHighlightState(isVisuallyHighlighted)
      })
    } else {
      updateVisualHighlightState(isVisuallyHighlighted)
    }
  }
}
