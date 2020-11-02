// Created by tyler_hedrick on 7/11/18.
// Copyright © 2018 Airbnb. All rights reserved.

import UIKit

// MARK: - BaseEpoxyModelBuilder

/// A temporary typealias of a `_BaseEpoxyModelBuilder` with a String `dataID` to ease migration to
/// `AnyHashable` `dataID`s.
public typealias BaseEpoxyModelBuilder<ViewType: UIView, DataType: Equatable> = _BaseEpoxyModelBuilder<
  ViewType,
  DataType,
  String>

// MARK: - _BaseEpoxyModelBuilder

/// An object used to progressively build EpoxyModels
public final class _BaseEpoxyModelBuilder<ViewType, DataType, DataID> where
  ViewType: UIView,
  DataType: Equatable,
  DataID: Hashable
{

  public init(data: DataType, dataID: DataID) {
    self.data = data
    self.dataID = dataID
  }

  // MARK: Public

  /// Builds the final immutable EpoxyModel from the current data
  ///
  /// - Returns: an EpoxyModel
  public func build() -> _EpoxyModel<ViewType, DataType, DataID> {
    return _EpoxyModel<ViewType, DataType, DataID>(
      data: data,
      dataID: dataID,
      alternateStyleID: alternateStyleID,
      makeView: makeView,
      configureView: configureView,
      didChangeState: didChangeState,
      setBehaviors: behaviorSetter,
      didSelect: didSelect,
      willDisplay: willDisplay,
      didEndDisplaying: didEndDisplaying,
      userInfo: userInfo)
  }

  public func alternateStyleID(_ alternateStyleID: String?) -> _BaseEpoxyModelBuilder {
    self.alternateStyleID = alternateStyleID
    return self
  }

  public func makeView(_ makeView: @escaping () -> ViewType) -> _BaseEpoxyModelBuilder {
    self.makeView = makeView
    return self
  }

  /**
   NOTE: The with(...) functions which take closures and return Void apply additively if you call them multiple times.
   This is intended to allow for layering additional logic on top of a model produced somewhere else.
   */

  public func configureView(_ configureView: @escaping (EpoxyContext<ViewType, DataType, DataID>) -> Void) -> _BaseEpoxyModelBuilder {
    let oldConfigureView = self.configureView
    self.configureView = { context in
      oldConfigureView(context)
      configureView(context)
    }

    return self
  }

  public func setBehaviors(_ behaviorSetter: ((EpoxyContext<ViewType, DataType, DataID>) -> Void)?) -> _BaseEpoxyModelBuilder {
    guard let newBehaviorSetter = behaviorSetter else { return self }

    if let oldBehaviorSetter = self.behaviorSetter {
      self.behaviorSetter = { context in
        oldBehaviorSetter(context)
        newBehaviorSetter(context)
      }
    } else {
      self.behaviorSetter = newBehaviorSetter
    }

    return self
  }

  public func didSelect(_ didSelect: ((EpoxyContext<ViewType, DataType, DataID>) -> Void)?) -> _BaseEpoxyModelBuilder {
    guard let newDidSelect = didSelect else { return self }

    if let oldDidSelect = self.didSelect {
      self.didSelect = { context in
        oldDidSelect(context)
        newDidSelect(context)
      }
    } else {
      self.didSelect = newDidSelect
    }

    return self
  }

  public func didChangeState(_ didChangeState: ((EpoxyContext<ViewType, DataType, DataID>) -> Void)?) -> _BaseEpoxyModelBuilder {
    guard let newDidChangeState = didChangeState else { return self }

    if let oldDidChangeState = self.didChangeState {
      self.didChangeState = { context in
        oldDidChangeState(context)
        newDidChangeState(context)
      }
    } else {
      self.didChangeState = newDidChangeState
    }

    return self
  }

  public func willDisplay(_ willDisplay: ((DataType, DataID) -> Void)?) -> _BaseEpoxyModelBuilder {
    guard let newWillDisplay = willDisplay else { return self }

    if let oldWillDisplay = self.willDisplay {
      self.willDisplay = { data, string in
        oldWillDisplay(data, string)
        newWillDisplay(data, string)
      }
    } else {
      self.willDisplay = newWillDisplay
    }

    return self
  }

  public func didEndDisplaying(_ didEndDisplaying: ((DataType, DataID) -> Void)?) -> _BaseEpoxyModelBuilder {
    guard let newDidEndDisplaying = didEndDisplaying else { return self }

    if let oldDidEndDisplaying = self.didEndDisplaying {
      self.didEndDisplaying = { data, string in
        oldDidEndDisplaying(data, string)
        newDidEndDisplaying(data, string)
      }
    } else {
      self.didEndDisplaying = newDidEndDisplaying
    }

    return self
  }

  public func userInfo(_ userInfo: [EpoxyUserInfoKey: Any]) -> _BaseEpoxyModelBuilder {
    self.userInfo = userInfo
    return self
  }

  public func setUserInfoValue(_ value: Any, for key: EpoxyUserInfoKey) -> _BaseEpoxyModelBuilder {
    userInfo[key] = value
    return self
  }

  // MARK: Private

  private var data: DataType
  private var dataID: DataID
  private var alternateStyleID: String? = nil
  private var makeView: () -> ViewType = { ViewType() }
  private var configureView: (EpoxyContext<ViewType, DataType, DataID>) -> Void = { _ in }
  private var didChangeState: ((EpoxyContext<ViewType, DataType, DataID>) -> Void)? = nil
  private var behaviorSetter: ((EpoxyContext<ViewType, DataType, DataID>) -> Void)? = nil
  private var didSelect: ((EpoxyContext<ViewType, DataType, DataID>) -> Void)? = nil
  private var willDisplay: ((DataType, DataID) -> Void)? = nil
  private var didEndDisplaying: ((DataType, DataID) -> Void)? = nil
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
