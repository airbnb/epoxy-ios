// Created by eric_horacek on 4/15/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - CoordinatedBarModel

/// A bar model with a custom content type and `Coordinator` that is responsible for providing the
/// `BarModel` that will be displayed to the user.
public struct CoordinatedBarModel {

  // MARK: Lifecycle

  public init<Coordinator: BarCoordinating, Content: Equatable, View: UIView>(
    dataID: AnyHashable? = nil,
    content: Content,
    viewType: View.Type,
    barModel: Coordinator.Model,
    makeCoordinator: @escaping (_ update: @escaping (_ animated: Bool) -> Void) -> Coordinator)
  {
    self.content = content
    viewClass = viewType

    typealias CoordinatorWrapper = AnyBarCoordinator<Coordinator.Model>

    _makeCoordinator = { CoordinatorWrapper(makeCoordinator($0)) }

    _barModel = { coordinator in
      guard let typedCoordinator = coordinator as? CoordinatorWrapper else {
        EpoxyLogger.shared.assertionFailure(
          "\(coordinator) is not of the expected type \(CoordinatorWrapper.self)")
        return nil
      }
      return typedCoordinator.barModel(for: barModel)
    }

    _canReuseCoordinator = { coordinator in
      guard let typedCoordinator = coordinator as? CoordinatorWrapper else {
        EpoxyLogger.shared.assertionFailure(
          "\(coordinator) is not of the expected type \(CoordinatorWrapper.self)")
        return false
      }
      return typedCoordinator.type == Coordinator.self
    }

    _isDiffableItemEqual = { other in
      guard let other = other as? CoordinatedBarModel else { return false }
      guard let otherContent = other.content as? Content else { return false }
      return otherContent == content
    }

    if let dataID = dataID {
      self.dataID = dataID
    }
  }

  // MARK: Public

  public var storage = EpoxyModelStorage()

  // MARK: Private

  private let content: Any
  private let viewClass: AnyClass
  private let _isDiffableItemEqual: (Diffable) -> Bool
  private let _makeCoordinator: (_ update: @escaping (_ animated: Bool) -> Void) -> AnyBarCoordinating
  private let _canReuseCoordinator: (_ coordinator: AnyBarCoordinating) -> Bool
  private let _barModel: (_ coordinator: AnyBarCoordinating) -> BarModeling?

}

// MARK: DataIDProviding

extension CoordinatedBarModel: DataIDProviding { }

// MARK: StyleIDProviding

extension CoordinatedBarModel: StyleIDProviding { }

// MARK: BarModeling

extension CoordinatedBarModel: BarModeling {
  public func eraseToAnyBarModel() -> AnyBarModel { .init(self) }
}

// MARK: InternalBarCoordinating

extension CoordinatedBarModel: InternalBarCoordinating {
  public func makeCoordinator(update: @escaping (Bool) -> Void) -> AnyBarCoordinating {
    _makeCoordinator(update)
  }

  public func barModel(for coordinator: AnyBarCoordinating) -> BarModeling {
    _barModel(coordinator) ?? self
  }

  public func canReuseCoordinator(_ coordinator: AnyBarCoordinating) -> Bool {
    _canReuseCoordinator(coordinator)
  }
}

// MARK: Diffable

extension CoordinatedBarModel: Diffable {
  public var diffIdentifier: AnyHashable {
    DiffIdentifier(dataID: dataID, viewClass: .init(viewClass))
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    _isDiffableItemEqual(otherDiffableItem)
  }
}
