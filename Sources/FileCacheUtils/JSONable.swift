//
//  JSONable.swift
//  Todotify
//
//  Created by kalmahik on 19.06.2024.
//

import Foundation

typealias JSONDictionary = [String: Any]

public enum JSONError: Error {
    case notValidJSONObject
    case notValidTodoItem
    case error(String)
}

public protocol JSONable {
    static func parse(json: Any) -> Self?
    var json: Any { get }
}
