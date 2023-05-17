# Batch

Does making DispatchGroups in iOS for various purposes all at once and managing them annoy you? Dont worry, you're covered. Meet Batch, a DispatchGroup collection but better! You dont have to worry about creating DispatchGroups over and over like:

var dispatchGroupForAPISet1 = DispatchGroup()  
var dispatchGroupForAPISet2 = DispatchGroup()  
var dispatchGroupForAPISet3 = DispatchGroup()  

then at some point:  

dispatchGroupForAPISet1.enter()  
dispatchGroupForAPISet2.enter()  
.....  

dispatchGroupForAPISet2.leave()  

YUCK!  

Simply use the logic you are already accustomed with, the indexed-based access logic! it will automatically create a new dispatchGroup internally and manage it for you so you dont have to worry, consider Batch a higher level api. Use Batch so:  

var batch = Batch()  

batch[0].enter()  
batch[0].leave()  
batch[0].notify(queue: .main, execute: {  
          print("work done!")  
})  

## Installation

Simply use SPM.


## Usage
```
import Batch

struct TestView: View {
    var batch = Batch()
    @State var incrementer = 0
    
    var body: some View {
        VStack {
            Button("Test") {
                batch[incrementer]
                print(batch[incrementer].enter())
                print(batch[incrementer].leave())
                print(batch[incrementer].notify(queue: .main, execute: {
                    print("work done!")
                }))
                incrementer += 1
                
            }
        }
    }
}
```

## Simplicity

You dont need to create multiple DispatchGroups and keep them in many variables in your code. Simply use indexed based array logic to enter a new group, dont worry it will automatically be created and managed for you, you just have to worry about .notify only. That's the magic!
