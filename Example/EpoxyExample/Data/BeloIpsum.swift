//  Created by dc on 5/1/18.
//  Copyright © 2018 Airbnb. All rights reserved.

// MARK: - BeloIpsum

enum BeloIpsum {

  // MARK: Internal

  /// Generate Belo Ipsum sentences.
  static func sentence(
    count: Int,
    wordCount: Int = 5,
    seed: Int = 0)
    -> String
  {
    var sentences: [String] = []
    if count > 0 {
      let range = 1...count
      var generator = SeededRandomNumberGenerator(seed: UInt64(seed))
      var startingAt = Int.random(in: propertyTypes.indices, using: &generator)
      sentences = range.map { _ -> String in
        let response = makeSentence(wordCount: wordCount, startingAt: startingAt)
        let sentence = response.0
        startingAt = response.1
        return sentence
      }
    }

    return sentences.joined(separator: " ")
  }

  /// Generate Belo Ipsum paragraphs
  static func paragraph(
    count: Int,
    sentencesPerParagraph: Int = 5,
    seed: Int = 0)
    -> String
  {
    let range = 0..<count

    let paragraphs = range.map { index -> String in
      sentence(count: sentencesPerParagraph, seed: seed + index)
    }

    return paragraphs.joined(separator: "\n\n")
  }

  // MARK: Private

  private static let propertyTypes = [
    "Hostel",
    "Plane",
    "Minsu",
    "Treehouse",
    "Bungalow",
    "Yurt",
    "Boutique hotel",
    "Guesthouse",
    "Campsite",
    "Windmill",
    "Pension",
    "Lighthouse",
    "Tent",
    "Guest suite",
    "Loft",
    "Dome house",
    "Tiny house",
    "Dammuso",
    "Villa",
    "Castle",
    "Island",
    "Casa particular",
    "Recreational vehicle",
    "Camper",
    "Cabin",
    "Bed and breakfast",
    "Hut",
    "Trullo",
    "Barn",
    "Nature lodge",
    "Train",
    "Tipi",
    "Igloo",
    "Cottage",
    "Farm stay",
    "Cycladic house",
    "Boat",
    "Resort",
    "Ryokan",
    "Houseboat",
    "Earth house",
    "Cave",
    "Townhouse",
    "Chalet",
    "Hotel",
    "Shepherd’s hut",
  ]

  private static func makeSentence(wordCount: Int, startingAt: Int) -> (String, Int) {
    var words: [String] = []
    let range = 0..<Int(wordCount)
    var i = startingAt

    range.forEach { _ in
      let availableSpace = Int(wordCount) - words.count
      if availableSpace == 0 { return }

      i += 1
      if i > propertyTypes.count - 1 {
        i = 0
      }

      // Some "words" have multiple words. Make sure the
      // cost of the word doesn't overflow the requested count
      var word = propertyTypes[i]
      var cost = word.split(separator: " ").count
      while cost > availableSpace {
        let index = i + 1
        if index >= 0 && index < propertyTypes.count {
          let value = propertyTypes[index]
          word = value
          cost = value.split(separator: " ").count
          i += 1
        } else {
          i = 0
        }
      }

      words.append(contentsOf: word.split(separator: " ").map { String($0) })
    }

    let sentence = words.joined(separator: " ") + "."
    return (sentence.sentencecase(), i)
  }

}

extension String {
  fileprivate func sentencecase() -> String {
    prefix(1).uppercased() + lowercased().dropFirst()
  }
}

import class GameplayKit.GKMersenneTwisterRandomSource

// MARK: - SeededRandomNumberGenerator

// Adapted from https://stackoverflow.com/a/57370987/4076325
private struct SeededRandomNumberGenerator: RandomNumberGenerator {

  init(seed: UInt64) {
    generator = GKMersenneTwisterRandomSource(seed: seed)
  }

  mutating func next() -> UInt64 {
    // GKRandom produces values in [INT32_MIN, INT32_MAX] range; hence we need two numbers to
    // produce 64-bit value.
    let next1 = UInt64(bitPattern: Int64(generator.nextInt()))
    let next2 = UInt64(bitPattern: Int64(generator.nextInt()))
    return next1 ^ (next2 << 32)
  }

  private let generator: GKMersenneTwisterRandomSource

}
