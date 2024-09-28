import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()
    let getRequest: NSFetchRequest<OrderedImageEntity> = OrderedImageEntity.fetchRequest()
    let container: NSPersistentContainer
    let ascendingSort: NSSortDescriptor = .init(key: "order", ascending: true)

    init() {
        container = NSPersistentContainer(name: "ImageModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func saveImageToGallery(imagesFromGallery: [UIImage]) {
        let context = container.viewContext

        for image in imagesFromGallery {
            let newImageEntity = OrderedImageEntity(context: context)
            newImageEntity.imageData = image.pngData()
            newImageEntity.id = .init()
            newImageEntity.isGrid = false
        }
        saveContext()
    }

    func addImagesToGrid(selectedImages: [SelectableImage]) {
        getRequest.sortDescriptors?.append(ascendingSort)
        let context = container.viewContext
        do {
            let results = try container.viewContext.fetch(getRequest)

            for entity in results {
                entity.order += Int32(selectedImages.count)
            }

            for (index, image) in selectedImages.enumerated() {
                let newImageEntity = OrderedImageEntity(context: context)
                newImageEntity.imageData = image.image.pngData()
                newImageEntity.order = Int32(index) // Set order for each new image
                newImageEntity.id = .init()
                newImageEntity.isGrid = true
            }
            try context.save()

        } catch _ as NSError {}
    }

    func fetchImages(isGrid: Bool) -> [SelectableImage] {
        do {
            getRequest.predicate = filter(isGrid: isGrid)
            let images = try container.viewContext.fetch(getRequest)
            var temp: [SelectableImage] = []
            for image in images {
                if image.imageData != nil {
                    temp.append(SelectableImage(
                        id: image.id!,
                        image: UIImage(data: image.imageData!)!, order: image.order))
                }
            }
            return temp
        } catch {}
        return []
    }

    func filter(isGrid: Bool) -> NSPredicate {
        return NSPredicate(format: "isGrid == %@", NSNumber(value: isGrid))
    }

    func deleteAllEntities() {
        let context = container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch _ as NSError {}
    }
}
