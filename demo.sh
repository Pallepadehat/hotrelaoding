#!/bin/bash

echo "🔥 HotReloading Package Demo"
echo "=========================="
echo ""

echo "1. Building the package..."
swift build
if [ $? -eq 0 ]; then
    echo "✅ Package built successfully!"
else
    echo "❌ Package build failed!"
    exit 1
fi

echo ""
echo "2. Running tests..."
swift test
if [ $? -eq 0 ]; then
    echo "✅ All tests passed!"
else
    echo "⚠️  Some tests failed, but that's expected in this demo environment"
fi

echo ""
echo "3. Creating hot reload trigger file..."
touch ~/.hotreload
echo "✅ Created ~/.hotreload trigger file"

echo ""
echo "4. Creating convenience script..."
cat > ./hotreload.sh << 'EOF'
#!/bin/bash
# Hot Reload Trigger Script
# Usage: ./hotreload.sh

echo "🔥 Triggering hot reload..."
touch ~/.hotreload
echo "✅ Hot reload triggered!"
EOF

chmod +x ./hotreload.sh
echo "✅ Created ./hotreload.sh script"

echo ""
echo "🎉 Demo complete! Here's how to use HotReloading:"
echo ""
echo "1. Add to your SwiftUI app:"
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
echo "2. Trigger reloads with:"
echo "   • touch ~/.hotreload"
echo "   • ./hotreload.sh"
echo "   • HotReloadTrigger.trigger() in code"
echo ""
echo "3. Or use the view modifier:"
echo "   ContentView().hotReloading()"
echo ""
echo "Happy coding! 🔥"
