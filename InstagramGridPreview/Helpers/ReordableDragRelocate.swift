
import SwiftUI

struct ReorderableDragRelocateDelegate<Item: Reorderable>: DropDelegate {
    
    let item: Item
    var items: [Item]
    
    @Binding var active: Item?
    @Binding var hasChangedLocation: Bool

    var moveAction: (IndexSet, Int) -> Void

    func dropEntered(info: DropInfo) {
        guard item != active, let current = active else { return }
        guard let from = items.firstIndex(of: current) else { return }
        guard let to = items.firstIndex(of: item) else { return }
        hasChangedLocation = true
        if items[to] != current {
            moveAction(IndexSet(integer: from), to > from ? to + 1 : to)
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        hasChangedLocation = false
        active = nil
        return true
    }
}

struct ReorderableDropOutsideDelegate<Item: Reorderable>: DropDelegate {
    
    @Binding
    var active: Item?
        
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        active = nil
        return true
    }
}


public extension View {
    
    func reorderableForEachContainer<Item: Reorderable>(
        active: Binding<Item?>
    ) -> some View {
        onDrop(of: [.text], delegate: ReorderableDropOutsideDelegate(active: active))
    }
}
