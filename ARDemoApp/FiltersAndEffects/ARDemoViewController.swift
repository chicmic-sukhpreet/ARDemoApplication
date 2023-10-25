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
    var heartModels: [ARAnimatedModels<AnimationDemo.HeartScene>] = [
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadHeartScene(), entityName: "heart"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadHeartScene(), entityName: "heart"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadHeartScene(), entityName: "heart")
    ]
    var antModels: [ARAnimatedModels<AnimationDemo.AntScene>] = [
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadAntScene(), entityName: "ant"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadAntScene(), entityName: "ant"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadAntScene(), entityName: "ant")
    ]
    var beardModels: [ARAnimatedModels<AnimationDemo.BeardScene>] = [
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadBeardScene(), entityName: "beard"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadBeardScene(), entityName: "beard"),
        ARAnimatedModels(animatedAnchor: try! AnimationDemo.loadBeardScene(), entityName: "beard")
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
    // swiftlint:enable force_try
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.session.delegate = self
        // arView.environment.background = .color(.black)
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("face tracking is not supported on this device")
        }
        guard ARWorldTrackingConfiguration.supportsUserFaceTracking else {
            fatalError("face tracking with world tracking is not supported on this device")
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
        setupCoachingOverlay()
        setupAnimoji()
        resetDayAndTimeLabels()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    func setupDayAndTimeLabels() {
        let data = getDataOfCurrentDay()
        self.weekDayLabel.text = data.day
        self.currentTimeLabel.text = data.time
    }
    func resetDayAndTimeLabels() {
        if selectedIndexForFilters == 11 {
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
        case 0:
            collectionViewForFilters.isHidden = false
            collectionViewForEffects.isHidden = true
            filterImageView.isHidden = true
            label.isHidden = false
            option = .filters
            resetDayAndTimeLabels()
        case 1:
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
    func captureScreenshot() {
        captureButton.isHidden = true
        collectionViewForFilters.isHidden = true
        collectionViewForEffects.isHidden = true
        label.isHidden = true
        segmentedControl.isHidden = true
        circularView.isHidden = true
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
