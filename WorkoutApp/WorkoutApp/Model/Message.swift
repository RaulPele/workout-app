//
//  WatchMessage.swift
//  WorkoutApp
//
//  Created by Raul Pele on 24.05.2023.
//

import Foundation

enum WatchMessageError: Error {
    case invalidMessageType
    case decodingFailed(Error)
    case encodingFailed(Error)
}

enum WatchMessage {

    case requestTemplates
    case workoutTemplates([Workout])
    case workoutSession(WorkoutSession)

    // MARK: - Keys

    private enum Keys {
        static let messageType = "messageType"
        static let payload = "payload"
    }

    private enum MessageType: String {
        case requestTemplates
        case workoutTemplates
        case workoutSession
    }

    // MARK: - Data Conversion (for sendMessageData)

    func toData() throws -> Data {
        let encoder = JSONEncoder()
        let envelope = Envelope(messageType: messageType, payload: payloadData(encoder: encoder))
        return try encoder.encode(envelope)
    }

    static func fromData(_ data: Data) throws -> WatchMessage {
        let decoder = JSONDecoder()
        let envelope: Envelope
        do {
            envelope = try decoder.decode(Envelope.self, from: data)
        } catch {
            throw WatchMessageError.decodingFailed(error)
        }

        guard let type = MessageType(rawValue: envelope.messageType) else {
            throw WatchMessageError.invalidMessageType
        }

        switch type {
        case .requestTemplates:
            return .requestTemplates
        case .workoutTemplates:
            guard let payload = envelope.payload else { throw WatchMessageError.invalidMessageType }
            let workouts = try decoder.decode([Workout].self, from: payload)
            return .workoutTemplates(workouts)
        case .workoutSession:
            guard let payload = envelope.payload else { throw WatchMessageError.invalidMessageType }
            let session = try decoder.decode(WorkoutSession.self, from: payload)
            return .workoutSession(session)
        }
    }

    // MARK: - Dictionary Conversion (for transferUserInfo / updateApplicationContext)

    func toDictionary() throws -> [String: Any] {
        let encoder = JSONEncoder()

        switch self {
        case .requestTemplates:
            return [Keys.messageType: MessageType.requestTemplates.rawValue]

        case .workoutTemplates(let workouts):
            let data = try encoder.encode(workouts)
            return [
                Keys.messageType: MessageType.workoutTemplates.rawValue,
                Keys.payload: data
            ]

        case .workoutSession(let session):
            let data = try encoder.encode(session)
            return [
                Keys.messageType: MessageType.workoutSession.rawValue,
                Keys.payload: data
            ]
        }
    }

    static func fromDictionary(_ dictionary: [String: Any]) throws -> WatchMessage {
        guard let typeString = dictionary[Keys.messageType] as? String,
              let type = MessageType(rawValue: typeString)
        else {
            throw WatchMessageError.invalidMessageType
        }

        let decoder = JSONDecoder()

        switch type {
        case .requestTemplates:
            return .requestTemplates

        case .workoutTemplates:
            guard let data = dictionary[Keys.payload] as? Data else {
                throw WatchMessageError.invalidMessageType
            }
            do {
                let workouts = try decoder.decode([Workout].self, from: data)
                return .workoutTemplates(workouts)
            } catch {
                throw WatchMessageError.decodingFailed(error)
            }

        case .workoutSession:
            guard let data = dictionary[Keys.payload] as? Data else {
                throw WatchMessageError.invalidMessageType
            }
            do {
                let session = try decoder.decode(WorkoutSession.self, from: data)
                return .workoutSession(session)
            } catch {
                throw WatchMessageError.decodingFailed(error)
            }
        }
    }

    // MARK: - Private Helpers

    private var messageType: String {
        switch self {
        case .requestTemplates: MessageType.requestTemplates.rawValue
        case .workoutTemplates: MessageType.workoutTemplates.rawValue
        case .workoutSession: MessageType.workoutSession.rawValue
        }
    }

    private func payloadData(encoder: JSONEncoder) -> Data? {
        switch self {
        case .requestTemplates:
            return nil
        case .workoutTemplates(let workouts):
            return try? encoder.encode(workouts)
        case .workoutSession(let session):
            return try? encoder.encode(session)
        }
    }

    private struct Envelope: Codable {
        let messageType: String
        let payload: Data?
    }
}
