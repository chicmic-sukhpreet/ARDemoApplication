//
//  CIFiltersViewController.swift
//  ARDemoApp
//
//  Created by Chicmic on 23/10/23.
//

import UIKit
import CoreImage
import AVFoundation
import Vision
import MetalKit
import Photos
// swiftlint:disable multiple_closures_with_trailing_closure
// swiftlint:disable line_length
class ImageProcessor {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var ciContext: CIContext!
    init?() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else { return nil }
        self.device = device
        self.commandQueue = commandQueue
        self.ciContext = CIContext(mtlDevice: device)
    }
}

class CIFiltersViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var imageView: UIImageView!
    let captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var cameraOutput: AVCaptureVideoDataOutput?
    var faceDetector: CIDetector?
    var imageProcessor: ImageProcessor?
    private var captureButton: UIButton!
    private var isRecording = false
    private var videoRecorder: VideoRecorder?
    override func viewDidLoad() {
        super.viewDidLoad()
        imageProcessor = ImageProcessor()
        setupCamera()
        setupImageView()
        setupFaceDetector()
        setupCaptureButton()
    }
    func getOrientationFromDeviceOrientation() -> Int32 {
        switch UIDevice.current.orientation {
        case .portrait, .faceUp: return 6
        case .portraitUpsideDown, .faceDown: return 8
        case .landscapeLeft: return 3
        case .landscapeRight: return 1
        default: return 6
        }
    }
    func setupFaceDetector() {
        let orientation = getOrientationFromDeviceOrientation()
        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorImageOrientation: orientation]
        faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)
    }
    func applyFilterToFace(in image: CIImage) -> CIImage? {
        guard let faceDetector = faceDetector, imageProcessor != nil else { return nil }
        let faces = faceDetector.features(in: image)
        var outputImage = image
        for face in faces {
            guard let face = face as? CIFaceFeature else {continue}
            outputImage = applyDistortionFilter(to: outputImage, for: face.bounds)
        }
       // outputImage = applyExposureAdjust(to: outputImage, exposureValue: 1.0)
       // outputImage = applyVibrance(to: outputImage, exposureValue: 1.0)
        return outputImage
    }
    func applyExposureAdjust(to image: CIImage, exposureValue: CGFloat) -> CIImage {
        guard let filter = CIFilter(name: "CIExposureAdjust") else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(exposureValue, forKey: kCIInputEVKey)
        return filter.outputImage ?? image
    }
    func applyVibrance(to image: CIImage, vibranceValue: CGFloat) -> CIImage {
        guard let filter = CIFilter(name: "CIVibrance") else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(vibranceValue, forKey: "inputAmount")
        return filter.outputImage ?? image
    }
    func applyDistortionFilter(to image: CIImage, for rect: CGRect) -> CIImage {
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
            if let cgImage = imageProcessor?.ciContext.createCGImage(flippedImage, from: flippedImage.extent) {
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
    private func setupImageView() {
        imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
    }
    private func setupCamera() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                      mediaType: .video,
                                                                      position: .front)
        guard let device = deviceDiscoverySession.devices.first else {
            print("Failed to get the front camera device")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(input)
            cameraOutput = AVCaptureVideoDataOutput()
            cameraOutput!.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
            cameraOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            captureSession.addOutput(cameraOutput!)
            DispatchQueue.global(qos: .default).async { [weak self] in
                self?.captureSession.startRunning()
            }
        } catch {
            print(error)
            return
        }
    }
    private func setupCaptureButton() {
        captureButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        captureButton.backgroundColor = .white
        captureButton.layer.cornerRadius = 40
        captureButton.layer.masksToBounds = true
        captureButton.addTarget(self, action: #selector(captureButtonClicked), for: .touchUpInside)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureButton)
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            captureButton.widthAnchor.constraint(equalToConstant: 80),
            captureButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}

extension CIFiltersViewController: PreviewViewControllerDelegate {
    func previewViewControllerDidSaveImage(_ viewController: PreviewViewController) {
        if let image = viewController.previewImage.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        viewController.showSaveAlert()
        self.navigationController?.popViewController(animated: true)
    }
    func previewViewControllerDidDiscardImage(_ viewController: PreviewViewController) {
        viewController.showActionSheet()
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved successfully")
        }
    }
    @objc func captureButtonClicked() {
//        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
//        self.captureButton.isHidden = true
//        let screenshot = renderer.image { _ in
//            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
//        }
//        let previewVC = self.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as? PreviewViewController
//        previewVC?.delegate = self
//        previewVC?.capturedImage = screenshot
//        previewVC?.originalImageWithoutEffects = screenshot
//        previewVC?.modalPresentationStyle = .overFullScreen
//        self.present(previewVC!, animated: true)
//        self.captureButton.isHidden = false
        if !isRecording {
            videoRecorder = VideoRecorder()
            if let fileURL = videoRecorder?.createTempFileURL() {
                videoRecorder?.startRecording(view: imageView, to: fileURL)
                captureButton.backgroundColor = .red
            }
        } else {
            videoRecorder?.stopRecording { [weak self] videoURL in
                if let url = videoURL {
                    self?.videoRecorder?.saveVideoToPhotos(url)
                }
                self?.videoRecorder = nil
            }
            captureButton.backgroundColor = .white
        }
        isRecording.toggle()
    }
}
// swiftlint:enable line_length
// swiftlint:enable multiple_closures_with_trailing_closure
