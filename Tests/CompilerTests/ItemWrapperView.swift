import UIKit

// MARK: - EmbeddedItemView

protocol EmbeddedItemView: ItemWrapperView { }

// MARK: - FocusableEmbeddedItemView

@MainActor
protocol FocusableEmbeddedItemView: EmbeddedItemView { }

// MARK: - EmbeddedView

final class EmbeddedView: UIView, FocusableEmbeddedItemView {
  var view: UIView? { nil }

  func setViewIfNeeded(view _: UIView) { }
}

@MainActor
func configure(_ view: any FocusableEmbeddedItemView, cell: any ItemCellView) {
  view.setViewIfNeeded(view: UIView())
  _ = view.view
  _ = cell.state
}
