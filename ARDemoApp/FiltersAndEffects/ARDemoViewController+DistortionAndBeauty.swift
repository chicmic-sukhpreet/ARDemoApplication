//
//  ARDemoViewController+DistortionAndBeauty.swift
//  ARDemoApp
//
//  Created by Chicmic on 04/01/24.
//

import Foundation
import UIKit
import ARKit
import RealityKit
import ReplayKit
import CoreImage
import YUCIHighPassSkinSmoothing
import AVFoundation
// swiftlint:disable force_cast
extension ARDemoViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func setupDistortionAndBeautyFilters() {
        DispatchQueue.main.async { [weak self] in
            self?.showLoader()
        }
        setupCamera()
        setupImageView()
        setupFaceDetector()
        setupSlider()
        view.bringSubviewToFront(collectionViewForFilters)
        view.bringSubviewToFront(collectionViewForEffects)
        view.bringSubviewToFront(segmentedControl)
        view.bringSubviewToFront(circularView)
        view.bringSubviewToFront(captureButton)
    }
    func removeImageViewForDistortionAndBeauty() {
        DispatchQueue.main.async { [weak self] in
            self?.showLoader()
        }
        captureSession.stopRunning()
        captureSession.inputs.forEach { captureSession.removeInput($0) }
        captureSession.outputs.forEach { captureSession.removeOutput($0) }
        imageView.removeFromSuperview()
        cameraOutput = nil
        DispatchQueue.main.async { [weak self] in
            self?.hideLoader()
        }
    }
    func setupSlider() {
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.7
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(slider)
        NSLayoutConstraint.activate([
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            slider.bottomAnchor.constraint(equalTo: segmentedControl.topAnchor, constant: -20)
        ])
    }
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let newValue = sender.value
        skinSmoothingFilter.inputAmount = NSNumber(value: newValue)
    }
    func setupFaceDetector() {
        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)
    }
    func applyFilterToFace(in image: CIImage) -> CIImage? {
        guard let faceDetector = faceDetector else { return nil }
        let faces = faceDetector.features(in: image)
        var outputImage = image
        if filterTypeSelected == .distortion {
            for face in faces {
                guard let face = face as? CIFaceFeature else {continue}
                outputImage = applyFaceDistortionFilter(to: outputImage, for: face.bounds)
            }
        } else {
            outputImage = applySkinWhiteningFilter(to: outputImage)
        }
        return outputImage
    }
    func applySkinWhiteningFilter(to image: CIImage) -> CIImage {
        skinSmoothingFilter.inputImage = image
        skinSmoothingFilter.inputRadius =
        (skinSmoothingFilter.inputAmount as! CGFloat * 10.0) * image.extent.width / 750.0 as NSNumber
        return skinSmoothingFilter.outputImage ?? image
    }
    func applyFaceDistortionFilter(to image: CIImage, for rect: CGRect) -> CIImage {
        let filter = CIFilter(name: "CIBumpDistortion")
        filter?.setValue(image, forKey: kCIInputImageKey)
        filter?.setValue(CIVector(x: rect.midX, y: rect.midY), forKey: kCIInputCenterKey)
        filter?.setValue(rect.width - 200, forKey: kCIInputRadiusKey)
        filter?.setValue(0.5, forKey: kCIInputScaleKey)
        return filter?.outputImage ?? image
    }
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer)
        if let filteredImage = applyFilterToFace(in: cameraImage) {
            let flippedImage = flipImageHorizontally(image: filteredImage)
            if let cgImage = self.context.createCGImage(flippedImage, from: flippedImage.extent) {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
                }
            }
        }
    }
    func flipImageHorizontally(image: CIImage) -> CIImage {
        let flippedImage = image.transformed(by: CGAffineTransform(scaleX: 1, y: -1))
        return flippedImage
    }
    func setupImageView() {
        imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
    }
    func setupCamera() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                      mediaType: .video,
                                                                      position: .front)
        guard let device = deviceDiscoverySession.devices.first else {
            print("Failed to get the front camera device")
            hideLoader()
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if captureSession.inputs.isEmpty {
                self.captureSession.addInput(input)
            }
            cameraOutput = AVCaptureVideoDataOutput()
            cameraOutput!.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue", qos: .userInitiated))
            cameraOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            captureSession.addOutput(cameraOutput!)
            DispatchQueue.global(qos: .default).async { [weak self] in
                self?.captureSession.startRunning()
                DispatchQueue.main.async {
                    self?.hideLoader()
                }
            }
        } catch {
            print(error)
            hideLoader()
            return
        }
    }
}
// swiftlint:enable force_cast
