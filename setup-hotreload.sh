#!/bin/bash

echo "🔥 HotReloading Setup Script"
echo "============================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}💡 $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in a Swift project
if [[ ! -f "Package.swift" ]] && ! ls *.xcodeproj &> /dev/null; then
    print_warning "No Swift project detected. This script works best in a Swift project directory."
fi

echo "1. Building HotReloading package..."
swift build
if [ $? -eq 0 ]; then
    print_status "Package built successfully!"
else
    print_error "Package build failed!"
    exit 1
fi

echo ""
echo "2. Setting up trigger file..."
touch ~/.hotreload
print_status "Created ~/.hotreload trigger file"

echo ""
echo "3. Creating convenience scripts..."

# Create basic hotreload script
cat > ./hotreload.sh << 'EOF'
#!/bin/bash
echo "🔥 Triggering hot reload..."
touch ~/.hotreload
echo "✅ Hot reload triggered at $(date '+%H:%M:%S')"
EOF
chmod +x ./hotreload.sh
print_status "Created ./hotreload.sh"

# Create auto-watch script
cat > ./auto-hotreload.sh << 'EOF'
#!/bin/bash
echo "🔥 Starting auto hot reload watcher..."
echo "💡 Watching for .swift file changes..."
echo "💡 Press Ctrl+C to stop"

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    echo "❌ fswatch not found."
    echo "📦 Installing fswatch with Homebrew..."
    if command -v brew &> /dev/null; then
        brew install fswatch
    else
        echo "❌ Homebrew not found. Please install fswatch manually:"
        echo "   brew install fswatch"
        exit 1
    fi
fi

# Find project root
PROJECT_ROOT="."
while [[ "$PROJECT_ROOT" != "/" ]]; do
    if ls "$PROJECT_ROOT"/*.xcodeproj &> /dev/null 2>&1 || [[ -f "$PROJECT_ROOT/Package.swift" ]]; then
        break
    fi
    PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done

echo "📁 Watching project at: $(realpath "$PROJECT_ROOT")"

# Watch for Swift file changes
fswatch -e ".*" -i "\.swift$" -x "$PROJECT_ROOT" | while read file event; do
    # Skip build directories and hidden files
    if [[ "$file" == *".build"* ]] || [[ "$file" == *"DerivedData"* ]] || [[ "$file" == */.*/* ]]; then
        continue
    fi
    
    echo "🔄 $(date '+%H:%M:%S') - Change detected: $(basename "$file")"
    touch ~/.hotreload
    sleep 0.3  # Debounce rapid changes
done
EOF
chmod +x ./auto-hotreload.sh
print_status "Created ./auto-hotreload.sh"

echo ""
echo "4. Setting up VS Code integration..."

# Create .vscode directory and tasks
mkdir -p .vscode
cat > .vscode/tasks.json << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Hot Reload",
            "type": "shell",
            "command": "touch ~/.hotreload && echo '🔥 Hot reload triggered!'",
            "group": "build",
            "presentation": {
                "echo": false,
                "reveal": "silent",
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
            "command": "${workspaceFolder}/auto-hotreload.sh",
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
EOF
print_status "Created VS Code tasks"

# Create VS Code keybindings
cat > .vscode/keybindings.json << 'EOF'
[
    {
        "key": "cmd+shift+r",
        "command": "workbench.action.tasks.runTask",
        "args": "Hot Reload"
    }
]
EOF
print_status "Created VS Code keybindings (Cmd+Shift+R)"

echo ""
echo "5. Checking dependencies..."

# Check for fswatch
if command -v fswatch &> /dev/null; then
    print_status "fswatch is installed"
else
    print_warning "fswatch not found - auto-watch won't work"
    print_info "Install with: brew install fswatch"
fi

# Check for Homebrew
if command -v brew &> /dev/null; then
    print_status "Homebrew is available"
else
    print_warning "Homebrew not found - some features may not work"
fi

echo ""
echo "6. Creating example usage..."

# Create example SwiftUI app
cat > ExampleHotReloadApp.swift << 'EOF'
import SwiftUI
import HotReloading

// Example: How to use HotReloading in your app
@main
struct ExampleHotReloadApp: App {
    var body: some Scene {
        WindowGroup {
            // Method 1: Wrap your entire app
            HotReloading {
                ContentView()
            }
        }
    }
}

struct ContentView: View {
    @State private var counter = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🔥 Hot Reload Demo")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Counter: \(counter)")
                .font(.title2)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            
            Button("Increment") {
                counter += 1
            }
            .buttonStyle(.borderedProminent)
            
            Text("Try editing this view and:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("• Triple-tap anywhere for quick reload")
                Text("• Run ./hotreload.sh")
                Text("• Use Cmd+Shift+R in VS Code")
                Text("• Run ./auto-hotreload.sh for auto-watch")
            }
            .font(.caption)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        // Method 2: Use the modifier
        .quickReload() // Triple-tap to reload
    }
}

// Alternative usage examples:
struct AlternativeExamples: View {
    var body: some View {
        VStack {
            // Method 3: Manual auto-watch control
            Text("Manual Control")
                .hotReloading(enableAutoWatch: false)
            
            // Method 4: Conditional hot reloading
            #if DEBUG
            HotReloading {
                Text("Debug only hot reload")
            }
            #else
            Text("Production version")
            #endif
        }
    }
}
EOF
print_status "Created ExampleHotReloadApp.swift"

echo ""
echo "🎉 HotReloading setup complete!"
echo ""
echo "🚀 Quick Start Guide:"
echo "===================="
echo ""
print_info "1. Add to your SwiftUI app:"
echo "   import HotReloading"
echo ""
echo "   @main"
echo "   struct MyApp: App {"
echo "       var body: some Scene {"
echo "           WindowGroup {"
echo "               HotReloading {"
echo "                   ContentView()"
echo "               }"
echo "           }"
echo "       }"
echo "   }"
echo ""
print_info "2. Trigger reloads:"
echo "   • Triple-tap any view (instant)"
echo "   • ./hotreload.sh (manual)"
echo "   • Cmd+Shift+R in VS Code"
echo "   • touch ~/.hotreload"
echo ""
print_info "3. Auto-watch mode:"
echo "   • ./auto-hotreload.sh (watches .swift files)"
echo "   • Or use VS Code task: 'Start Auto Hot Reload'"
echo ""
print_info "4. Development workflow:"
echo "   • Build your app once in Xcode (Cmd+R)"
echo "   • Make changes to SwiftUI views"
echo "   • Trigger reload (any method above)"
echo "   • See changes instantly!"
echo ""
echo "📁 Files created:"
echo "   • hotreload.sh - Manual trigger script"
echo "   • auto-hotreload.sh - Auto-watch script"
echo "   • .vscode/tasks.json - VS Code integration"
echo "   • .vscode/keybindings.json - Keyboard shortcuts"
echo "   • ExampleHotReloadApp.swift - Usage example"
echo ""
print_status "Happy hot reloading! 🔥"
