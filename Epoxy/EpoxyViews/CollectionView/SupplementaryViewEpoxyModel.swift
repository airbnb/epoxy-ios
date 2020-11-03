//  Created by Laura Skelton on 9/8/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

// MARK: - SupplementaryViewEpoxyModel

public class SupplementaryViewEpoxyModel<ViewType, DataType>: TypedSupplementaryViewEpoxyableModel where
  ViewType: UIView
{
  public typealias View = ViewType

  // MARK: Lifecycle

  public init(
    elementKind: String,
    data: DataType,
    dataID: AnyHashable,
    alternateStyleID: String? = nil,
    builder: @escaping () -> ViewType,
    configurer: @escaping (ViewType, DataType, UITraitCollection) -> Void,
    behaviorSetter: ((ViewType, DataType, AnyHashable?) -> Void)? = nil)
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
  public let dataID: AnyHashable
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
  private let behaviorSetter: ((ViewType, DataType, AnyHashable?) -> Void)?
}
