import Foundation

class Batch {
    private var dispatchGroup = Array<DispatchGroup>()
    var count: Int {
        return dispatchGroup.count
    }
    
}

extension Batch {
    subscript(_ index: Int) -> DispatchGroup {
        var dispatchGroup: DispatchGroup!
        
        if let _ = self.dispatchGroup[safe: index] {
            dispatchGroup = self.dispatchGroup[index]
        } else {
            dispatchGroup = DispatchGroup()
            self.dispatchGroup.append(dispatchGroup)
        }
        
        return dispatchGroup
        
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

