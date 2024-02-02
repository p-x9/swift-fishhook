//
//  Rebinding.swift
//  
//
//  Created by p-x9 on 2024/02/03.
//  
//

import Foundation

public class Rebinding {
    public let name: String
    public let replacement: UnsafeMutableRawPointer
    public let replaced: UnsafeMutablePointer<UnsafeMutableRawPointer?>?

    public init(
        name: String,
        replacement: UnsafeMutableRawPointer,
        replaced: UnsafeMutablePointer<UnsafeMutableRawPointer?>?
    ) {
        self.name = name
        self.replacement = replacement
        self.replaced = replaced
    }
}
