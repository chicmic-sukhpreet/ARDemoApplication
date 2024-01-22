//
//  ARViewRecorder.swift
//  ARDemoApp
//
//  Created by Chicmic on 05/01/24.
//

import ARKit
import AVFoundation
import RealityKit
import Photos
// swiftlint:disable force_cast
class ARViewRecorder: NSObject, ARSessionDelegate {
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    var isRecording = false
    private var outputURL: URL?
    // Function to start recording
    func startRecording(to outputFileURL: URL, from arView: ARView) {
        guard !isRecording else { return }
        self.outputURL = outputFileURL
        let outputSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: NSNumber(value: Float(arView.bounds.width)),
            AVVideoHeightKey: NSNumber(value: Float(arView.bounds.height))
        ]
        do {
            assetWriter = try AVAssetWriter(outputURL: outputFileURL, fileType: .mp4)
            assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
            assetWriterInput?.expectsMediaDataInRealTime = true
            if assetWriter!.canAdd(assetWriterInput!) {
                assetWriter!.add(assetWriterInput!)
            } else {
                throw NSError(domain: "ARViewRecorder",
                              code: 0,
                              userInfo: [NSLocalizedDescriptionKey: "Cannot add input"])
            }
            assetWriter!.startWriting()
            assetWriter!.startSession(atSourceTime: .zero)
            isRecording = true
        } catch {
            print("Error setting up video writer: \(error)")
        }
    }
    // Function to stop recording
    func stopRecording(completion: @escaping (URL?) -> Void) {
        guard isRecording else {
            completion(nil)
            return
        }
        assetWriterInput?.markAsFinished()
        assetWriter?.finishWriting { [weak self] in
            self?.isRecording = false
            let outputURL = self?.assetWriter?.outputURL
            completion(outputURL)
        }
    }
    // ARSessionDelegate method to capture each frame
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard isRecording,
              let assetWriterInput = assetWriterInput,
              assetWriterInput.isReadyForMoreMediaData else { return }

        let pixelBuffer = frame.capturedImage
        let frameTime = CMTime(seconds: frame.timestamp, preferredTimescale: 600)

        // Create a CMVideoFormatDescription from the pixel buffer
        var formatDescription: CMFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                     imageBuffer: pixelBuffer,
                                                     formatDescriptionOut: &formatDescription)

        // Ensure formatDescription is created
        guard let formatDesc = formatDescription else {
            print("Error creating format description")
            return
        }

        // Create a CMSampleBuffer from the pixel buffer
        var sampleBuffer: CMSampleBuffer?
        var timingInfo = CMSampleTimingInfo(duration: CMTime.invalid,
                                            presentationTimeStamp: frameTime,
                                            decodeTimeStamp: CMTime.invalid)
        let status = CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                        imageBuffer: pixelBuffer,
                                                        dataReady: true,
                                                        makeDataReadyCallback: nil,
                                                        refcon: nil,
                                                        formatDescription: formatDesc,
                                                        sampleTiming: &timingInfo,
                                                        sampleBufferOut: &sampleBuffer)

        if status == noErr, let sampleBuffer = sampleBuffer {
            // Append the sample buffer if possible
            if assetWriterInput.isReadyForMoreMediaData {
                assetWriterInput.append(sampleBuffer)
            }
        } else {
            print("Error creating sample buffer")
        }
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
// swiftlint:enable force_cast
