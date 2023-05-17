# Batch

Use DispatchGroups the painless way!

## Installation

Simply use SPM.


## Usage
```
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
