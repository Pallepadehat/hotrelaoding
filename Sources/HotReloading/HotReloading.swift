import SwiftUI
import Combine

/// A SwiftUI wrapper that enables seamless hot reloading for development.
/// 
/// Usage:
/// ```swift
/// HotReloading {
///     ContentView()
/// }
/// ```
///
/// The wrapper automatically detects file changes and rebuilds the wrapped view.
/// Works only in DEBUG mode and iOS Simulator for safety.
public struct HotReloading<Content: View>: View {
    @StateObject private var reloader = HotReloadManager.shared
    private let content: () -> Content
    private let enableAutoWatch: Bool
    
    /// Initialize with a view builder and optional auto-watching
    /// - Parameters:
    ///   - enableAutoWatch: Automatically watch for file changes (default: true)
    ///   - content: The SwiftUI view to wrap with hot reloading
    public init(enableAutoWatch: Bool = true, @ViewBuilder _ content: @escaping () -> Content) {
        self.enableAutoWatch = enableAutoWatch
        self.content = content
    }
    
    public var body: some View {
        #if DEBUG
        content()
            .id(reloader.reloadTrigger)
            .onAppear {
                if enableAutoWatch {
                    reloader.startAutoWatching()
                } else {
                    reloader.startWatching()
                }
            }
            .onDisappear {
                reloader.stopWatching()
            }
            .overlay(
                // Show reload indicator
                Group {
                    if reloader.isReloading {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("🔥 Reloading...")
                                    .font(.caption)
                                    .padding(8)
                                    .background(Color.black.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .padding()
                            }
                        }
                        .allowsHitTesting(false)
                    }
                }
            )
        #else
        content()
        #endif
    }
}

/// Convenience modifier for existing views
public extension View {
    /// Enables hot reloading for this view with automatic file watching
    /// - Parameter enableAutoWatch: Automatically watch for file changes (default: true)
    /// - Returns: A view wrapped with hot reloading capabilities
    func hotReloading(enableAutoWatch: Bool = true) -> some View {
        HotReloading(enableAutoWatch: enableAutoWatch) {
            self
        }
    }
    
    /// Quick hot reload trigger - adds a hidden button that triggers reload on triple-tap
    func quickReload() -> some View {
        #if DEBUG
        return self.overlay(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture(count: 3) {
                    HotReloadTrigger.trigger()
                }
        )
        #else
        return self
        #endif
    }
}
