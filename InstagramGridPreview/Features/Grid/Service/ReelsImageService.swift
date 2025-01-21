import Foundation
import CoreData
import UIKit

actor ReelsImageService {
    private let container: NSPersistentContainer
    private let containerName = "ReelsContainer"
    private let entityName = "ReelImage"
    
    init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core Data: \(error)")
            }
        }
    }
    
    func loadReelsImages() async throws -> [UIImage?] {
        let context = container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        
        let results = try context.fetch(request)
        return results.map { entity in
            if let imageData = entity.value(forKey: "imageData") as? Data {
                return UIImage(data: imageData)
            }
            return nil
        }
    }
    
    func saveReelsImages(_ images: [UIImage?]) async throws {
        let context = container.viewContext
        
        // Delete existing images
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        
        // Save new images
        for (index, image) in images.enumerated() {
            guard let image = image,
                  let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
            
            let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
            entity.setValue(imageData, forKey: "imageData")
            entity.setValue(Int64(index), forKey: "order")
        }
        
        try context.save()
    }
} 