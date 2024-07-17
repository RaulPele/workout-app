//
//  CustomLogger.swift
//  WorkoutApp
//
//  Created by Raul Pele on 17.07.2024.
//

import Foundation
import OSLog

struct CustomLogger {
    
    //MARK: - Shared Properties
    static var loggingDisabled = false
    
    //MARK: - Properties
    let subsystem: String
    let category: String
    
    private var logger: Logger
    
    //MARK: - Initializers
    init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
        
        logger = Logger(subsystem: subsystem, category: category)
    }
    
    //MARK: - Public Methods
    func log(level: LogType, message: String) {
        if !CustomLogger.loggingDisabled {
            logger.log(level: level.osLogType, "\(message)")
        }
    }
    
    func debug(_ message: String) {
        if !CustomLogger.loggingDisabled {
            logger.debug("\(message)")
        }
    }
    
    func info(_ message: String) {
        if !CustomLogger.loggingDisabled {
            logger.info("\(message)")
        }
    }
    
    func error(_ message: String) {
        if !CustomLogger.loggingDisabled {
            logger.error("\(message)")
        }
    }
    
    func fault(_ message: String) {
        if !CustomLogger.loggingDisabled {
            logger.fault("\(message)")
        }
    }
    
    //MARK: - LogType
    enum LogType {
        
        case debug
        case info
        case error
        case fault
        
        var osLogType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .info:
                return .info
            case .error:
                return .error
            case .fault:
                return .fault
            }
        }
    }
}
