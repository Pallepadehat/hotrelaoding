import Foundation

/// Utility functions for triggering hot reloads programmatically
public enum HotReloadTrigger {
    
    /// Trigger a hot reload by touching the trigger file
    public static func trigger() {
        #if DEBUG
        // Use iOS-compatible home directory method
        let homeDirectory: URL
        #if os(iOS) || os(watchOS) || os(tvOS)
        homeDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        #else
        homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        #endif
        
        let triggerFile = homeDirectory.appendingPathComponent(".hotreload")
        
        // Update the modification date
        let now = Date()
        try? FileManager.default.setAttributes(
            [.modificationDate: now],
            ofItemAtPath: triggerFile.path
        )
        
        // Format time for older iOS versions
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        let timeString = formatter.string(from: now)
        
        print("🔥 HotReload triggered manually at \(timeString)")
        #endif
    }
    
    /// Create a shell script for easy command-line triggering (macOS only)
    public static func createShellScript(at path: String? = nil) {
        #if DEBUG && os(macOS)
        let scriptContent = """
        #!/bin/bash
        # HotReloading Trigger Script
        # Usage: ./hotreload.sh
        
        echo "🔥 Triggering hot reload..."
        touch ~/.hotreload
        echo "✅ Hot reload triggered at $(date)"
        """
        
        let scriptPath = path ?? (FileManager.default.currentDirectoryPath + "/hotreload.sh")
        
        do {
            try scriptContent.write(toFile: scriptPath, atomically: true, encoding: .utf8)
            
            // Make it executable
            let attributes = [FileAttributeKey.posixPermissions: 0o755]
            try FileManager.default.setAttributes(attributes, ofItemAtPath: scriptPath)
            
            print("📝 Created hotreload.sh script at: \(scriptPath)")
            print("💡 Run with: ./hotreload.sh")
        } catch {
            print("❌ Failed to create script: \(error)")
        }
        #else
        print("💡 Shell scripts are only available on macOS")
        #endif
    }
    
    /// Create a file watcher script that automatically triggers reloads (macOS only)
    public static func createAutoWatchScript() {
        #if DEBUG && os(macOS)
        let scriptContent = """
        #!/bin/bash
        # Auto HotReloading Script
        # Watches Swift files and triggers reloads automatically
        
        echo "🔥 Starting auto hot reload watcher..."
        echo "💡 Watching for .swift file changes..."
        echo "💡 Press Ctrl+C to stop"
        
        # Check if fswatch is installed
        if ! command -v fswatch &> /dev/null; then
            echo "❌ fswatch not found. Install with: brew install fswatch"
            exit 1
        fi
        
        # Find project root (look for .xcodeproj or Package.swift)
        PROJECT_ROOT="."
        while [[ "$PROJECT_ROOT" != "/" ]]; do
            if ls "$PROJECT_ROOT"/*.xcodeproj &> /dev/null || [[ -f "$PROJECT_ROOT/Package.swift" ]]; then
                break
            fi
            PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
        done
        
        echo "📁 Watching project at: $PROJECT_ROOT"
        
        # Watch for Swift file changes
        fswatch -e ".*" -i "\\.swift$" -x "$PROJECT_ROOT" | while read file event; do
            # Skip build directories
            if [[ "$file" == *".build"* ]] || [[ "$file" == *"DerivedData"* ]]; then
                continue
            fi
            
            echo "🔄 Detected change in: $(basename "$file")"
            touch ~/.hotreload
            sleep 0.5  # Debounce
        done
        """
        
        let scriptPath = FileManager.default.currentDirectoryPath + "/auto-hotreload.sh"
        
        do {
            try scriptContent.write(toFile: scriptPath, atomically: true, encoding: .utf8)
            
            // Make it executable
            let attributes = [FileAttributeKey.posixPermissions: 0o755]
            try FileManager.default.setAttributes(attributes, ofItemAtPath: scriptPath)
            
            print("📝 Created auto-hotreload.sh script at: \(scriptPath)")
            print("💡 Run with: ./auto-hotreload.sh")
            print("💡 Requires fswatch: brew install fswatch")
        } catch {
            print("❌ Failed to create auto-watch script: \(error)")
        }
        #else
        print("💡 Auto-watch scripts are only available on macOS")
        #endif
    }
    
    /// Setup complete hot reloading environment
    public static func setupEnvironment() {
        #if DEBUG
        print("🔥 Setting up HotReloading environment...")
        
        // Use iOS-compatible home directory method
        let homeDirectory: URL
        #if os(iOS) || os(watchOS) || os(tvOS)
        homeDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        #else
        homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        #endif
        
        let triggerFile = homeDirectory.appendingPathComponent(".hotreload")
        
        if !FileManager.default.fileExists(atPath: triggerFile.path) {
            let content = """
            # HotReloading Trigger File
            # Touch this file to trigger hot reloads
            # Created: \(Date())
            """.data(using: .utf8)
            
            FileManager.default.createFile(
                atPath: triggerFile.path,
                contents: content,
                attributes: nil
            )
            print("✅ Created trigger file: \(triggerFile.path)")
        }
        
        // Create convenience scripts (macOS only)
        #if os(macOS)
        createShellScript()
        createAutoWatchScript()
        createVSCodeTask()
        #endif
        
        print("🎉 HotReloading environment setup complete!")
        print("")
        print("🚀 Quick Start:")
        print("1. Wrap your views: HotReloading { ContentView() }")
        print("2. Manual trigger: HotReloadTrigger.trigger()")
        print("3. Triple-tap any view for quick reload")
        #if os(macOS)
        print("4. Auto-watch: ./auto-hotreload.sh (requires fswatch)")
        #endif
        print("")
        #endif
    }
    
    /// Create VS Code task for hot reloading (macOS only)
    private static func createVSCodeTask() {
        #if DEBUG && os(macOS)
        let vscodeDir = FileManager.default.currentDirectoryPath + "/.vscode"
        let tasksFile = vscodeDir + "/tasks.json"
        
        // Create .vscode directory if it doesn't exist
        try? FileManager.default.createDirectory(atPath: vscodeDir, withIntermediateDirectories: true)
        
        let tasksContent = """
        {
            "version": "2.0.0",
            "tasks": [
                {
                    "label": "Hot Reload",
                    "type": "shell",
                    "command": "touch ~/.hotreload",
                    "group": "build",
                    "presentation": {
                        "echo": false,
                        "reveal": "never",
                        "focus": false,
                        "panel": "shared",
                        "showReuseMessage": false,
                        "clear": false
                    },
                    "problemMatcher": []
                },
                {
                    "label": "Start Auto Hot Reload",
                    "type": "shell",
                    "command": "./auto-hotreload.sh",
                    "group": "build",
                    "isBackground": true,
                    "presentation": {
                        "echo": true,
                        "reveal": "always",
                        "focus": false,
                        "panel": "new"
                    },
                    "problemMatcher": []
                }
            ]
        }
        """
        
        do {
            try tasksContent.write(toFile: tasksFile, atomically: true, encoding: .utf8)
            print("📝 Created VS Code tasks: .vscode/tasks.json")
            print("💡 Use Cmd+Shift+P → 'Tasks: Run Task' → 'Hot Reload'")
        } catch {
            // Silently fail - VS Code setup is optional
        }
        #endif
    }
    
    /// Enable keyboard shortcuts (when possible)
    public static func enableKeyboardShortcuts() {
        #if DEBUG
        print("⌨️  Available shortcuts:")
        #if os(macOS)
        print("💡 Cmd+R in Xcode to rebuild")
        print("💡 Use VS Code task: Cmd+Shift+P → 'Hot Reload'")
        #endif
        print("💡 Triple-tap any view for quick reload")
        print("💡 Use HotReloadTrigger.trigger() programmatically")
        #endif
    }
}
