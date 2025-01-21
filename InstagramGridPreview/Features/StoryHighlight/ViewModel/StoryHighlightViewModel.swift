import SwiftUI

@MainActor
final class StoryHighlightViewModel: ObservableObject {
    @Published private(set) var highlights: [StoryHighlight] = []
    private let storyHighlightService = StoryHighlightService()
    
    init() {
        Task {
            await loadHighlights()
        }
    }
    
    private func loadHighlights() async {
        do {
            highlights = try await storyHighlightService.loadHighlights()
        } catch {
            print("Error loading highlights: \(error)")
        }
    }
    
    func addHighlight(title: String, image: UIImage) async {
        let highlight = StoryHighlight(title: title, image: image)
        do {
            try await storyHighlightService.addHighlight(highlight)
            await loadHighlights()
        } catch {
            print("Error adding highlight: \(error)")
        }
    }
    
    func removeHighlight(at index: Int) async {
        do {
            try await storyHighlightService.removeHighlight(at: index)
            await loadHighlights()
        } catch {
            print("Error removing highlight: \(error)")
        }
    }
    
    func moveHighlight(from source: Int, to destination: Int) async {
        do {
            try await storyHighlightService.moveHighlight(from: source, to: destination)
            await loadHighlights()
        } catch {
            print("Error moving highlight: \(error)")
        }
    }
    
    func updateHighlight(_ highlight: StoryHighlight, at index: Int) async {
        do {
            try await storyHighlightService.updateHighlight(highlight, at: index)
            await loadHighlights()
        } catch {
            print("Error updating highlight: \(error)")
        }
    }
} 