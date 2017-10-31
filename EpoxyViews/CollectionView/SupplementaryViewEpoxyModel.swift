//  Created by Laura Skelton on 9/8/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

public class SupplementaryViewEpoxyModel<ViewType, DataType>: TypedSupplementaryViewEpoxyableModel where
  ViewType: UIView
{
  public typealias View = ViewType

  // MARK: Lifecycle

  public init(
    elementKind: String,
    data: DataType,
    dataID: String,
    alternateStyleID: String? = nil,
    builder: @escaping () -> ViewType,
    configurer: @escaping (ViewType, DataType, UITraitCollection) -> Void)
  {
    self.elementKind = elementKind
    self.data = data
    self.dataID = dataID
    self.reuseID = "\(type(of: ViewType.self))_\(elementKind)_\(alternateStyleID ?? ""))"
    self.builder = builder
    self.configurer = configurer
  }

  // MARK: Public

  public let elementKind: String
  public let dataID: String
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

  // MARK: Private

  private let builder: () -> ViewType
  private let configurer: (ViewType, DataType, UITraitCollection) -> Void
}
