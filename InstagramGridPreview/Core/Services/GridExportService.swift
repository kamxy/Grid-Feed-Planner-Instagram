import UIKit

class GridExportService {
    enum ExportError: Error {
        case noImages
        case renderingFailed
        case invalidContext
    }
    
    struct ExportOptions {
        var spacing: CGFloat = 1
        var backgroundColor: UIColor = .white
        var borderWidth: CGFloat = 0
        var borderColor: UIColor = .clear
        var padding: CGFloat = 0
    }
    
    func exportGrid(images: [UIImage], columns: Int = 3, options: ExportOptions = ExportOptions()) throws -> UIImage {
        guard !images.isEmpty else { throw ExportError.noImages }
        
        // Calculate dimensions
        let spacing = options.spacing
        let padding = options.padding
        let totalSpacing = spacing * CGFloat(columns - 1)
        let totalPadding = padding * 2
        
        // Use Instagram's preferred 1080x1080 size
        let totalSize: CGFloat = 1080
        let availableSize = totalSize - totalSpacing - totalPadding
        let cellSize = availableSize / CGFloat(columns)
        
        // Create graphics context
        UIGraphicsBeginImageContextWithOptions(CGSize(width: totalSize, height: totalSize), true, 1)
        guard let context = UIGraphicsGetCurrentContext() else {
            throw ExportError.invalidContext
        }
        
        // Fill background
        context.setFillColor(options.backgroundColor.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: totalSize, height: totalSize))
        
        // Draw images
        for (index, image) in images.enumerated() {
            let row = index / columns
            let col = index % columns
            
            let x = padding + CGFloat(col) * (cellSize + spacing)
            let y = padding + CGFloat(row) * (cellSize + spacing)
            let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)
            
            // Draw border if needed
            if options.borderWidth > 0 {
                context.setStrokeColor(options.borderColor.cgColor)
                context.setLineWidth(options.borderWidth)
                context.stroke(rect)
            }
            
            // Draw image
            let drawRect = rect.insetBy(dx: options.borderWidth / 2, dy: options.borderWidth / 2)
            image.draw(in: drawRect, blendMode: .normal, alpha: 1)
        }
        
        // Get final image
        guard let finalImage = UIGraphicsGetImageFromCurrentImageContext() else {
            throw ExportError.renderingFailed
        }
        
        UIGraphicsEndImageContext()
        return finalImage
    }
    
    func saveToPhotos(_ image: UIImage, completion: @escaping (Error?) -> Void) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        completion(nil)
    }
    
    func copyToClipboard(_ image: UIImage) {
        UIPasteboard.general.image = image
    }
} 