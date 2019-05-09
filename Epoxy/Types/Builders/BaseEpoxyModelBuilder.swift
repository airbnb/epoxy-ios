// Created by tyler_hedrick on 7/11/18.
// Copyright © 2018 Airbnb. All rights reserved.

import UIKit

// MARK: - BaseEpoxyModelBuilder

/// An object used to progressively build EpoxyModels
public final class BaseEpoxyModelBuilder<ViewType, DataType> where
  ViewType: UIView,
  DataType: Equatable
{

  public init(data: DataType, dataID: String) {
    self.data = data
    self.dataID = dataID
  }

  // MARK: Public

  /// Builds the final immutable EpoxyModel from the current data
  ///
  /// - Returns: an EpoxyModel
  public func build() -> EpoxyModel<ViewType, DataType> {
    return EpoxyModel<ViewType, DataType>(
      data: data,
      dataID: dataID,
      alternateStyleID: alternateStyleID,
      builder: builder,
      configurer: configurer,
      stateConfigurer: stateConfigurer,
      behaviorSetter: behaviorSetter,
      selectionHandler: selectionHandler,
      userInfo: userInfo)
  }

  public func with(alternateStyleID: String?) -> BaseEpoxyModelBuilder {
    self.alternateStyleID = alternateStyleID
    return self
  }

  public func with(viewBuilder: @escaping () -> ViewType) -> BaseEpoxyModelBuilder {
    self.builder = viewBuilder
    return self
  }

  public func with(configurer: @escaping (ViewType, DataType, UITraitCollection, Bool) -> Void) -> BaseEpoxyModelBuilder {
    self.configurer = configurer
    return self
  }

  public func with(stateConfigurer: ((ViewType, DataType, UITraitCollection, EpoxyCellState) -> Void)?) -> BaseEpoxyModelBuilder {
    self.stateConfigurer = stateConfigurer
    return self
  }

  public func with(behaviorSetter: ((ViewType, DataType, String) -> Void)?) -> BaseEpoxyModelBuilder {
    self.behaviorSetter = behaviorSetter
    return self
  }

  public func with(selectionHandler: ((ViewType, DataType, String) -> Void)?) -> BaseEpoxyModelBuilder {
    self.selectionHandler = selectionHandler
    return self
  }

  public func with(userInfo: [EpoxyUserInfoKey: Any]) -> BaseEpoxyModelBuilder {
    self.userInfo = userInfo
    return self
  }

  public func withSetUserInfoValue(_ value: Any, for key: EpoxyUserInfoKey) -> BaseEpoxyModelBuilder {
    userInfo[key] = value
    return self
  }

  // MARK: Private

  private var data: DataType
  private var dataID: String
  private var alternateStyleID: String? = nil
  private var builder: () -> ViewType = { ViewType() }
  private var configurer: (ViewType, DataType, UITraitCollection, Bool) -> Void = { _, _, _, _ in }
  private var stateConfigurer: ((ViewType, DataType, UITraitCollection, EpoxyCellState) -> Void)? = nil
  private var behaviorSetter: ((ViewType, DataType, String) -> Void)? = nil
  private var selectionHandler: ((ViewType, DataType, String) -> Void)? = nil
  private var userInfo: [EpoxyUserInfoKey: Any] = [:]
}

// MARK: Subscript

extension BaseEpoxyModelBuilder {
  /// provides a subscript interface to set and get values from the userInfo
  /// dictionary on a builder
  /// example usage: `builder[EpoxyUserInfoKey.customKey] = customValue`
  public subscript<T>(key: EpoxyUserInfoKey) -> T? {
    get { return userInfo[key] as? T }
    set { userInfo[key] = newValue }
  }
}
