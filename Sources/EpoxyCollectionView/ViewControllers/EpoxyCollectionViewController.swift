//  Created by Laura Skelton on 6/30/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

open class EpoxyCollectionViewController: UIViewController {

  // MARK: Lifecycle

  public init(
    collectionViewLayout: UICollectionViewLayout,
    epoxyLogger: EpoxyLogging = DefaultEpoxyLogger())
  {
    self.collectionViewLayout = collectionViewLayout
    self.epoxyLogger = epoxyLogger
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Open

  open override func viewDidLoad() {
    super.viewDidLoad()
    setUpViews()
    setUpConstraints()
  }

  open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    setEpoxySectionsIfReady()
  }

  /// Override this in your subclass to return your sections.
  open func epoxySections() -> [SectionModel] {
    return []
  }

  /// Returns a `CollectionView` by default. Override this to configure it differently.
  open func makeCollectionView() -> CollectionView {
    return CollectionView(collectionViewLayout: collectionViewLayout, epoxyLogger: epoxyLogger)
  }

  // MARK: Public

  public var contentOffset: CGPoint? {
    return collectionView.contentOffset
  }

  public lazy var collectionView: CollectionView = {
    epoxyLogger.epoxyAssert(self.isViewLoaded, "Accessed collectionView before view was loaded.")
    return self.makeCollectionView()
  }()

  /// Updates the Epoxy view by calling the `epoxySections()` method. Optionally animated.
  public func updateData(animated: Bool) {
    if isViewLoaded && traitCollection.horizontalSizeClass != .unspecified {
      let sections = epoxySections()
      collectionView.setSections(sections, animated: animated)
    }
  }

  // MARK: Private

  private let collectionViewLayout: UICollectionViewLayout
  private let epoxyLogger: EpoxyLogging

  private func setUpViews() {
    view.backgroundColor = .white
    view.addSubview(collectionView)
    collectionView.layoutDelegate = self
    setEpoxySectionsIfReady()
  }

  private func setUpConstraints() {
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    let constraints = [
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ]
    NSLayoutConstraint.activate(constraints)
  }

  private func setEpoxySectionsIfReady() {
    if traitCollection.horizontalSizeClass != .unspecified {
      updateData(animated: false)
    }
  }

}
