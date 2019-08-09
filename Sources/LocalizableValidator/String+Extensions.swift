//
//  String+Extensions.swift
//  Basic
//
//  Created by Łukasz Kasperek on 09/08/2019.
//

import Foundation

extension String {
    var startToEndNSRange: NSRange {
        return NSRange(startIndex..<endIndex, in: self)
    }
    
    subscript(_ nsRange: NSRange) -> Substring {
        let range = Range<String.Index>(nsRange, in: self)!
        return self[range]
    }
}
