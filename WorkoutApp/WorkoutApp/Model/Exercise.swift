//
//  Exercise.swift
//  WorkoutApp
//
//  Created by Raul Pele on 13.05.2023.
//

import Foundation

struct Exercise: Identifiable, Codable, Hashable {

    let id: UUID
    let definition: ExerciseDefinition
    let numberOfSets: Int
    let setData: ExerciseSet
    let restBetweenSets: TimeInterval

    // MARK: - Convenience Accessors
    var name: String { definition.name }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, definition, name, numberOfSets, setData, restBetweenSets
    }

    init(id: UUID, definition: ExerciseDefinition, numberOfSets: Int, setData: ExerciseSet, restBetweenSets: TimeInterval) {
        self.id = id
        self.definition = definition
        self.numberOfSets = numberOfSets
        self.setData = setData
        self.restBetweenSets = restBetweenSets
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)

        if let definition = try? container.decode(ExerciseDefinition.self, forKey: .definition) {
            self.definition = definition
        } else {
            // Legacy migration: old Exercise had a flat "name" field
            let legacyName = try container.decode(String.self, forKey: .name)
            self.definition = ExerciseDefinition.legacy(name: legacyName)
        }

        numberOfSets = try container.decode(Int.self, forKey: .numberOfSets)
        setData = try container.decode(ExerciseSet.self, forKey: .setData)
        restBetweenSets = try container.decode(TimeInterval.self, forKey: .restBetweenSets)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(definition, forKey: .definition)
        try container.encode(numberOfSets, forKey: .numberOfSets)
        try container.encode(setData, forKey: .setData)
        try container.encode(restBetweenSets, forKey: .restBetweenSets)
    }
}

// MARK: - Mocked Data
extension Exercise {
    static let mockedBBBenchPress = Exercise(
        id: .init(),
        definition: .mockedBBBenchPress,
        numberOfSets: 3,
        setData: .mockedBBBenchPress,
        restBetweenSets: 150
    )

    static let mockedBBSquats = Exercise(
        id: .init(),
        definition: .mockedBBSquats,
        numberOfSets: 4,
        setData: .mockedBBSquats,
        restBetweenSets: 150
    )
}
