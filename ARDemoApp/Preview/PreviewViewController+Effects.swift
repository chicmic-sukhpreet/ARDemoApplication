//
//  PreviewViewController+Effects.swift
//  ARDemoApp
//
//  Created by Chicmic on 06/09/23.
//

import Foundation
import UIKit
import CoreImage

extension PreviewViewController {
    func sepiaFilter(_ input: CIImage, intensity: Double) -> CGImage? {
        let sepiaFilter = CIFilter(name: "CISepiaTone")
        sepiaFilter?.setValue(input, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(intensity, forKey: kCIInputIntensityKey)
        let context = CIContext()
        let cgimg = context.createCGImage(sepiaFilter!.outputImage!, from: sepiaFilter!.outputImage!.extent)
        return cgimg
    }
    func monoFilter(_ input: CIImage) -> CGImage? {
        let monoFilter = CIFilter(name: "CIPhotoEffectMono")
        monoFilter?.setValue(input, forKey: kCIInputImageKey)
        let context = CIContext()
        let cgimg = context.createCGImage(monoFilter!.outputImage!, from: monoFilter!.outputImage!.extent)
        return cgimg
    }
    func applyContrastEffect(to inputImage: UIImage, contrast: CGFloat) -> UIImage? { // circle.lefthalf.filled
        guard let ciImage = CIImage(image: inputImage) else { return nil }
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(contrast, forKey: kCIInputContrastKey)
        guard let outputCIImage = filter?.outputImage else { return nil }
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    func applyBrightnessEffect(to inputImage: UIImage, brightness: CGFloat) -> UIImage? { // microbe.circle
        guard let ciImage = CIImage(image: inputImage) else { return nil }
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(brightness, forKey: kCIInputBrightnessKey)
        guard let outputCIImage = filter?.outputImage else { return nil }
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    func applySaturationEffect(to inputImage: UIImage, saturation: CGFloat) -> UIImage? { // thermometer.medium
        guard let ciImage = CIImage(image: inputImage) else { return nil }
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(saturation, forKey: kCIInputSaturationKey)
        guard let outputCIImage = filter?.outputImage else { return nil }
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .size

        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        context.rotate(by: radians)

        self.draw(in: CGRect(x: -self.size.width / 2,
                             y: -self.size.height / 2,
                             width: self.size.width,
                             height: self.size.height))

        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return rotatedImage
    }
}
