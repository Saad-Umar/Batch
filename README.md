# Batch

A **thread-safe**, **high-performance** Swift library that provides a clean, index-based API for managing multiple `DispatchGroup` instances. Say goodbye to manually creating and managing individual dispatch groups!

## Why Batch?

Instead of cluttering your code with multiple dispatch group variables:

```swift
var dispatchGroupForAPISet1 = DispatchGroup()  
var dispatchGroupForAPISet2 = DispatchGroup()  
var dispatchGroupForAPISet3 = DispatchGroup()  

// Later in your code...
dispatchGroupForAPISet1.enter()  
dispatchGroupForAPISet2.enter()  
// ...
dispatchGroupForAPISet2.leave()  
```

**Simply use Batch with familiar index-based access:**

```swift
let batch = Batch()

batch[0].enter()  
batch[1].enter()  
// ...
batch[0].leave()  
```

## Features

✅ **Thread-Safe**: Built with concurrent queues and proper synchronization  
✅ **Automatic Management**: DispatchGroups are created on-demand  
✅ **Index-Based Access**: Familiar array-like syntax  
✅ **Comprehensive API**: Additional utility methods for common patterns  
✅ **Zero Dependencies**: Pure Swift/Foundation implementation  
✅ **Extensively Tested**: 100% test coverage with edge cases  

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/Batch.git", from: "1.0.0")
]
```

Or add it through Xcode: **File → Add Package Dependencies**

## Usage

### Basic Usage

```swift
import Batch

let batch = Batch()

// Automatically creates DispatchGroup at index 0
batch[0].enter()

// Perform async work
DispatchQueue.global().async {
    // Simulate work
    Thread.sleep(forTimeInterval: 1.0)
    batch[0].leave()
}

// Get notified when work completes
batch[0].notify(queue: .main) {
    print("Work completed!")
}
```

### Advanced Usage

```swift
import Batch

class NetworkManager {
    private let batch = Batch()
    
    func fetchAllData() {
        // Start multiple API calls
        fetchUserData(groupIndex: 0)
        fetchSettings(groupIndex: 1) 
        fetchNotifications(groupIndex: 2)
        
        // Wait for all to complete
        batch.notifyAll(queue: .main) {
            print("All API calls completed!")
            self.updateUI()
        }
    }
    
    private func fetchUserData(groupIndex: Int) {
        batch[groupIndex].enter()
        
        URLSession.shared.dataTask(with: userURL) { data, response, error in
            // Process data...
            self.batch[groupIndex].leave()
        }.resume()
    }
    
    // Similar methods for other API calls...
}
```

### SwiftUI Integration

```swift
import SwiftUI
import Batch

struct ContentView: View {
    @State private var batch = Batch()
    @State private var isLoading = false
    @State private var results: [String] = []
    
    var body: some View {
        VStack {
            Button("Load Data") {
                loadMultipleDataSources()
            }
            .disabled(isLoading)
            
            List(results, id: \.self) { result in
                Text(result)
            }
        }
    }
    
    private func loadMultipleDataSources() {
        isLoading = true
        results.removeAll()
        
        // Start multiple async operations
        for i in 0..<5 {
            batch[i].enter()
            
            DispatchQueue.global().async {
                // Simulate API call
                Thread.sleep(forTimeInterval: Double.random(in: 0.5...2.0))
                
                DispatchQueue.main.async {
                    self.results.append("Result \(i)")
                }
                
                self.batch[i].leave()
            }
        }
        
        // Notify when all complete
        batch.notifyAll(queue: .main) {
            self.isLoading = false
        }
    }
}
```

## API Reference

### Core Methods

- `batch[index]` - Access or create DispatchGroup at index
- `count` - Number of managed DispatchGroups
- `removeAll()` - Remove all DispatchGroups
- `allGroups()` - Get array of all DispatchGroups

### Utility Methods

- `waitForAll(timeout:)` - Block until all groups complete
- `notifyAll(queue:execute:)` - Execute block when all groups complete

### Thread Safety

Batch is fully thread-safe and can be accessed concurrently from multiple queues without additional synchronization.

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 5.8+

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
