//
//  Array + Extensions.swift
//  Nakatani
//
//  Created by Илья Карась on 29.10.2020.
//  Copyright © 2020 Илья Карась. All rights reserved.
//

import Foundation

extension Collection where Element: BinaryInteger {
  
  func average(forLast last: Int = 20) -> Element? {
    if self.count < last {
      return nil
    }
    
    let subArray = self.suffix(last)
    let sum = subArray.reduce(0, +)
    let averageVal = sum / Element(last)
    return averageVal > 0 ? averageVal : nil
  }
}


//extension Collection where Element: BinaryInteger {
//
//  func sum(ofLast: Int = 0) -> Element {
//    if count < ofLast {
//      return .zero
//    }
//    return ofLast == 0 ? self.reduce(.zero, +) : self.suffix(ofLast).reduce(.zero, +)
//  }
//    /// Returns the average of all elements in the array
//  func average(ofLast: Int = 0) -> Element? { isEmpty ? nil : sum(ofLast: ofLast) / Element(ofLast == 0 ? count : ofLast) }
//    /// Returns the average of all elements in the array as Floating Point type
//  func average<T: FloatingPoint>(ofLast: Int = 0) -> T? { isEmpty ? nil : T(sum(ofLast: ofLast)) / T(ofLast == 0 ? count : ofLast) }
//}
