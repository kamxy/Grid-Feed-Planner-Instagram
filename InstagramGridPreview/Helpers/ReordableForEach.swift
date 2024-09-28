
import SwiftUI

public typealias Reorderable = Equatable & Identifiable

public struct ReorderableForEach<Item: Reorderable, Content: View, Preview: View>: View {
    public init(
        _ items: [Item],
        active: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> Content,
        @ViewBuilder preview: @escaping (Item) -> Preview,
        moveAction: @escaping (IndexSet, Int) -> Void,
        onEnd: @escaping () -> Void
    ) {
        self.items = items
        self._active = active
        self.content = content
        self.preview = preview
        self.moveAction = moveAction
        self.onEnd = onEnd
    }

    public init(
        _ items: [Item],
        active: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> Content,
        moveAction: @escaping (IndexSet, Int) -> Void,
        onEnd: @escaping () -> Void
    ) where Preview == EmptyView {
        self.items = items
        self._active = active
        self.content = content
        self.preview = nil
        self.moveAction = moveAction
        self.onEnd = onEnd
    }

    @Binding
    private var active: Item?

    @State
    private var hasChangedLocation = false

    private let items: [Item]
    private let content: (Item) -> Content
    private let preview: ((Item) -> Preview)?
    private let moveAction: (IndexSet, Int) -> Void
    let onEnd: () -> Void

    public var body: some View {
        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
            if let preview {
                contentView(for: item).gesture(DragGesture().onEnded { _ in
                    print("here")
                })
                .onDrag {
                    dragData(for: item)
                } preview: {
                    preview(item)
                }.onTapGesture {
                    print("ontap")
                }
            } else {
                contentView(for: item).gesture(DragGesture().onEnded { _ in
                    print("hero")
                })
                .onDrag {
                    dragData(for: item)
                }.onTapGesture {
                    print("ontapp")
                }
            }
        }
    }

    private func contentView(for item: Item) -> some View {
        content(item)
            .opacity(active == item && hasChangedLocation ? 0.5 : 1)
            .onDrop(
                of: [.text],
                delegate: ReorderableDragRelocateDelegate(
                    item: item,
                    items: items,
                    active: $active,
                    hasChangedLocation: $hasChangedLocation
                ) { from, to in
                    withAnimation {
                        moveAction(from, to)
                    }
                }
            )
    }

    private func dragData(for item: Item) -> NSItemProvider {
        active = item
        return NSItemProvider(object: "\(item.id)" as NSString)
    }
}
