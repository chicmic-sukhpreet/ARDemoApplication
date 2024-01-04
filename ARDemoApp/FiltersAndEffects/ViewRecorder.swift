//
//  ViewRecorder.swift
//  ARDemoApp
//
//  Created by Chicmic on 28/12/23.
//

import Foundation
import AVFoundation
import UIKit
import Photos
// swiftlint:disable multiple_closures_with_trailing_closure
// swiftlint:disable line_length
class VideoRecorder {
    var assetWriter: AVAssetWriter?
    var assetWriterInput: AVAssetWriterInput?
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    var displayLink: CADisplayLink?
    var startTime: CFAbsoluteTime?
    var isRecording = false
    weak var viewToRecord: UIView?
    func startRecording(view: UIView, to outputFileURL: URL) {
        self.viewToRecord = view
        guard !isRecording else { return }
        do {
            try setupAssetWriter(view: view, outputFileURL: outputFileURL)
            startDisplayLink(for: view)
            isRecording = true
        } catch {
            print("Error setting up video writer: \(error)")
        }
    }
    private func setupAssetWriter(view: UIView, outputFileURL: URL) throws {
        let outputSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: view.bounds.width,
            AVVideoHeightKey: view.bounds.height
        ]
        assetWriter = try AVAssetWriter(outputURL: outputFileURL, fileType: .mp4)
        assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
        assetWriterInput?.expectsMediaDataInRealTime = true
        if assetWriter!.canAdd(assetWriterInput!) {
            assetWriter!.add(assetWriterInput!)
        } else {
            throw NSError(domain: "VideoRecorder", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot add input"])
        }
        let sourcePixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB
        ]
        pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput!,
                                                                  sourcePixelBufferAttributes: sourcePixelBufferAttributes)
        assetWriter!.startWriting()
        assetWriter!.startSession(atSourceTime: .zero)
    }
    private func startDisplayLink(for view: UIView) {
        displayLink = CADisplayLink(target: self, selector: #selector(captureFrame(_:)))
        displayLink?.add(to: .main, forMode: .common)
        startTime = CFAbsoluteTimeGetCurrent()
    }
    @objc private func captureFrame(_ displayLink: CADisplayLink) {
        guard let assetWriterInput = assetWriterInput,
                assetWriterInput.isReadyForMoreMediaData,
                let startTime = startTime else { return }
        let currentTime = CFAbsoluteTimeGetCurrent() - startTime
        let frameTime = CMTime(seconds: currentTime, preferredTimescale: 600)
        guard let pixelBuffer = pixelBuffer(from: viewToRecord!) else { return }
        pixelBufferAdaptor?.append(pixelBuffer, withPresentationTime: frameTime)
    }
    private func pixelBuffer(from view: UIView) -> CVPixelBuffer? {
        let size = view.bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(size.width),
                                         Int(size.height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)

        guard status == kCVReturnSuccess, let unwrappedPixelBuffer = pixelBuffer else { return nil }
        CVPixelBufferLockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(unwrappedPixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let quartzContext = CGContext(data: pixelData,
                                            width: Int(size.width),
                                            height: Int(size.height),
                                            bitsPerComponent: 8,
                                            bytesPerRow: CVPixelBufferGetBytesPerRow(unwrappedPixelBuffer),
                                            space: rgbColorSpace,
                                            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) else {
                                                return nil
                                            }

        quartzContext.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        CVPixelBufferUnlockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return unwrappedPixelBuffer
    }
    func stopRecording(completion: @escaping (URL?) -> Void) {
        guard isRecording else {
            completion(nil)
            return
        }
        displayLink?.invalidate()
        displayLink = nil
        assetWriterInput?.markAsFinished()
        assetWriter?.finishWriting { [weak self] in
            let outputURL = self?.assetWriter?.outputURL
            self?.reset()
            completion(outputURL)
        }
    }
    private func reset() {
        assetWriter = nil
        assetWriterInput = nil
        pixelBufferAdaptor = nil
        startTime = nil
        isRecording = false
    }
    func createTempFileURL() -> URL? {
        let tempDirectory = NSTemporaryDirectory()
        let fileName = "temp_video_\(UUID().uuidString).mp4"
        let fileURL = URL(fileURLWithPath: tempDirectory).appendingPathComponent(fileName)
        return fileURL
    }
    func saveVideoToPhotos(_ videoURL: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                }) { saved, error in
                    if saved {
                        print("Video saved successfully")
                    } else {
                        print("Error saving video: \(String(describing: error))")
                    }
                }
            } else {
                print("Photos library access denied")
            }
        }
    }
}
// swiftlint:enable line_length
// swiftlint:enable multiple_closures_with_trailing_closure
