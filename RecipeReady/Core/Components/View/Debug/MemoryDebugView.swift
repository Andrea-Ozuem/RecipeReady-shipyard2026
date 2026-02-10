//
//  MemoryDebugView.swift
//  RecipeReady
//
//  Debug view for monitoring memory usage in real-time.
//

import SwiftUI

struct MemoryDebugView: View {
    @State private var currentMemory: Float = 0
    @State private var urlCacheMemory: Float = 0
    @State private var urlCacheDisk: Float = 0
    @State private var timer: Timer?
    
    var body: some View {
        NavigationStack {
            List {
                Section("Current Memory Usage") {
                    HStack {
                        Text("App Memory")
                        Spacer()
                        Text("\(String(format: "%.2f", currentMemory)) MB")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    
                    HStack {
                        Text("URLCache Memory")
                        Spacer()
                        Text("\(String(format: "%.2f", urlCacheMemory)) MB")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    
                    HStack {
                        Text("URLCache Disk")
                        Spacer()
                        Text("\(String(format: "%.2f", urlCacheDisk)) MB")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
                
                Section("URLCache Configuration") {
                    HStack {
                        Text("Memory Capacity")
                        Spacer()
                        Text("\(URLCache.shared.memoryCapacity / 1024 / 1024) MB")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Disk Capacity")
                        Spacer()
                        Text("\(URLCache.shared.diskCapacity / 1024 / 1024) MB")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Actions") {
                    Button("Clear URLCache") {
                        MemoryDebugger.shared.clearURLCache()
                        updateMemoryStats()
                    }
                    
                    Button("Reset Baseline") {
                        MemoryDebugger.shared.resetBaseline()
                        updateMemoryStats()
                    }
                    
                    Button("Print Summary to Console") {
                        MemoryDebugger.shared.printSummary()
                    }
                    
                    Button("Clear Checkpoints") {
                        MemoryDebugger.shared.clearCheckpoints()
                    }
                }
                
                Section("Instructions") {
                    Text("This view updates every second. Watch the memory values as you extract and save recipes to identify memory leaks.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Memory Debug")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                startMonitoring()
            }
            .onDisappear {
                stopMonitoring()
            }
        }
    }
    
    private func startMonitoring() {
        updateMemoryStats()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateMemoryStats()
        }
    }
    
    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateMemoryStats() {
        currentMemory = MemoryDebugger.shared.currentMemoryUsage()
        urlCacheMemory = MemoryDebugger.shared.urlCacheMemoryUsage()
        urlCacheDisk = MemoryDebugger.shared.urlCacheDiskUsage()
    }
}

#Preview {
    MemoryDebugView()
}

