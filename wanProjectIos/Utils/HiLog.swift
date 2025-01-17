//
//  HiLog.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

class HiLog {
    enum Level: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        
        var emoji: String {
            switch self {
            case .debug: return "🔍"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            }
        }
    }
    
    static var isDebugMode = true
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    private static func log(_ level: Level, _ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        guard isDebugMode else { return }
        
        let timestamp = dateFormatter.string(from: Date())
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(level.emoji) [\(level.rawValue)] [\(timestamp)] [\(fileName):\(line)] \(function): \(message)"
        
        print(logMessage)
        
        // 可以在这里添加日志写入文件的逻辑
        saveToFile(logMessage)
    }
    
    private static func saveToFile(_ message: String) {
        // 获取日志文件路径
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let logFileURL = documentsDirectory.appendingPathComponent("app.log")
        
        // 将日志写入文件
        if let data = (message + "\n").data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logFileURL.path) {
                if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            } else {
                try? data.write(to: logFileURL, options: .atomicWrite)
            }
        }
    }
    
    // 公开的日志方法
    static func d(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(.debug, message, file: file, function: function, line: line)
    }
    
    static func i(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(.info, message, file: file, function: function, line: line)
    }
    
    static func w(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(.warning, message, file: file, function: function, line: line)
    }
    
    static func e(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, message, file: file, function: function, line: line)
    }
} 