import CoreImage
import UIKit

struct ImageAdjustment {
    var brightness: Double
    var contrast: Double
    
    func apply(to image: UIImage) -> UIImage? {
        guard let inputImage = CIImage(image: image) else { return nil }
        let context = CIContext()
        
        // Create color controls filter
        guard let colorControls = CIFilter(name: "CIColorControls") else { return nil }
        colorControls.setValue(inputImage, forKey: kCIInputImageKey)
        colorControls.setValue(brightness, forKey: kCIInputBrightnessKey)
        colorControls.setValue(contrast, forKey: kCIInputContrastKey)
        
        guard let outputImage = colorControls.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        else {
            return nil
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
            lhs.contrast == rhs.contrast
    }
}
