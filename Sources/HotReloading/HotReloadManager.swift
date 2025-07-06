import Foundation
import Combine
import SwiftUI

/// Advanced hot reload manager with automatic file watching
@MainActor
final class HotReloadManager: ObservableObject {
    static let shared = HotReloadManager()
    
    @Published var reloadTrigger = UUID()
    @Published var isReloading = false
    
    private var isWatching = false
    private var isAutoWatching = false
    private var cancellables = Set<AnyCancellable>()
    private var fileWatcher: FileWatcher?
    private var autoWatcher: AutoFileWatcher?
    
    // Configuration
    private let watchPaths: [String]
    private let triggerFile: String
    private var lastReloadTime = Date()
    
    private init() {
        // Use iOS-compatible home directory method
        let homeDirectory: URL
        #if os(iOS) || os(watchOS) || os(tvOS)
        homeDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        #else
        homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        #endif
        
        // Primary trigger file
        self.triggerFile = homeDirectory
            .appendingPathComponent(".hotreload")
            .path
        
        // Paths to watch for automatic reloading
        self.watchPaths = [
            triggerFile,
            FileManager.default.currentDirectoryPath,
            NSTemporaryDirectory()
        ]
        
        setupTriggerFile()
        setupKeyboardShortcuts()
    }
    
    /// Start basic file watching (manual triggers only)
    func startWatching() {
        guard !isWatching else { return }
        
        #if DEBUG
        isWatching = true
        startTriggerFileWatcher()
        
        print("🔥 HotReloading: Manual trigger mode active")
        print("💡 Trigger with: touch ~/.hotreload or triple-tap your view")
        #endif
    }
    
    /// Start automatic file watching (watches source files)
    func startAutoWatching() {
        guard !isAutoWatching else { return }
        
        #if DEBUG
        isAutoWatching = true
        startWatching() // Also enable manual triggers
        
        // Start automatic source file watching (macOS only)
        #if os(macOS)
        startSourceFileWatcher()
        print("🔥 HotReloading: Auto-watch mode active")
        print("💡 Changes will be detected automatically!")
        #else
        print("🔥 HotReloading: Auto-watch not available on iOS")
        print("💡 Use manual triggers instead")
        #endif
        
        print("💡 Manual trigger: touch ~/.hotreload")
        #endif
    }
    
    /// Stop all watching
    func stopWatching() {
        guard isWatching || isAutoWatching else { return }
        
        isWatching = false
        isAutoWatching = false
        cancellables.removeAll()
        fileWatcher?.stop()
        fileWatcher = nil
        autoWatcher?.stop()
        autoWatcher = nil
        
        print("🔥 HotReloading: Stopped watching")
    }
    
    /// Manually trigger a reload with visual feedback
    func triggerReload() {
        // Debounce rapid triggers
        let now = Date()
        guard now.timeIntervalSince(lastReloadTime) > 0.5 else { return }
        lastReloadTime = now
        
        Task { @MainActor in
            // Show loading indicator
            withAnimation(.easeInOut(duration: 0.2)) {
                self.isReloading = true
            }
            
            // Small delay for visual feedback
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            // Trigger the actual reload
            self.reloadTrigger = UUID()
            
            // Hide loading indicator
            withAnimation(.easeInOut(duration: 0.2)) {
                self.isReloading = false
            }
            
            // Format time for older iOS versions
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            let timeString = formatter.string(from: now)
            
            print("🔥 HotReloading: View refreshed at \(timeString)")
        }
    }
    
    // MARK: - Private Methods
    
    private func setupTriggerFile() {
        // Create the trigger file if it doesn't exist
        if !FileManager.default.fileExists(atPath: triggerFile) {
            let content = """
            # HotReloading Trigger File
            # Touch this file to trigger hot reloads
            # Created: \(Date())
            """.data(using: .utf8)
            
            FileManager.default.createFile(
                atPath: triggerFile,
                contents: content,
                attributes: nil
            )
        }
    }
    
    private func setupKeyboardShortcuts() {
        #if os(macOS)
        // Listen for Command+R when app is in focus
        NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                // Setup global hotkey listener here if needed
                self?.setupGlobalHotkeys()
            }
            .store(in: &cancellables)
        #endif
    }
    
    private func setupGlobalHotkeys() {
        // This would require additional permissions and setup
        // For now, we'll use the file-based approach
    }
    
    private func startTriggerFileWatcher() {
        // High-frequency polling for the trigger file
        Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.checkTriggerFile()
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkTriggerFile() {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: triggerFile),
              let modificationDate = attributes[.modificationDate] as? Date else {
            return
        }
        
        // Check if file was modified in the last 1 second
        if Date().timeIntervalSince(modificationDate) < 1.0 {
            triggerReload()
        }
    }
    
    private func startSourceFileWatcher() {
        // Watch for Swift file changes in the project (macOS only)
        #if os(macOS)
        let projectPath = findProjectPath()
        
        autoWatcher = AutoFileWatcher(projectPath: projectPath) { [weak self] in
            Task { @MainActor in
                self?.triggerReload()
            }
        }
        autoWatcher?.start()
        #endif
    }
    
    private func findProjectPath() -> String {
        // Try to find the Xcode project root
        var currentPath = FileManager.default.currentDirectoryPath
        
        // Look for .xcodeproj or Package.swift
        while currentPath != "/" {
            let contents = try? FileManager.default.contentsOfDirectory(atPath: currentPath)
            if contents?.contains(where: { $0.hasSuffix(".xcodeproj") || $0 == "Package.swift" }) == true {
                return currentPath
            }
            currentPath = (currentPath as NSString).deletingLastPathComponent
        }
        
        return FileManager.default.currentDirectoryPath
    }
}

// MARK: - File Watching Protocols

protocol FileWatcher {
    func start()
    func stop()
}

// MARK: - Auto File Watcher (macOS only)

#if os(macOS)
import CoreServices

class AutoFileWatcher: FileWatcher {
    private let projectPath: String
    private let callback: () -> Void
    private var eventStream: FSEventStreamRef?
    private var lastTriggerTime = Date()
    
    init(projectPath: String, callback: @escaping () -> Void) {
        self.projectPath = projectPath
        self.callback = callback
    }
    
    func start() {
        let pathsToWatch = [projectPath] as CFArray
        
        var streamContext = FSEventStreamContext()
        streamContext.version = 0
        streamContext.info = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        streamContext.retain = nil
        streamContext.release = nil
        streamContext.copyDescription = nil
        
        let callback: FSEventStreamCallback = { streamRef, clientCallBackInfo, numEvents, eventPaths, eventFlags, eventIds in
            guard let info = clientCallBackInfo else { return }
            let watcher = Unmanaged<AutoFileWatcher>.fromOpaque(info).takeUnretainedValue()
            
            // Convert eventPaths to proper type
            let paths = UnsafeBufferPointer(start: eventPaths.assumingMemoryBound(to: UnsafeMutablePointer<CChar>?.self), count: numEvents)
            let flags = UnsafeBufferPointer(start: eventFlags, count: numEvents)
            
            watcher.handleFileEvent(paths: Array(paths), flags: Array(flags))
        }
        
        eventStream = FSEventStreamCreate(
            kCFAllocatorDefault,
            callback,
            &streamContext,
            pathsToWatch,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0.3, // latency
            FSEventStreamCreateFlags(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)
        )
        
        if let stream = eventStream {
            FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
            FSEventStreamStart(stream)
            print("🔥 Auto-watching Swift files in: \(projectPath)")
        }
    }
    
    private func handleFileEvent(paths: [UnsafeMutablePointer<CChar>?], flags: [FSEventStreamEventFlags]) {
        let now = Date()
        
        // Debounce events
        guard now.timeIntervalSince(lastTriggerTime) > 1.0 else { return }
        
        for pathPtr in paths {
            if let pathPtr = pathPtr {
                let path = String(cString: pathPtr)
                
                // Only trigger for Swift files
                if path.hasSuffix(".swift") && !path.contains(".build") && !path.contains("DerivedData") {
                    lastTriggerTime = now
                    print("🔥 Detected change in: \(path)")
                    callback()
                    break
                }
            }
        }
    }
    
    func stop() {
        if let stream = eventStream {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
            eventStream = nil
        }
    }
    
    deinit {
        stop()
    }
}

class FSEventWatcher: FileWatcher {
    private let paths: [String]
    private let callback: () -> Void
    private var eventStream: FSEventStreamRef?
    private var context: FSEventStreamContext?
    
    init(paths: [String], callback: @escaping () -> Void) {
        self.paths = paths
        self.callback = callback
    }
    
    func start() {
        let pathsToWatch = paths as CFArray
        
        var streamContext = FSEventStreamContext()
        streamContext.version = 0
        streamContext.info = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        streamContext.retain = nil
        streamContext.release = nil
        streamContext.copyDescription = nil
        
        self.context = streamContext
        
        let callback: FSEventStreamCallback = { streamRef, clientCallBackInfo, numEvents, eventPaths, eventFlags, eventIds in
            guard let info = clientCallBackInfo else { return }
            let watcher = Unmanaged<FSEventWatcher>.fromOpaque(info).takeUnretainedValue()
            watcher.callback()
        }
        
        eventStream = FSEventStreamCreate(
            kCFAllocatorDefault,
            callback,
            &streamContext,
            pathsToWatch,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0.5,
            FSEventStreamCreateFlags(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)
        )
        
        if let stream = eventStream {
            FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
            FSEventStreamStart(stream)
        }
    }
    
    func stop() {
        if let stream = eventStream {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
            eventStream = nil
        }
        context = nil
    }
    
    deinit {
        stop()
    }
}

#else

// Stub implementations for non-macOS platforms
class AutoFileWatcher: FileWatcher {
    init(projectPath: String, callback: @escaping () -> Void) {
        // No-op on iOS
    }
    
    func start() {
        // No-op on iOS
    }
    
    func stop() {
        // No-op on iOS
    }
}

#endif
