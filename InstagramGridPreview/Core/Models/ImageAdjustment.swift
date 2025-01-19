import UIKit
import CoreImage

struct ImageAdjustment: Equatable {
    var brightness: Double = 0.0
    var contrast: Double = 1.0
    var saturation: Double = 1.0
    
    func apply(to image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        
        let colorControls = CIFilter.colorControls()
        colorControls.setValue(ciImage, forKey: kCIInputImageKey)
        colorControls.setValue(saturation, forKey: kCIInputSaturationKey)
        colorControls.setValue(contrast, forKey: kCIInputContrastKey)
        colorControls.setValue(brightness, forKey: kCIInputBrightnessKey)
        
        guard let outputImage = colorControls.outputImage,
              let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    static let ranges: [String: ClosedRange<Double>] = [
        "brightness": -1.0...1.0,
        "contrast": 0.0...2.0,
        "saturation": 0.0...2.0
    ]
    
    // MARK: - Equatable
    static func == (lhs: ImageAdjustment, rhs: ImageAdjustment) -> Bool {
        return lhs.brightness == rhs.brightness &&
               lhs.contrast == rhs.contrast &&
               lhs.saturation == rhs.saturation
    }
} 