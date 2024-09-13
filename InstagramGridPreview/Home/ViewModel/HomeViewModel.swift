import CoreData
import Photos
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var images: [OrderedImageEntity] = []
    @Published var isGallerySheetPresented = false
    @Published var selectedImages: [SelectableImage] = []
    @Published var gridImages: [SelectableImage] = []

    private let context = PersistenceController.shared.container.viewContext

    init() {
        fetchImages()
    }

    func fetchImages() {
        let request = NSFetchRequest<OrderedImageEntity>(entityName: "OrderedImageEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        request.predicate = NSPredicate(format: "isGrid == %@", NSNumber(value: true))

        do {
            images = try context.fetch(request)
            var temp: [SelectableImage] = []
            for image in images {
                if image.imageData != nil {
                    temp.append(SelectableImage(
                        id: image.id!,
                        image: UIImage(data: image.imageData!)!,
                        order: image.order)
                    )
                }
            }

            DispatchQueue.main.async {
                self.gridImages = temp
            }
        } catch {
            print("Error fetching images: \(error.localizedDescription)")
        }
    }

    func deleteImages() {
        for selectedImge in selectedImages {
            for image in images {
                if selectedImge.id == image.id {
                    context.delete(image)
                }
            }
        }
        selectedImages = []
        do {
            try context.save()
            fetchImages()
        } catch {}
    }

    func deleteAllEntities() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save() // Save the context after executing the batch delete
        } catch _ as NSError {}
    }
}
