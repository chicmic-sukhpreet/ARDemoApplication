//
//  CIFiltersViewController.swift
//  ARDemoApp
//
//  Created by Chicmic on 23/10/23.
//

import UIKit
import CoreImage

class CIFiltersViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load an initial image into the imageView
        imageView.image = UIImage(named: "face")
    }
    @IBAction func applyBumpDistortion(_ sender: UIButton) {
        // Check if the imageView has an image
        guard let image = imageView.image else {
            return
        }
        // Create a CIImage from the UIImage
        guard let ciImage = CIImage(image: image) else {
            return
        }
        // Create a Core Image context
        let context = CIContext(options: nil)
        // Create a face detector
        let detector = CIDetector(ofType: CIDetectorTypeFace,
                                  context: context,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        // Get an array of detected face features
        if let features = detector?.features(in: ciImage) as? [CIFaceFeature] {
            for face in features {
                var filteredImage = ciImage
                // Apply the Bump Distortion filter to the face
                if let bumpDistortion = CIFilter(name: "CIBumpDistortion") {
                    bumpDistortion.setValue(filteredImage, forKey: kCIInputImageKey)
                    bumpDistortion.setValue(CIVector(x: face.bounds.midX, y: face.bounds.midY),
                                            forKey: kCIInputCenterKey)
                    bumpDistortion.setValue(2000.0, forKey: kCIInputRadiusKey)
                    bumpDistortion.setValue(1.0, forKey: kCIInputScaleKey)
                    if let distortedImage = bumpDistortion.outputImage {
                        filteredImage = distortedImage
                    }
                }
                // Render the filtered image
                if let outputCGImage = context.createCGImage(filteredImage, from: filteredImage.extent) {
                    let resultImage = UIImage(cgImage: outputCGImage)
                    imageView.image = resultImage
                }
            }
        }
    }
}
