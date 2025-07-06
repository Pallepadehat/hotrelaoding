import SwiftUI
import HotReloading

// MARK: - Example App

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            HotReloading {
                ContentView()
            }
        }
    }
}

// MARK: - Example Views

struct ContentView: View {
    @State private var counter = 0
    @State private var showingSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🔥 HotReloading Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Counter: \(counter)")
                    .font(.title2)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                
                HStack(spacing: 15) {
                    Button("Increment") {
                        counter += 1
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Reset") {
                        counter = 0
                    }
                    .buttonStyle(.bordered)
                }
                
                Button("Show Sheet") {
                    showingSheet = true
                }
                .buttonStyle(.borderedProminent)
                
                NavigationLink("Navigate to Detail") {
                    DetailView()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                VStack {
                    Text("💡 Try editing this view and trigger a reload:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("touch ~/.hotreload")
                        .font(.caption.monospaced())
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(5)
                }
            }
            .padding()
            .navigationTitle("Hot Reload Demo")
        }
        .sheet(isPresented: $showingSheet) {
            SheetView()
        }
    }
}

struct DetailView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🎯 Detail View")
                .font(.largeTitle)
            
            Text("This view also supports hot reloading!")
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Manual Reload") {
                HotReloadTrigger.trigger()
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("📋 Sheet View")
                    .font(.title)
                
                Text("Hot reloading works in sheets too!")
                    .padding()
                
                Button("Create Shell Script") {
                    HotReloadTrigger.createShellScript()
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Sheet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Alternative Usage Examples

struct AlternativeUsageExamples: View {
    var body: some View {
        VStack {
            // Method 1: Using the wrapper
            HotReloading {
                Text("Wrapped with HotReloading")
            }
            
            // Method 2: Using the modifier
            Text("Using .hotReloading() modifier")
                .hotReloading()
            
            // Method 3: Conditional usage
            #if DEBUG
            HotReloading {
                Text("Only in DEBUG builds")
            }
            #else
            Text("Production build")
            #endif
        }
    }
}
