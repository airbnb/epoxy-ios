//  Created by Laura Skelton on 7/11/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation

/// Protocol for a type that can return a string for use in Epoxy
public protocol ConvertibleToStringID {

  var stringID: String { get }
  
}

/// Protocol for a type that can be converted to or from a string identifier for use in Epoxy
public protocol StringIDConvertible: ConvertibleToStringID {

  static func make(stringID: String?) -> Self?
}

extension String: StringIDConvertible {
  public var stringID: String {
    return self
  }

  public static func make(stringID: String?) -> String? {
    return stringID
  }
}

extension RawRepresentable
  where RawValue == String
{
  public var stringID: String {
    return rawValue
  }

  public static func make(stringID: String?) -> Self? {
    guard let stringID = stringID else { return nil }
    return Self.init(rawValue: stringID)
  }
}

extension Int: StringIDConvertible {
  public var stringID: String {
    return String(self)
  }

  public static func make(stringID: String?) -> Int? {
    guard let stringID = stringID else { return nil }
    return Int(stringID)
  }
}
