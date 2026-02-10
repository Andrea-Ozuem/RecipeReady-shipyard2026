//
//  MemoryDebugger.swift
//  RecipeReady
//
//  Utility for tracking and debugging memory usage.
//

import Foundation
import UIKit

final class MemoryDebugger {
    static let shared = MemoryDebugger()
    
    private var baselineMemory: Float = 0
    private var checkpointMemory: [String: Float] = [:]
    
    private init() {
        baselineMemory = currentMemoryUsage()
        print("🎯 MemoryDebugger initialized - Baseline: \(String(format: "%.2f", baselineMemory)) MB")
    }
    
    // MARK: - Memory Tracking
    
    /// Returns current memory usage in MB
    func currentMemoryUsage() -> Float {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard kerr == KERN_SUCCESS else {
            return 0
        }
        
        return Float(info.resident_size) / 1024.0 / 1024.0
    }
    
    /// Returns URLCache memory usage in MB
    func urlCacheMemoryUsage() -> Float {
        return Float(URLCache.shared.currentMemoryUsage) / 1024.0 / 1024.0
    }
    
    /// Returns URLCache disk usage in MB
    func urlCacheDiskUsage() -> Float {
        return Float(URLCache.shared.currentDiskUsage) / 1024.0 / 1024.0
    }
    
    // MARK: - Logging
    
    /// Log current memory state with a label
    func log(_ label: String) {
        let current = currentMemoryUsage()
        let delta = current - baselineMemory
        let urlCache = urlCacheMemoryUsage()
        
        print("📊 [\(label)]")
        print("   Memory: \(String(format: "%.2f", current)) MB (Δ \(String(format: "%+.2f", delta)) MB)")
        print("   URLCache: \(String(format: "%.2f", urlCache)) MB")
    }
    
    /// Log memory with detailed breakdown
    func logDetailed(_ label: String) {
        let current = currentMemoryUsage()
        let delta = current - baselineMemory
        let urlCacheMem = urlCacheMemoryUsage()
        let urlCacheDisk = urlCacheDiskUsage()
        
        print("📊 [\(label)] DETAILED")
        print("   ├─ Total Memory: \(String(format: "%.2f", current)) MB")
        print("   ├─ Delta from Baseline: \(String(format: "%+.2f", delta)) MB")
        print("   ├─ URLCache Memory: \(String(format: "%.2f", urlCacheMem)) MB")
        print("   └─ URLCache Disk: \(String(format: "%.2f", urlCacheDisk)) MB")
    }
    
    /// Set a checkpoint to measure delta from
    func checkpoint(_ name: String) {
        let current = currentMemoryUsage()
        checkpointMemory[name] = current
        print("🔖 Checkpoint [\(name)]: \(String(format: "%.2f", current)) MB")
    }
    
    /// Log delta from a checkpoint
    func logFromCheckpoint(_ checkpointName: String, label: String) {
        guard let checkpointMem = checkpointMemory[checkpointName] else {
            print("⚠️ Checkpoint '\(checkpointName)' not found")
            return
        }
        
        let current = currentMemoryUsage()
        let delta = current - checkpointMem
        let urlCache = urlCacheMemoryUsage()
        
        print("📊 [\(label)] from checkpoint '\(checkpointName)'")
        print("   Memory: \(String(format: "%.2f", current)) MB (Δ \(String(format: "%+.2f", delta)) MB)")
        print("   URLCache: \(String(format: "%.2f", urlCache)) MB")
    }
    
    /// Reset baseline to current memory
    func resetBaseline() {
        baselineMemory = currentMemoryUsage()
        print("🔄 Baseline reset to: \(String(format: "%.2f", baselineMemory)) MB")
    }
    
    /// Clear all checkpoints
    func clearCheckpoints() {
        checkpointMemory.removeAll()
        print("🗑️ All checkpoints cleared")
    }
    
    // MARK: - Cache Management
    
    /// Clear URLCache and log the result
    func clearURLCache() {
        let beforeMem = urlCacheMemoryUsage()
        let beforeDisk = urlCacheDiskUsage()
        
        URLCache.shared.removeAllCachedResponses()
        
        let afterMem = urlCacheMemoryUsage()
        let afterDisk = urlCacheDiskUsage()
        
        print("🧹 URLCache cleared:")
        print("   Memory: \(String(format: "%.2f", beforeMem)) MB → \(String(format: "%.2f", afterMem)) MB")
        print("   Disk: \(String(format: "%.2f", beforeDisk)) MB → \(String(format: "%.2f", afterDisk)) MB")
    }
    
    // MARK: - Summary
    
    /// Print a comprehensive memory summary
    func printSummary() {
        print("=" * 60)
        print("📊 MEMORY SUMMARY")
        print("=" * 60)
        logDetailed("Current State")
        print("=" * 60)
    }
}

// Helper for string repetition
private func *(lhs: String, rhs: Int) -> String {
    return String(repeating: lhs, count: rhs)
}

