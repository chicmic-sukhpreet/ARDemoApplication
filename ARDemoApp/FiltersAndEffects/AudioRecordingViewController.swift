//
//  AudioRecordingViewController.swift
//  ARDemoApp
//
//  Created by Chicmic on 23/01/24.
//

import UIKit
import AVFoundation
import AVKit
// swiftlint:disable force_try
class AudioRecordingViewController2: UIViewController, AVAudioRecorderDelegate {
    var audioRecorder: AVAudioRecorder?
    var audioPlayerNode: AVAudioPlayerNode?
    var audioEngine: AVAudioEngine?
    var audioFile: AVAudioFile?
    let recordButton = UIButton()
    let playButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudioRecorder()
    }
    func setupUI() {
        // Record Button
        recordButton.setTitle("Record", for: .normal)
        recordButton.setTitleColor(.blue, for: .normal)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recordButton)
        // Play Button
        playButton.setTitle("Play Childish Voice", for: .normal)
        playButton.setTitleColor(.green, for: .normal)
        playButton.addTarget(self, action: #selector(extractAudioAndExport), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playButton)
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 20)
        ])
    }
    func setupAudioRecorder() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
        } catch {
            print("Failed to set up the audio recorder.")
        }
    }
    @objc func recordTapped() {
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
            recordButton.setTitle("Record", for: .normal)
        } else {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                audioRecorder?.record()
                recordButton.setTitle("Stop", for: .normal)
            } catch {
                print("Failed to start recording.")
            }
        }
    }
    @objc func playTapped() {
        if audioEngine == nil {
            setupAndStartAudioEngine()
        } else {
            audioPlayerNode?.stop()
            audioEngine?.stop()
            audioEngine?.reset()
            setupAndStartAudioEngine()
        }
    }
    func setupAndStartAudioEngine() {
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        let timePitch = AVAudioUnitTimePitch()
        timePitch.pitch = 1200
        guard let audioEngine = audioEngine, let audioPlayerNode = audioPlayerNode else { return }
        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(timePitch)
        audioEngine.connect(audioPlayerNode, to: timePitch, format: nil)
        audioEngine.connect(timePitch, to: audioEngine.outputNode, format: nil)
        do {
            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
            audioFile = try AVAudioFile(forReading: audioFilename)
            try audioEngine.start()
            audioPlayerNode.scheduleFile(audioFile!, at: nil)
            audioPlayerNode.play()
        } catch {
            print("Could not play the audio file.")
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    @objc func extractAudioAndExport() {
        // Create a composition
        let composition = AVMutableComposition()
        do {
            let sourceUrl = Bundle.main.url(forResource: "Movie", withExtension: "mov")!
            let asset = AVURLAsset(url: sourceUrl)
            guard let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else { return }
            guard let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                          preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
            try audioCompositionTrack.insertTimeRange(audioAssetTrack.timeRange, of: audioAssetTrack, at: CMTime.zero)
        } catch {
            print(error)
        }

        // Get url for output
        let outputUrl = URL(fileURLWithPath: NSTemporaryDirectory() + "out.m4a")
        if FileManager.default.fileExists(atPath: outputUrl.path) {
            try? FileManager.default.removeItem(atPath: outputUrl.path)
        }

        // Create an export session
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)!
        exportSession.outputFileType = AVFileType.m4a
        exportSession.outputURL = outputUrl

        // Export file
        exportSession.exportAsynchronously {
            guard case exportSession.status = AVAssetExportSession.Status.completed else { return }

            DispatchQueue.main.async {
                // Present a UIActivityViewController to share audio file
                guard let outputURL = exportSession.outputURL else { return }
                let activityViewController = UIActivityViewController(activityItems: [outputURL],
                                                                      applicationActivities: [])
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
}

class AudioRecordingViewController: UIViewController {

    var captureSession: AVCaptureSession?
    var videoOutput: AVCaptureMovieFileOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var recordButton: UIButton!
    var playButton: UIButton!
    var outputFileURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }

    func setupCamera() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }

        // Setup for video input
        if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
           let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
           captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        // Setup for audio input
        if let audioDevice = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
           captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        }

        // Setup for video output
        videoOutput = AVCaptureMovieFileOutput()
        if let videoOutput = videoOutput, captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        // Setup preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }

        captureSession.startRunning()
    }
    func setupUI() {
        // Record button
        recordButton = UIButton(frame: CGRect(x: 20, y: view.bounds.height - 70, width: 120, height: 50))
        recordButton.backgroundColor = .red
        recordButton.setTitle("Record", for: .normal)
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        view.addSubview(recordButton)

        // Play button
        playButton = UIButton(frame: CGRect(x: view.bounds.width - 140,
                                            y: view.bounds.height - 70,
                                            width: 120, height: 50))
        playButton.backgroundColor = .blue
        playButton.setTitle("Play", for: .normal)
        playButton.addTarget(self, action: #selector(extractAudioAndExport), for: .touchUpInside)
        view.addSubview(playButton)
    }
    @objc func recordButtonTapped() {
        guard let videoOutput = videoOutput else { return }

        if videoOutput.isRecording {
            videoOutput.stopRecording()
            recordButton.setTitle("Record", for: .normal)
        } else {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let outputPath = "\(documentsPath)/output.mov"
            outputFileURL = URL(fileURLWithPath: outputPath)
            videoOutput.startRecording(to: outputFileURL!, recordingDelegate: self)
            recordButton.setTitle("Stop", for: .normal)
        }
    }
    @objc func playButtonTapped() {
        guard let outputFileURL = outputFileURL else { return }
        let player = AVPlayer(url: outputFileURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    @objc func extractAudioAndExport() {
        // Create a composition
        let composition = AVMutableComposition()
        do {
            guard let outputFileURL = outputFileURL else { return }
            let asset = AVURLAsset(url: outputFileURL)
            guard let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else { return }
            guard let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                          preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
            try audioCompositionTrack.insertTimeRange(audioAssetTrack.timeRange, of: audioAssetTrack, at: CMTime.zero)
        } catch {
            print(error)
        }

        // Get url for output
        let outputUrl = URL(fileURLWithPath: NSTemporaryDirectory() + "out.m4a")
        if FileManager.default.fileExists(atPath: outputUrl.path) {
            try? FileManager.default.removeItem(atPath: outputUrl.path)
        }

        // Create an export session
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)!
        exportSession.outputFileType = AVFileType.m4a
        exportSession.outputURL = outputUrl

        // Export file
        exportSession.exportAsynchronously {
            guard case exportSession.status = AVAssetExportSession.Status.completed else { return }

            DispatchQueue.main.async {
                // Present a UIActivityViewController to share audio file
                guard let outputURL = exportSession.outputURL else { return }
                let activityViewController = UIActivityViewController(activityItems: [outputURL],
                                                                      applicationActivities: [])
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
}

extension AudioRecordingViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        if let error = error {
            // Handle recording error
            print("Recording error: \(error.localizedDescription)")
        } else {
            // Recording completed successfully
            print("Recording completed: \(outputFileURL.absoluteString)")
        }
    }
}
// swiftlint:enable force_try
