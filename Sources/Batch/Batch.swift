import Foundation

/// A thread-safe collection for managing multiple DispatchGroups with index-based access.
/// 
/// Batch provides a higher-level API for working with multiple DispatchGroups without
/// the need to manually create and manage individual groups. Simply use index-based
/// access and Batch will automatically create and manage DispatchGroups as needed.
///
/// Example usage:
/// ```swift
/// let batch = Batch()
/// 
/// // Automatically creates DispatchGroup at index 0
/// batch[0].enter()
/// 
/// // Perform async work...
/// DispatchQueue.global().async {
///     // Do work
///     batch[0].leave()
/// }
/// 
/// batch[0].notify(queue: .main) {
///     print("Work completed!")
/// }
/// ```
public class Batch {
    private var dispatchGroups = Array<DispatchGroup>()
    private let queue = DispatchQueue(label: "com.batch.sync", attributes: .concurrent)
    
    /// The number of DispatchGroups currently managed by this Batch.
    public var count: Int {
        return queue.sync { dispatchGroups.count }
    }
    
    /// Creates a new empty Batch instance.
    public init() {}
    
    /// Removes all DispatchGroups from the batch.
    /// - Warning: This should only be called when you're sure no operations are pending.
    public func removeAll() {
        queue.async(flags: .barrier) {
            self.dispatchGroups.removeAll()
        }
    }
    
    /// Returns all DispatchGroups currently managed by this Batch.
    /// - Returns: An array of DispatchGroup instances.
    public func allGroups() -> [DispatchGroup] {
        return queue.sync { Array(dispatchGroups) }
    }
    
    /// Waits for all DispatchGroups in the batch to complete.
    /// - Parameter timeout: The maximum time to wait. Use .distantFuture to wait indefinitely.
    /// - Returns: .success if all groups completed, .timedOut if the timeout was reached.
    public func waitForAll(timeout: DispatchTime = .distantFuture) -> DispatchTimeoutResult {
        let groups = allGroups()
        
        for group in groups {
            let result = group.wait(timeout: timeout)
            if result == .timedOut {
                return .timedOut
            }
        }
        
        return .success
    }
    
    /// Notifies when all DispatchGroups in the batch complete.
    /// - Parameters:
    ///   - queue: The queue on which to execute the notification block.
    ///   - work: The block to execute when all groups complete.
    public func notifyAll(queue: DispatchQueue, execute work: @escaping () -> Void) {
        let groups = allGroups()
        let masterGroup = DispatchGroup()
        
        for group in groups {
            masterGroup.enter()
            group.notify(queue: queue) {
                masterGroup.leave()
            }
        }
        
        masterGroup.notify(queue: queue, execute: work)
    }
}

public extension Batch {
    /// Provides thread-safe access to DispatchGroups by index.
    /// 
    /// If a DispatchGroup doesn't exist at the specified index, it will be created automatically.
    /// The array will be expanded as needed to accommodate the requested index.
    ///
    /// - Parameter index: The index of the DispatchGroup to access. Must be non-negative.
    /// - Returns: The DispatchGroup at the specified index.
    /// - Precondition: index >= 0
    subscript(_ index: Int) -> DispatchGroup {
        precondition(index >= 0, "Index must be non-negative")
        
        return queue.sync(flags: .barrier) {
            // Ensure the array is large enough to accommodate the index
            while dispatchGroups.count <= index {
                dispatchGroups.append(DispatchGroup())
            }
            
            return dispatchGroups[index]
        }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        if !self.indices.contains(index) {
            return nil
        }
        return self[index]
    }
}

