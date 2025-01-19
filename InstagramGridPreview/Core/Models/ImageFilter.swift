import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

enum ImageFilter: String, CaseIterable, Identifiable {
    case none = "Original"
    case mono = "Mono"
    case noir = "Noir"
    case fade = "Fade"
    case chrome = "Chrome"
    case process = "Process"
    case tonal = "Tonal"
    case transfer = "Transfer"
    case instant = "Instant"
    
    var id: String { rawValue }
    
    func apply(to image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image),
              let filter = getFilter() else { return image }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter.outputImage,
              let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    private func getFilter() -> CIFilter? {
        switch self {
        case .none:
            return nil
        case .mono:
            return CIFilter.photoEffectMono()
        case .noir:
            return CIFilter.photoEffectNoir()
        case .fade:
            return CIFilter.photoEffectFade()
        case .chrome:
            return CIFilter.photoEffectChrome()
        case .process:
            return CIFilter.photoEffectProcess()
        case .tonal:
            return CIFilter.photoEffectTonal()
        case .transfer:
            return CIFilter.photoEffectTransfer()
        case .instant:
            return CIFilter.photoEffectInstant()
        }
    }
} 