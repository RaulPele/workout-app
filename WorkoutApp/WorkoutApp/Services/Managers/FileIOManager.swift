//
//  FileIOManager.swift
//  WorkoutApp
//
//  Created by Raul Pele on 19.05.2023.
//

import Foundation

enum Directory: String {
    case workoutSessions = "WorkoutSessions"
    case workoutTemplates = "WorkoutTemplates"
}


typealias CodableEntity = Identifiable & Codable

struct FileIOManager {
    
    private static func ensureDirectoryExists(at url: URL) throws {
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: url.path()) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
            print("Created directory at path: \(url.path())")
        } else {
            print("Directory \(url.path()) already exists.")
        }
        
    }
    
    static func write<T: CodableEntity>(
        entity: T,
        toDirectory directory: Directory,
        encoder: JSONEncoder = .init()
    ) throws {
        guard let appDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let entityDirectoryURL = appDirectoryURL.appendingPathComponent(directory.rawValue, conformingTo: .directory)
        try ensureDirectoryExists(at: entityDirectoryURL)
        
        let fileName = "\(entity.id).json"
        let fileURL = entityDirectoryURL.appendingPathComponent(fileName, conformingTo: .fileURL)
        print("File URL: \(fileURL.absoluteString)")
        
        let jsonData = try encoder.encode(entity)
        try jsonData.write(to: fileURL)
    }
    
    static func readAll<T: CodableEntity>(from directory: Directory) throws -> [T] {
        guard let appDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return [T]()}
        
        let entityDirectoryURL = appDirectoryURL.appendingPathComponent(directory.rawValue, conformingTo: .directory)
        
        let fileURLs = try FileManager.default.contentsOfDirectory(at: entityDirectoryURL, includingPropertiesForKeys: nil)
        print("FILEURLS: \(fileURLs)")
        let decoder = JSONDecoder()
        
        let entities = try fileURLs.compactMap {
            print("FILE URL FROM DIRECTORY: \($0)")
            let data = try Data(contentsOf: $0)
            return try? decoder.decode(T.self, from: data)
        }
        
        return entities
    }
    
    static func read<T: CodableEntity>(forId id: T.ID, fromDirectory directory: Directory) throws -> T? {
        guard let appDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil}
        let entityDirectory = appDirectoryURL.appendingPathComponent(directory.rawValue, conformingTo: .directory)
        
        //TEST
        let fileURLs = try FileManager.default.contentsOfDirectory(at: entityDirectory, includingPropertiesForKeys: nil)
        print("FILEURLS: \(fileURLs)")
        
        let fileURL = entityDirectory.appendingPathComponent("\(id).json", conformingTo: .fileURL)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: Data(contentsOf: fileURL))
    }
}
