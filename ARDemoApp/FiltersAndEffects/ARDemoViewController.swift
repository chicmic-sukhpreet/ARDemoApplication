//
//  MultipleFaceDetectionViewController.swift
//  ARDemoApp
//
//  Created by Chicmic on 24/08/23.
//

import UIKit
import ARKit
import RealityKit
import ReplayKit
import CoreImage
import YUCIHighPassSkinSmoothing
import AVFoundation
import SwiftConfettiView

enum ChoosedOption {
    case filters
    case effects
}
// swiftlint:disable line_length
// swiftlint:disable type_body_length
class ARDemoViewController: UIViewController {

    @IBOutlet var arView: ARView!
    @IBOutlet var captureButton: UIButton!
    @IBOutlet var collectionViewForFilters: UICollectionView!
    @IBOutlet weak var collectionViewForEffects: UICollectionView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet var filterImageView: UIImageView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var weekDayLabel: UILabel!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet weak var confettiView: SwiftConfettiView!
    let circularView = UIView()
    let coachingOverlayView = ARCoachingOverlayView()
    let recorder = RPScreenRecorder.shared()
    var currentConfiguration: ARConfiguration?
    var imageWithoutEffects: UIImage?
    var headPreview: RobotHead?
    var headPreview2: Entity?
    var effects: [CIFilter?] = [
        CIFilter(name: "CISepiaTone"),
        CIFilter(name: "CISepiaTone"),
        CIFilter(name: "CIPhotoEffectMono")
    ]
    var models: [ARModel] = [
        ARModel(modelName: "Glass",
                // swiftlint:disable force_try
                modelEntity: try! Entity.load(named: "Glass"),
                modelOffset: [0.0, 0.027, 0.054],
                modelScale: [0.01, 0.01, 0.01]),
        ARModel(modelName: "Mustache",
                modelEntity: try! Entity.load(named: "Mustache"),
                modelOffset: [0.0, -0.03, 0.064],
                modelScale: [0.0003, 0.0003, 0.0003]),
        ARModel(modelName: "PlagueMaster",
                modelEntity: try! Entity.load(named: "PlagueMaster"),
                modelOffset: [0.0, -0.01, 0.064],
                modelScale: [0.01, 0.01, 0.01]),
        ARModel(modelName: "VelvetHat",
                modelEntity: try! Entity.load(named: "VelvetHat"),
                modelOffset: [0.0, 0.07, -0.05],
                modelScale: [0.007, 0.007, 0.007]),
        ARModel(modelName: "Glass",
                modelEntity: try! Entity.load(named: "Glass"),
                modelOffset: [0.0, 0.027, 0.054],
                modelScale: [0.01, 0.01, 0.01]),
        ARModel(modelName: "Mustache",
                modelEntity: try! Entity.load(named: "Mustache"),
                modelOffset: [0.0, -0.03, 0.064],
                modelScale: [0.0003, 0.0003, 0.0003]),
        ARModel(modelName: "PlagueMaster",
                modelEntity: try! Entity.load(named: "PlagueMaster"),
                modelOffset: [0.0, -0.01, 0.064],
                modelScale: [0.01, 0.01, 0.01]),
        ARModel(modelName: "VelvetHat",
                modelEntity: try! Entity.load(named: "VelvetHat"),
                modelOffset: [0.0, 0.07, -0.05],
                modelScale: [0.007, 0.007, 0.007]),
        ARModel(modelName: "Glass",
                modelEntity: try! Entity.load(named: "Glass"),
                modelOffset: [0.0, 0.027, 0.054],
                modelScale: [0.01, 0.01, 0.01]),
        ARModel(modelName: "Mustache",
                modelEntity: try! Entity.load(named: "Mustache"),
                modelOffset: [0.0, -0.03, 0.064],
                modelScale: [0.0003, 0.0003, 0.0003]),
        ARModel(modelName: "PlagueMaster",
                modelEntity: try! Entity.load(named: "PlagueMaster"),
                modelOffset: [0.0, -0.01, 0.064],
                modelScale: [0.01, 0.01, 0.01]),
        ARModel(modelName: "VelvetHat",
                modelEntity: try! Entity.load(named: "VelvetHat"),
                modelOffset: [0.0, 0.07, -0.05],
                modelScale: [0.007, 0.007, 0.007])
    ]
    var animatedModelsForEye: [ARAnimatedModels<AnimationDemo.Animoji>] = [
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadAnimoji(), entityName: "Animoji"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadAnimoji(), entityName: "Animoji"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadAnimoji(), entityName: "Animoji")
    ]
    var animatedModelsForTongue: [ARAnimatedModels<AnimationDemo.CupcakeScene>] = [
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadCupcakeScene(), entityName: "cupcake"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadCupcakeScene(), entityName: "cupcake"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadCupcakeScene(), entityName: "cupcake")
    ]
    var animatedModelsForSmile: [ARAnimatedModels<AnimationDemo.SmileGlasses>] = [
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadSmileGlasses(), entityName: "glasses"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadSmileGlasses(), entityName: "glasses"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadSmileGlasses(), entityName: "glasses")
    ]
    var heartModels: [ARAnimatedModels<AnimationDemo.AnimeBlush>] = [
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadAnimeBlush(), entityName: "blush"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadAnimeBlush(), entityName: "blush"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadAnimeBlush(), entityName: "blush")
    ]
    var antModels: [ARAnimatedModels<AnimationDemo.AnimeEyes>] = [
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadAnimeEyes(), entityName: "eyes"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadAnimeEyes(), entityName: "eyes"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadAnimeEyes(), entityName: "eyes")
    ]
    var beardModels: [ARAnimatedModels<AnimationDemo.RedSharpLens>] = [
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadRedSharpLens(), entityName: "lens"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadRedSharpLens(), entityName: "lens"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadRedSharpLens(), entityName: "lens")
    ]
    var leftEyeBallEntity: Entity?
    var rightEyeBallEntity: Entity?
    var leftEyeBrowEntity: Entity?
    var rightEyeBrowEntity: Entity?
    var tongueEntity: Entity?
    var leftEyeLashEntity: Entity?
    var rightEyeLashEntity: Entity?
    var faceEntity: Entity?
    var tongueOriginalY: Float = 0
    var eyeBrowRightOriginalY: Float = 0
    var eyeBrowLeftOriginalY: Float = 0
    var eyeBrowRightOriginalZ: Float = 0
    var eyeBrowLeftOriginalZ: Float = 0
    var leftEyeBallOriginalZ: Float = 0
    var rightEyeBallOriginalZ: Float = 0
    var faceOriginalY: Float = 0
    var leftEyeLashOriginalOrientation: simd_quatf?
    var righEyeLashOriginalOrientation: simd_quatf?
    var selectedIndexForFilters = 0
    var selectedIndexPathForFilters: IndexPath?
    var selectedIndexForEffects = 0
    var selectedIndexPathForEffects: IndexPath?
    let maximumNumberOfFaceAnchors: Int = 3
    var option: ChoosedOption = .filters
    var isProcessingFrame: Bool = false
    var filterContext: CIContext?
    var imageView: UIImageView!
    let captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var cameraOutput: AVCaptureVideoDataOutput?
    var faceDetector: CIDetector?
    let context = CIContext(options: [CIContextOption.workingColorSpace: CGColorSpaceCreateDeviceRGB()])
    let skinSmoothingFilter = YUCIHighPassSkinSmoothing()
    var slider: UISlider! = UISlider()
    var filterTypeSelected: FilterType = .distortion
    var faceTrackingSupported: Bool = true
    var arViewRecorder: ARViewRecorder?
    let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
    private var isRecording = false
    private var videoRecorder: VideoRecorder?
    // swiftlint:enable force_try
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.session.delegate = self
        if !ARFaceTrackingConfiguration.isSupported || !ARWorldTrackingConfiguration.supportsUserFaceTracking {
            faceTrackingSupported = false
        }
        collectionViewForFilters.delegate = self
        collectionViewForFilters.dataSource = self
        collectionViewForEffects.delegate = self
        collectionViewForEffects.dataSource = self
        if option == .filters {
            collectionViewForEffects.isHidden = true
            collectionViewForFilters.isHidden = false
        } else {
            collectionViewForFilters.isHidden = true
            collectionViewForEffects.isHidden = false
        }
        filterImageView.sizeToFit()
        filterImageView.contentMode = .scaleAspectFill
        filterImageView.center = self.view.center
        circularView.backgroundColor = UIColor.white
        circularView.layer.cornerRadius = 39
        circularView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(circularView, belowSubview: captureButton)
        NSLayoutConstraint.activate([
            circularView.widthAnchor.constraint(equalToConstant: 78),
            circularView.heightAnchor.constraint(equalToConstant: 78),
            circularView.centerXAnchor.constraint(equalTo: captureButton.centerXAnchor),
            circularView.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor)
        ])
        guard faceTrackingSupported else {
            segmentedControl.selectedSegmentIndex = 1
            option = .effects
            collectionViewForFilters.isHidden = true
            collectionViewForEffects.isHidden = false
            return
        }
        arViewRecorder = ARViewRecorder()
        setupCoachingOverlay()
        setupAnimoji()
        resetDayAndTimeLabels()
        setupConfetti()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectedIndexForFilters < 12 {
            arView.scene.anchors.removeAll()
            guard selectedIndexForFilters != 6 else {
                setupCombinedTracking()
                return
            }
            headPreview = nil
            let configuration = ARFaceTrackingConfiguration()
            configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
            arView.session.run(configuration)
            resetDayAndTimeLabels()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    func setupConfetti() {
        confettiView.type = .diamond
        confettiView.colors = [UIColor.red, UIColor.green, UIColor.blue]
        confettiView.intensity = 0.75
    }
    func setupDayAndTimeLabels() {
        let data = getDataOfCurrentDay()
        self.weekDayLabel.text = data.day
        self.currentTimeLabel.text = data.time
    }
    func resetDayAndTimeLabels() {
        if selectedIndexForFilters == 11 && option == .filters {
            weekDayLabel.isHidden = false
            currentTimeLabel.isHidden = false
            setupDayAndTimeLabels()
        } else {
            weekDayLabel.isHidden = true
            currentTimeLabel.isHidden = true
        }
    }
    func setupAnimoji() {
        leftEyeBallEntity = animatedModelsForEye[0].animatedAnchor.findEntity(named: "eyeballright")
        rightEyeBallEntity = animatedModelsForEye[0].animatedAnchor.findEntity(named: "eyeballleft")
        leftEyeBrowEntity = animatedModelsForEye[0].animatedAnchor.findEntity(named: "eyebrowLeft")
        rightEyeBrowEntity = animatedModelsForEye[0].animatedAnchor.findEntity(named: "eyebrowRight")
        tongueEntity = animatedModelsForEye[0].animatedAnchor.findEntity(named: "tongue")
        leftEyeLashEntity = animatedModelsForEye[0].animatedAnchor.findEntity(named: "leftEyeLash")
        rightEyeLashEntity = animatedModelsForEye[0].animatedAnchor.findEntity(named: "rightEyeLash")
        faceEntity = animatedModelsForEye[0].animatedAnchor.findEntity(named: "face")
        faceOriginalY = faceEntity!.position.y
        tongueOriginalY = tongueEntity!.position.y
        eyeBrowLeftOriginalY = leftEyeBrowEntity!.position.y
        eyeBrowRightOriginalY = rightEyeBrowEntity!.position.y
        eyeBrowLeftOriginalZ = leftEyeBrowEntity!.position.z
        eyeBrowRightOriginalZ = rightEyeBrowEntity!.position.z
        leftEyeBallOriginalZ = leftEyeBallEntity!.position.z
        rightEyeBallOriginalZ = rightEyeBallEntity!.position.z
        leftEyeLashOriginalOrientation = leftEyeLashEntity?.orientation
        righEyeLashOriginalOrientation = rightEyeLashEntity?.orientation
    }
    func setupFaceTracking() {
        arView.scene.anchors.removeAll()
        let configuration = ARFaceTrackingConfiguration()
        currentConfiguration = configuration
        configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
        arView.session.run(configuration)
    }
    func setupCombinedTracking() {
        arView.scene.anchors.removeAll()
        let configuration = ARWorldTrackingConfiguration()
        currentConfiguration = configuration
        arView.automaticallyConfigureSession = false
        arView.renderOptions.insert(.disableMotionBlur)
        configuration.environmentTexturing = .automatic
        configuration.userFaceTrackingEnabled = true
        UIApplication.shared.isIdleTimerDisabled = true
        arView.session.run(configuration)
    }
    @IBAction func captureButtonClicked(_ sender: UIButton) {
        captureScreenshot()
        // captureVideoRecording()
    }
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // This is called when we click on the filter(AR) side
            if faceTrackingSupported {
                if selectedIndexForFilters >= 12 {
                    if cameraOutput == nil {
                        setupDistortionAndBeautyFilters()
                    }
                    filterTypeSelected = selectedIndexForFilters == 12 ? .distortion : .beauty
                    slider.isHidden = selectedIndexForFilters != 13
                }
                collectionViewForFilters.isHidden = false
                collectionViewForEffects.isHidden = true
                filterImageView.isHidden = true
                label.isHidden = false
                option = .filters
                resetDayAndTimeLabels()
            } else {
                showAlertForFaceTracking()
            }
        case 1: // This is called when we click on the effect side
            if selectedIndexForFilters >= 12 {
                removeImageViewForDistortionAndBeauty()
            }
            slider.isHidden = true
            collectionViewForFilters.isHidden = true
            collectionViewForEffects.isHidden = false
            filterImageView.isHidden = false
            label.isHidden = true
            weekDayLabel.isHidden = true
            currentTimeLabel.isHidden = true
            option = .effects
        default:
            break
        }
    }
    func showAlertForFaceTracking() {
        let alert = UIAlertController(title: "Not Supported",
                                      message: "This device doesn't support this feature.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) {[weak self] _ in
            self?.segmentedControl.selectedSegmentIndex = 1
            self?.option = .effects
        })
        present(alert, animated: true, completion: nil)
    }
    func captureScreenshot() {
        captureButton.isHidden = true
        collectionViewForFilters.isHidden = true
        collectionViewForEffects.isHidden = true
        label.isHidden = true
        segmentedControl.isHidden = true
        circularView.isHidden = true
        slider.isHidden = true
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let screenshot = renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        let previewVC = self.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as? PreviewViewController
        previewVC?.delegate = self
        previewVC?.capturedImage = screenshot
        if option == .filters {
            previewVC?.originalImageWithoutEffects = screenshot
        } else {
            previewVC?.originalImageWithoutEffects = imageWithoutEffects?.rotate(radians: .pi * 2)
        }
        previewVC?.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(previewVC!, animated: true)
        if option == .filters {
            collectionViewForFilters.isHidden = false
        } else {
            collectionViewForEffects.isHidden = false
        }
        captureButton.isHidden = false
        label.isHidden = false
        segmentedControl.isHidden = false
        circularView.isHidden = false
        slider.isHidden = selectedIndexForFilters != 13
    }
    func captureVideo() {
        if !isRecording {
            videoRecorder = VideoRecorder()
            if let fileURL = videoRecorder?.createTempFileURL() {
                videoRecorder?.startRecording(view: imageView, to: fileURL)
                circularView.backgroundColor = .red
            }
        } else {
            videoRecorder?.stopRecording { [weak self] videoURL in
                if let url = videoURL {
                    self?.videoRecorder?.saveVideoToPhotos(url)
                }
                self?.videoRecorder = nil
            }
            circularView.backgroundColor = .white
        }
        isRecording.toggle()
    }
    func updateHeadPreviewAppearance(for frame: ARFrame) {
        guard let robotHeadPreview = headPreview else { return }
        if robotHeadPreview.isTooCloseToAnchoredHeads(in: arView.scene) {
            robotHeadPreview.appearance = .intersecting
            return
        }
        let faceAnchors = frame.anchors.compactMap { $0 as? ARFaceAnchor }
        if faceAnchors.first(where: { $0.isTracked }) != nil {
            robotHeadPreview.appearance = .tracked
        } else {
            robotHeadPreview.appearance = .notTracked
        }
    }
    func addHeadPreview() {
        let camera = AnchorEntity(.camera)
        let robotHead = RobotHead()
        arView.scene.addAnchor(camera)
        camera.addChild(robotHead)
        robotHead.position.z = 1.0
        headPreview = robotHead
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable line_length
