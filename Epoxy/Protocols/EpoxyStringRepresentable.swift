import Foundation

// MARK: - EpoxyStringRepresentable

/// Protocol for a type that can be represented by a string value
public protocol EpoxyStringRepresentable {

  var epoxyStringValue: String { get }

  init?(epoxyStringValue: String)
}

public extension EpoxyStringRepresentable {
  init?(optionalEpoxyStringValue: String?) {
    guard let someEpoxyStringValue = optionalEpoxyStringValue else { return nil }
    self.init(epoxyStringValue: someEpoxyStringValue)
  }
}

// MARK: - RawRepresentable

extension RawRepresentable where RawValue == String {

  public var epoxyStringValue: String {
    return rawValue
  }

  public init?(epoxyStringValue: String) {
    self.init(rawValue: epoxyStringValue)
  }
}
