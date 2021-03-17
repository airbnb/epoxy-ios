// Created by eric_horacek on 3/15/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

#if swift(>=5.4)
/// A result builder that enables a DSL for building an optional presentation model.
///
/// For example:
/// ```
/// @PresentationModelBuilder var presentation: PresentationModel? {
///    if showA {
///      PresentationModel(…)
///    }
///    if showB {
///      PresentationModel(…)
///    }
/// }
/// ```
///
/// Will return a `nil` presentation model if `showA` and `showB` are false, else will return the
/// first non-`nil` presentation model.
@resultBuilder
public struct PresentationModelBuilder {
  public typealias Expression = PresentationModel
  public typealias Component = PresentationModel?

  public static func buildExpression(_ expression: Expression) -> Component {
    expression
  }

  public static func buildExpression(_ expression: Component) -> Component {
    expression
  }

  public static func buildBlock(_ children: Component...) -> Component {
    for child in children {
      if let child = child {
        return child
      }
    }
    return nil
  }

  public static func buildBlock(_ component: Component) -> Component {
    component
  }

  public static func buildOptional(_ children: Component?) -> Component {
    if let child = children {
      return child
    }
    return nil
  }

  public static func buildEither(first child: Component) -> Component {
    child
  }

  public static func buildEither(second child: Component) -> Component {
    child
  }

  public static func buildArray(_ components: [Component]) -> Component {
    for child in components {
      if let child = child {
        return child
      }
    }
    return nil
  }
}
#else
/// A result builder that enables a DSL for building an optional presentation model.
///
/// For example:
/// ```
/// @PresentationModelBuilder var presentation: PresentationModel? {
///    if showA {
///      PresentationModel(…)
///    }
///    if showB {
///      PresentationModel(…)
///    }
/// }
/// ```
///
/// Will return a `nil` presentation model if `showA` and `showB` are false, else will return the
/// first non-`nil` presentation model.
@_functionBuilder
public struct PresentationModelBuilder {
  public typealias Expression = PresentationModel
  public typealias Component = PresentationModel?

  public static func buildExpression(_ expression: Expression) -> Component {
    expression
  }

  public static func buildExpression(_ expression: Component) -> Component {
    expression
  }

  public static func buildBlock(_ children: Component...) -> Component {
    for child in children {
      if let child = child {
        return child
      }
    }
    return nil
  }

  public static func buildBlock(_ component: Component) -> Component {
    component
  }

  public static func buildOptional(_ children: Component?) -> Component {
    if let child = children {
      return child
    }
    return nil
  }

  public static func buildEither(first child: Component) -> Component {
    child
  }

  public static func buildEither(second child: Component) -> Component {
    child
  }

  public static func buildArray(_ components: [Component]) -> Component {
    for child in components {
      if let child = child {
        return child
      }
    }
    return nil
  }
}
#endif
