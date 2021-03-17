// Created by eric_horacek on 3/15/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

#if swift(>=5.4)
/// A generic result builder that enables a DSL for building arrays of Epoxy models.
@resultBuilder
public struct EpoxyModelArrayBuilder<Model> {
  public typealias Expression = Model
  public typealias Component = [Model]

  public static func buildExpression(_ expression: Expression) -> Component {
    [expression]
  }

  public static func buildExpression(_ expression: Component) -> Component {
    expression
  }

  public static func buildExpression(_ expression: Expression?) -> Component {
    if let expression = expression {
      return [expression]
    }
    return []
  }

  public static func buildBlock(_ children: Component...) -> Component {
    children.flatMap { $0 }
  }

  public static func buildBlock(_ component: Component) -> Component {
    component
  }

  public static func buildOptional(_ children: Component?) -> Component {
    children ?? []
  }

  public static func buildEither(first child: Component) -> Component {
    child
  }

  public static func buildEither(second child: Component) -> Component {
    child
  }

  public static func buildArray(_ components: [Component]) -> Component {
    components.flatMap { $0 }
  }
}
#else
/// A generic result builder that enables a DSL for building arrays of Epoxy models.
@_functionBuilder
public struct EpoxyModelArrayBuilder<Model> {
  public typealias Expression = Model
  public typealias Component = [Model]

  public static func buildExpression(_ expression: Expression) -> Component {
    [expression]
  }

  public static func buildExpression(_ expression: Component) -> Component {
    expression
  }

  public static func buildExpression(_ expression: Expression?) -> Component {
    if let expression = expression {
      return [expression]
    }
    return []
  }

  public static func buildBlock(_ children: Component...) -> Component {
    children.flatMap { $0 }
  }

  public static func buildBlock(_ component: Component) -> Component {
    component
  }

  public static func buildOptional(_ children: Component?) -> Component {
    children ?? []
  }

  public static func buildEither(first child: Component) -> Component {
    child
  }

  public static func buildEither(second child: Component) -> Component {
    child
  }

  public static func buildArray(_ components: [Component]) -> Component {
    components.flatMap { $0 }
  }
}
#endif
