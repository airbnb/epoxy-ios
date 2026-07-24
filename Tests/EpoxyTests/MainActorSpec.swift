// Created by andrea_cipriani on 7/11/26.
// Copyright © 2026 Airbnb Inc. All rights reserved.

import Quick

// MARK: - MainActorSpec

/// Opt-in for `QuickSpec`s that exercise `@MainActor` types.
///
/// Quick's `spec()` stores its `beforeEach` / `it` / `afterEach` closures as nonisolated
/// `@escaping` closures and invokes them later, so a `@MainActor` annotation on the spec class or
/// on `spec()` doesn't reach them.
/// Conforming to `MainActorSpec` bridges through `MainActor.assumeIsolated`,
/// letting the spec call into `@MainActor` types directly without annotating every closure.
protocol MainActorSpec: QuickSpec { }

extension MainActorSpec {
  func beforeEach(_ closure: @escaping @MainActor () -> Void) {
    Quick.beforeEach { MainActor.assumeIsolated { closure() } }
  }

  func afterEach(_ closure: @escaping @MainActor () -> Void) {
    Quick.afterEach { MainActor.assumeIsolated { closure() } }
  }

  func it(
    _ description: String,
    file: FileString = #file,
    line: UInt = #line,
    closure: @escaping @MainActor () throws -> Void)
  {
    Quick.it(description, file: file, line: line) {
      try MainActor.assumeIsolated { try closure() }
    }
  }
}
