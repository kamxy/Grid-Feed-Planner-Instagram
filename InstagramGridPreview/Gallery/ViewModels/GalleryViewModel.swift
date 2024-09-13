//
//  GalleryViewModel.swift
//  InstagramGridPreview
//
//  Created by Mehmet Kamay on 10.09.2024.
//

import CoreData
import Photos
import SwiftUI

class GalleryViewModel: ObservableObject {
    @Published var imagesFromGallery: [UIImage] = []
    @Published var galleryImages: [SelectableImage] = []
    @Published var selectedImages: [SelectableImage] = []
    @Published var isImagePickerPresented: Bool = false

    private let context = PersistenceController.shared.container.viewContext
    private let dbController = PersistenceController.shared

    init() {
        fetchImages()
    }

    func saveImages() {
        for image in imagesFromGallery {
            let newImageEntity = OrderedImageEntity(context: context)
            newImageEntity.imageData = image.pngData()
            newImageEntity.id = .init()
            newImageEntity.isGrid = false
        }

        dbController.saveContext()
        imagesFromGallery = []
        fetchImages()
    }

    func fetchImages() {
        let temp: [SelectableImage] = dbController.fetchImages(isGrid: false)
        DispatchQueue.main.async {
            self.galleryImages = temp
            self.imagePickerSheetTogle()
        }
    }

    func imagePickerSheetTogle() {
        isImagePickerPresented = galleryImages.isEmpty
    }

    func insertNewItemsAsFirst() {
        let fetchRequest = NSFetchRequest<OrderedImageEntity>(entityName: "OrderedImageEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]

        do {
            let results = try context.fetch(fetchRequest)

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

            selectedImages = []

        } catch _ as NSError {}
    }

    func deleteAllEntities() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderedImageEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch _ as NSError {}
    }
}
