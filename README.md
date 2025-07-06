# 🔥 HotReloading

A drop-in SwiftUI hot reloading solution that makes iOS development faster and more enjoyable.

## ✨ Features

- **Zero Configuration**: Just wrap your views and go
- **Multiple Trigger Methods**: File watching, manual triggers, shell scripts
- **Safe by Default**: Only works in DEBUG mode and iOS Simulator
- **Performance Optimized**: Efficient file watching with minimal overhead
- **Cross-Platform**: Works on iOS, macOS, watchOS, and tvOS

## 🚀 Quick Start

### 1. Add the Package

In Xcode, go to **File → Add Package Dependencies** and add:
```
https://github.com/yourusername/HotReloading
```

### 2. Wrap Your Views

```swift
import SwiftUI
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

### 3. Trigger Reloads

**Method 1: Touch the trigger file**
```bash
touch ~/.hotreload
```

**Method 2: Use the convenience modifier**
```swift
ContentView()
    .hotReloading()
```

**Method 3: Programmatic trigger**
```swift
import HotReloading

// Somewhere in your code
HotReloadTrigger.trigger()
```

## 📖 Usage Examples

### Basic Usage
```swift
import SwiftUI
import HotReloading

struct ContentView: View {
    var body: some View {
        HotReloading {
            VStack {
                Text("Hello, World!")
                    .font(.largeTitle)
                Button("Tap me!") {
                    print("Button tapped")
                }
            }
        }
    }
}
```

### With View Modifier
```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
            Button("Tap me!") { }
        }
        .hotReloading() // Add hot reloading to any view
    }
}
```

### Conditional Hot Reloading
```swift
struct ContentView: View {
    var body: some View {
        #if DEBUG
        HotReloading {
            MyComplexView()
        }
        #else
        MyComplexView()
        #endif
    }
}
```

## 🛠 Advanced Usage

### Create a Shell Script
```swift
// Run this once to create a convenient script
HotReloadTrigger.createShellScript()
```

Then use:
```bash
./hotreload.sh
```

### Watch for File Changes (macOS)
The package automatically watches for changes in:
- `~/.hotreload` (primary trigger file)
- Your project directory
- Common source directories

### Manual Triggers
```swift
import HotReloading

Button("Reload") {
    HotReloadTrigger.trigger()
}
```

## 🔧 How It Works

1. **File Watching**: Monitors the `~/.hotreload` file for changes
2. **View Invalidation**: Uses SwiftUI's `.id()` modifier to force view rebuilds
3. **Safety Checks**: Only active in DEBUG builds and iOS Simulator
4. **Efficient Polling**: Uses optimized file system events on macOS

## 📱 Platform Support

- ✅ iOS 14.0+
- ✅ macOS 11.0+
- ✅ watchOS 7.0+
- ✅ tvOS 14.0+

## 🎯 Best Practices

### 1. Use at the Root Level
```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            HotReloading {
                ContentView() // Wrap your root view
            }
        }
    }
}
```

### 2. Combine with Environment Setup
```swift
HotReloading {
    ContentView()
        .environmentObject(dataModel)
        .preferredColorScheme(.dark)
}
```

### 3. Use with Navigation
```swift
HotReloading {
    NavigationView {
        ContentView()
    }
}
```

## 🚨 Troubleshooting

### Hot Reloading Not Working?

1. **Check DEBUG mode**: Only works in debug builds
2. **Verify Simulator**: Must be running in iOS Simulator (not device)
3. **Check file permissions**: Ensure `~/.hotreload` is writable
4. **Manual trigger**: Try `HotReloadTrigger.trigger()` programmatically

### Performance Issues?

1. **Limit scope**: Only wrap the views you're actively developing
2. **Use conditionally**: Wrap with `#if DEBUG` for production builds
3. **Check file watchers**: Ensure you're not watching too many directories

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details.

## 🙏 Acknowledgments

Inspired by React's hot reloading and the SwiftUI development experience.

---

**Happy coding! 🔥**
