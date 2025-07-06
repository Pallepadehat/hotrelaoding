# 🔥 HotReloading - Complete Usage Guide

## 🚀 Quick Start (30 seconds)

1. **Add to your SwiftUI app:**
```swift
import HotReloading

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            HotReloading {
                ContentView()
            }
        }
    }
}
```

2. **Build your app once in Xcode** (Cmd+R)

3. **Make changes to your SwiftUI views**

4. **Trigger reload** (choose any method):
   - **Triple-tap anywhere** on your view (instant!)
   - Run `./hotreload.sh` in terminal
   - Press **Cmd+Shift+R** in VS Code
   - Run `touch ~/.hotreload` in terminal

5. **See changes instantly!** 🎉

## 🎯 Trigger Methods (From Fastest to Slowest)

### 1. Triple-Tap (Instant) ⚡
- **Speed**: Instant
- **How**: Triple-tap anywhere on your view
- **Setup**: Add `.quickReload()` to any view
```swift
ContentView()
    .quickReload() // Enables triple-tap
```

### 2. Keyboard Shortcut (VS Code) ⌨️
- **Speed**: ~0.1 seconds
- **How**: Press **Cmd+Shift+R** in VS Code
- **Setup**: Already configured by setup script

### 3. Shell Script 📜
- **Speed**: ~0.2 seconds
- **How**: Run `./hotreload.sh` in terminal
- **Setup**: Already created by setup script

### 4. Manual Command 💻
- **Speed**: ~0.2 seconds
- **How**: Run `touch ~/.hotreload` in terminal
- **Setup**: No setup needed

### 5. Auto-Watch (Automatic) 🤖
- **Speed**: ~0.5 seconds after file save
- **How**: Automatically detects Swift file changes
- **Setup**: Run `./auto-hotreload.sh` in terminal

## 🛠 Advanced Usage

### Method 1: Basic Wrapper
```swift
import HotReloading

HotReloading {
    ContentView()
}
```

### Method 2: View Modifier
```swift
ContentView()
    .hotReloading()
```

### Method 3: Conditional (Recommended)
```swift
#if DEBUG
HotReloading {
    ContentView()
}
#else
ContentView()
#endif
```

### Method 4: Manual Control
```swift
HotReloading(enableAutoWatch: false) {
    ContentView()
}
```

### Method 5: Programmatic Trigger
```swift
Button("Reload") {
    HotReloadTrigger.trigger()
}
```

## 🔧 Development Workflows

### Workflow 1: Triple-Tap (Recommended)
1. Build app once in Xcode (Cmd+R)
2. Add `.quickReload()` to your main view
3. Make changes to SwiftUI code
4. Triple-tap anywhere → instant reload!

### Workflow 2: VS Code Integration
1. Open project in VS Code
2. Build app once in Xcode (Cmd+R)
3. Make changes in VS Code
4. Press Cmd+Shift+R → reload!

### Workflow 3: Auto-Watch
1. Build app once in Xcode (Cmd+R)
2. Run `./auto-hotreload.sh` in terminal
3. Make changes to any .swift file
4. Save file → automatic reload!

### Workflow 4: Terminal-Based
1. Build app once in Xcode (Cmd+R)
2. Keep terminal open
3. Make changes to SwiftUI code
4. Run `./hotreload.sh` → reload!

## 📱 Platform Support

- ✅ **iOS Simulator** (Primary target)
- ✅ **macOS** (Full support)
- ⚠️ **iOS Device** (Limited - manual triggers only)
- ⚠️ **watchOS/tvOS** (Basic support)

## 🎨 Visual Feedback

When you trigger a reload, you'll see:
- 🔥 "Reloading..." indicator on screen
- Console messages with timestamps
- Smooth animation transitions

## 🚨 Troubleshooting

### Hot Reload Not Working?

1. **Check DEBUG mode**: Only works in debug builds
2. **Verify Simulator**: Works best in iOS Simulator
3. **Check console**: Look for "🔥 HotReloading" messages
4. **Try manual trigger**: Use `HotReloadTrigger.trigger()`

### Auto-Watch Not Working?

1. **Check fswatch**: Run `brew install fswatch`
2. **Check project structure**: Must have .xcodeproj or Package.swift
3. **Check file paths**: Avoid spaces in project path
4. **Try manual mode**: Use `./hotreload.sh` instead

### Performance Issues?

1. **Limit scope**: Only wrap views you're actively developing
2. **Use conditionally**: Wrap with `#if DEBUG`
3. **Disable auto-watch**: Use `enableAutoWatch: false`

## 🎯 Best Practices

### ✅ Do This
- Wrap your root view with `HotReloading`
- Use triple-tap for fastest iteration
- Enable only in DEBUG builds
- Use with iOS Simulator for best performance
- Keep the scope limited to views you're developing

### ❌ Avoid This
- Don't wrap every single view
- Don't use in production builds
- Don't expect it to work on physical devices
- Don't use with complex state management without testing

## 🔍 Under the Hood

### How It Works
1. **File Watching**: Monitors `~/.hotreload` file for changes
2. **View Invalidation**: Uses SwiftUI's `.id()` modifier
3. **State Reset**: View state is recreated (not preserved)
4. **Safety Checks**: Only active in DEBUG + Simulator

### Performance Impact
- **Minimal**: Only active in debug builds
- **Efficient**: Uses optimized file system events
- **Safe**: Automatically disabled in production

## 📚 API Reference

### HotReloading
```swift
HotReloading(enableAutoWatch: Bool = true) {
    // Your SwiftUI view
}
```

### View Extensions
```swift
.hotReloading(enableAutoWatch: Bool = true)
.quickReload() // Enables triple-tap
```

### HotReloadTrigger
```swift
HotReloadTrigger.trigger()                    // Manual trigger
HotReloadTrigger.createShellScript()          // Create script
HotReloadTrigger.createAutoWatchScript()      // Create auto-watcher
HotReloadTrigger.setupEnvironment()           // Full setup
```

## 🎉 Tips & Tricks

### Tip 1: Combine with SwiftUI Previews
Use both for maximum productivity:
```swift
struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    ContentView()
        .quickReload()
}
```

### Tip 2: Debug Overlay
Add a debug overlay to see reload status:
```swift
.overlay(
    Text("🔥 Hot Reload Active")
        .font(.caption)
        .padding(4)
        .background(Color.red.opacity(0.8))
        .foregroundColor(.white)
        .cornerRadius(4)
        .padding(),
    alignment: .topTrailing
)
```

### Tip 3: Environment Setup
Run this once per project:
```swift
// In your app's init or onAppear
HotReloadTrigger.setupEnvironment()
```

---

**Happy hot reloading! 🔥**

*Made with ❤️ for faster SwiftUI development*
