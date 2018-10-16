import Foundation

// MARK: - EpoxyStringRepresentable

/// Protocol for a type that can be represented by a string value
public protocol EpoxyStringRepresentable {

  var epoxyStringValue: String { get }

  init?(epoxyStringValue: String)
}

public extension EpoxyStringRepresentable {
  public init?(optionalEpoxyStringValue: String?) {
    guard let someEpoxyStringValue = optionalEpoxyStringValue else { return nil }
    self.init(epoxyStringValue: someEpoxyStringValue)
  }
}

// MARK: - String

extension String: EpoxyStringRepresentable {

  public var epoxyStringValue: String {
    return self
  }

  public init?(epoxyStringValue: String) {
    self.init(epoxyStringValue)
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

// MARK: - Int

extension Int: EpoxyStringRepresentable {

  public var epoxyStringValue: String {
    return String(self)
  }

  public init?(epoxyStringValue: String) {
    self.init(epoxyStringValue)
  }
}
