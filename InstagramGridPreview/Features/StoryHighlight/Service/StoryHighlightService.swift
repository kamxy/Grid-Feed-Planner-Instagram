import Foundation
import CoreData
import UIKit

actor StoryHighlightService {
    private let container: NSPersistentContainer
    private let containerName = "StoryHighlightContainer"
    private let entityName = "StoryHighlightItem"
    
    init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core Data: \(error)")
            }
        }
    }
    
    func loadHighlights() async throws -> [StoryHighlight] {
        let context = container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        
        let results = try context.fetch(request)
        return results.compactMap { entity -> StoryHighlight? in
            guard let id = entity.value(forKey: "id") as? UUID,
                  let title = entity.value(forKey: "title") as? String,
                  let imageData = entity.value(forKey: "imageData") as? Data,
                  let image = UIImage(data: imageData) else {
                return nil
            }
            return StoryHighlight(id: id, title: title, image: image)
        }
    }
    
    func saveHighlights(_ highlights: [StoryHighlight]) async throws {
        let context = container.viewContext
        
        // Delete existing highlights
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        
        // Save new highlights
        for (index, highlight) in highlights.enumerated() {
            guard let imageData = highlight.image.jpegData(compressionQuality: 0.8) else { continue }
            
            let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
            entity.setValue(highlight.id, forKey: "id")
            entity.setValue(highlight.title, forKey: "title")
            entity.setValue(imageData, forKey: "imageData")
            entity.setValue(Int64(index), forKey: "order")
        }
        
        try context.save()
    }
    
    func addHighlight(_ highlight: StoryHighlight) async throws {
        var highlights = try await loadHighlights()
        highlights.append(highlight)
        try await saveHighlights(highlights)
    }
    
    func removeHighlight(at index: Int) async throws {
        var highlights = try await loadHighlights()
        guard index < highlights.count else { return }
        highlights.remove(at: index)
        try await saveHighlights(highlights)
    }
    
    func moveHighlight(from source: Int, to destination: Int) async throws {
        var highlights = try await loadHighlights()
        guard source < highlights.count, destination < highlights.count else { return }
        let highlight = highlights.remove(at: source)
        highlights.insert(highlight, at: destination)
        try await saveHighlights(highlights)
    }
    
    func updateHighlight(_ highlight: StoryHighlight, at index: Int) async throws {
        var highlights = try await loadHighlights()
        guard index < highlights.count else { return }
        highlights[index] = highlight
        try await saveHighlights(highlights)
    }
} 