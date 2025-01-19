import SwiftUI

struct GestureGuide: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let gestureType: GestureType
    let feature: GestureFeature
    let animationDuration: Double
    let repeatCount: Int
}

enum GestureType {
    case tap
    case longPress
    case drag
    case pinch
    case swipe(Edge)
}

enum GestureFeature: String {
    case gridReorder
    case imageEdit
    case multiSelect
    case export
    case zoom
}

final class GestureGuideService: ObservableObject {
    static let shared = GestureGuideService()
    
    @AppStorage("shownGestures") private var shownGesturesData: Data = Data()
    @Published var currentGuide: GestureGuide?
    
    private let guides: [GestureGuide] = [
        GestureGuide(
            title: "Reorder Images",
            description: "Touch and hold an image, then drag it to a new position",
            gestureType: .drag,
            feature: .gridReorder,
            animationDuration: 2.0,
            repeatCount: 2
        ),
        GestureGuide(
            title: "Quick Edit",
            description: "Tap any image to open the editor",
            gestureType: .tap,
            feature: .imageEdit,
            animationDuration: 1.0,
            repeatCount: 2
        ),
        GestureGuide(
            title: "Multi-Select Mode",
            description: "Long press any image to enter multi-select mode",
            gestureType: .longPress,
            feature: .multiSelect,
            animationDuration: 1.5,
            repeatCount: 1
        ),
        GestureGuide(
            title: "Preview Grid",
            description: "Pinch to zoom in/out of the grid preview",
            gestureType: .pinch,
            feature: .zoom,
            animationDuration: 2.0,
            repeatCount: 2
        ),
        GestureGuide(
            title: "Quick Export",
            description: "Swipe up from the bottom to access export options",
            gestureType: .swipe(.bottom),
            feature: .export,
            animationDuration: 1.5,
            repeatCount: 2
        )
    ]
    
    private init() {}
    
    func showGuideForFeature(_ feature: GestureFeature) {
        var shownGestures: Set<String> = []
        if let decoded = try? JSONDecoder().decode(Set<String>.self, from: shownGesturesData) {
            shownGestures = decoded
        }
        
        // Only show if not seen before
        guard !shownGestures.contains(feature.rawValue) else { return }
        
        if let guide = guides.first(where: { $0.feature == feature }) {
            currentGuide = guide
            shownGestures.insert(feature.rawValue)
            if let encoded = try? JSONEncoder().encode(shownGestures) {
                shownGesturesData = encoded
            }
        }
    }
    
    func dismissCurrentGuide() {
        currentGuide = nil
    }
    
    func resetGestureHistory() {
        shownGesturesData = Data()
        currentGuide = nil
    }
} 