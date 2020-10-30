//  Created by Laura Skelton on 9/8/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

// MARK: - _SupplementaryViewEpoxyModel

/// A temporary typealias of a `_SupplementaryViewEpoxyModel` with a String `dataID` to ease
/// migration to `AnyHashable` `dataID`s.
public typealias SupplementaryViewEpoxyModel<ViewType: UIView, DataType> = _SupplementaryViewEpoxyModel<
  ViewType,
  DataType,
  String>

// MARK: - _SupplementaryViewEpoxyModel

public class _SupplementaryViewEpoxyModel<ViewType, DataType, DataID>: TypedSupplementaryViewEpoxyableModel where
  ViewType: UIView,
  DataID: Hashable
{
  public typealias View = ViewType

  // MARK: Lifecycle

  public init(
    elementKind: String,
    data: DataType,
    dataID: DataID,
    alternateStyleID: String? = nil,
    builder: @escaping () -> ViewType,
    configurer: @escaping (ViewType, DataType, UITraitCollection) -> Void,
    behaviorSetter: ((ViewType, DataType, DataID?) -> Void)? = nil)
  {
    self.elementKind = elementKind
    self.data = data
    self.dataID = dataID
    self.reuseID = "\(type(of: ViewType.self))_\(elementKind)_\(alternateStyleID ?? ""))"
    self.builder = builder
    self.configurer = configurer
    self.behaviorSetter = behaviorSetter
  }

  // MARK: Public

  public let elementKind: String
  public let dataID: DataID
  public let reuseID: String
  public let data: DataType

  public func makeView() -> ViewType {
    return builder()
  }

  public func configureView(
    _ view: ViewType,
    forTraitCollection traitCollection: UITraitCollection)
  {
    configurer(view, data, traitCollection)
  }

  public func setViewBehavior(_ view: ViewType) {
    behaviorSetter?(view, data, dataID)
  }

  // MARK: Private

  private let builder: () -> ViewType
  private let configurer: (ViewType, DataType, UITraitCollection) -> Void
  private let behaviorSetter: ((ViewType, DataType, DataID?) -> Void)?
}
