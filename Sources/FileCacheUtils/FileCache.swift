//
//  FileCache.swift
//  Todotify
//
//  Created by kalmahik on 18.06.2024.
//

import Foundation

public enum Format {
    case json
    case csv
}

public final class FileCache<T: JSONable & CSVable> {
    
    public init() {}

    public func saveToFile(elements: [T], fileName: String, format: Format = .json) throws {
        guard let filename = try? FileManager.getFileURL(name: fileName) else {
            throw FileManagerError.fileNotFound
        }
        let isFileExist = FileManager.isFileExist(name: fileName)
        if isFileExist {
            Logger.shared.warning("FILE EXIST, REWRITE")
        }
        switch format {
        case .json:
            let todosJSON = elements.map { $0.json }
            let isNotValidJson = !JSONSerialization.isValidJSONObject(todosJSON)
            if isNotValidJson {
                throw JSONError.notValidJSONObject
            }
            let data = try JSONSerialization.data(withJSONObject: todosJSON)
            try data.write(to: filename)
        case .csv:
            let CSVString = ([T.csvHeader] + elements.map { $0.csv }).joined(separator: "\n")
            try CSVString.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        }
    }

    public func readFromFile(fileName: String, format: Format = .json) throws -> [T] {
        let filename = try FileManager.getFileURL(name: fileName)
        let isFileExist = FileManager.isFileExist(name: fileName)
        if !isFileExist {
            throw FileManagerError.fileNotFound
        }
        // что-то мне кажется, что лучше это вынести из этого класса...
        switch format {
        case .json:
            let data = try Data(contentsOf: filename)
            let todosJson = try JSONSerialization.jsonObject(with: data) as? [JSONDictionary] ?? []
            let elements = todosJson.compactMap { T.parse(json: $0) }
            return elements
        case .csv:
            let data = try String(contentsOf: filename)
            var rows = data.components(separatedBy: "\n")
            rows.removeFirst()
            let elements = rows.compactMap { T.parse(csv: $0) }
            return elements
        }
    }
}
