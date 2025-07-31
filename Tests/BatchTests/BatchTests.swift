import XCTest
@testable import Batch

final class BatchTests: XCTestCase {
    
    func testInitialState() {
        let batch = Batch()
        XCTAssertEqual(batch.count, 0)
        XCTAssertTrue(batch.allGroups().isEmpty)
    }
    
    func testBasicIndexAccess() {
        let batch = Batch()
        
        // Accessing index 0 should create the first DispatchGroup
        let group0 = batch[0]
        XCTAssertEqual(batch.count, 1)
        
        // Accessing the same index should return the same group
        let sameGroup0 = batch[0]
        XCTAssertTrue(group0 === sameGroup0)
        XCTAssertEqual(batch.count, 1)
    }
    
    func testNonSequentialIndexAccess() {
        let batch = Batch()
        
        // Accessing index 5 should create groups 0-5
        let group5 = batch[5]
        XCTAssertEqual(batch.count, 6)
        
        // All groups should be accessible
        for i in 0...5 {
            XCTAssertNotNil(batch[i])
        }
        
        // Group at index 5 should be the same as initially accessed
        XCTAssertTrue(group5 === batch[5])
    }
    
    func testNegativeIndexPrecondition() {
        let batch = Batch()
        
        // Accessing negative index should trigger precondition failure
        XCTAssertThrowsError(try {
            _ = batch[-1]
        }(), "Expected precondition failure for negative index")
    }
    
    func testThreadSafety() {
        let batch = Batch()
        let expectation = XCTestExpectation(description: "Thread safety test")
        let iterations = 100
        var completedOperations = 0
        
        // Perform concurrent access from multiple threads
        for i in 0..<iterations {
            DispatchQueue.global().async {
                let group = batch[i % 10] // Access groups 0-9
                group.enter()
                
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.001) {
                    group.leave()
                    
                    DispatchQueue.main.async {
                        completedOperations += 1
                        if completedOperations == iterations {
                            expectation.fulfill()
                        }
                    }
                }
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(batch.count, 10)
    }
    
    func testDispatchGroupFunctionality() {
        let batch = Batch()
        let expectation = XCTestExpectation(description: "DispatchGroup functionality")
        
        let group = batch[0]
        group.enter()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            group.leave()
        }
        
        group.notify(queue: .main) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRemoveAll() {
        let batch = Batch()
        
        // Create some groups
        _ = batch[0]
        _ = batch[5]
        XCTAssertEqual(batch.count, 6)
        
        // Remove all groups
        batch.removeAll()
        
        // Wait a bit for the async operation to complete
        let expectation = XCTestExpectation(description: "Remove all completion")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(batch.count, 0)
    }
    
    func testWaitForAll() {
        let batch = Batch()
        let startTime = DispatchTime.now()
        
        // Create multiple groups with work
        for i in 0..<3 {
            let group = batch[i]
            group.enter()
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                group.leave()
            }
        }
        
        let result = batch.waitForAll(timeout: .now() + 1.0)
        let endTime = DispatchTime.now()
        
        XCTAssertEqual(result, .success)
        XCTAssertGreaterThanOrEqual(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds, 100_000_000) // At least 0.1 seconds
    }
    
    func testWaitForAllTimeout() {
        let batch = Batch()
        
        let group = batch[0]
        group.enter()
        // Don't call leave() to simulate long-running work
        
        let result = batch.waitForAll(timeout: .now() + 0.1)
        XCTAssertEqual(result, .timedOut)
        
        // Clean up
        group.leave()
    }
    
    func testNotifyAll() {
        let batch = Batch()
        let expectation = XCTestExpectation(description: "Notify all completion")
        
        // Create multiple groups with work
        for i in 0..<3 {
            let group = batch[i]
            group.enter()
            
            DispatchQueue.global().asyncAfter(deadline: .now() + Double(i) * 0.05) {
                group.leave()
            }
        }
        
        batch.notifyAll(queue: .main) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testAllGroups() {
        let batch = Batch()
        
        // Initially empty
        XCTAssertTrue(batch.allGroups().isEmpty)
        
        // Create some groups
        let group0 = batch[0]
        let group2 = batch[2]
        
        let allGroups = batch.allGroups()
        XCTAssertEqual(allGroups.count, 3)
        XCTAssertTrue(allGroups[0] === group0)
        XCTAssertTrue(allGroups[2] === group2)
    }
}
