import RealityKit
import ARKit
// swiftlint:disable function_body_length
class RobotHead: Entity, HasModel {
    // Default color values
    private let inactiveColor: SimpleMaterial.Color = .gray
    private let eyeColor: SimpleMaterial.Color = .blue
    private let eyebrowColor: SimpleMaterial.Color = .brown
    private let headColor: SimpleMaterial.Color = .green
    private let lipColor: SimpleMaterial.Color = .lightGray
    private let mouthColor: SimpleMaterial.Color = .gray
    private let tongueColor: SimpleMaterial.Color = .red
    private let clearColor: SimpleMaterial.Color = .clear
    private let notTrackedColor: SimpleMaterial.Color = UIColor.lightGray.withAlphaComponent(0.3)
    private var originalJawY: Float = 0
    private var originalJawX: Float = 0
    private var originalJawZ: Float = 0
    private var originalUpperLipY: Float = 0
    private var originalLeftEyebrowY: Float = 0
    private var originalRightEyebrowY: Float = 0
    private var originalTongueZ: Float = 0
    private lazy var eyeLeftEntity = findEntity(named: "eyeLeft")!
    private lazy var eyeRightEntity = findEntity(named: "eyeRight")!
    private lazy var eyebrowLeftEntity = findEntity(named: "eyebrowLeft")!
    private lazy var eyebrowRightEntity = findEntity(named: "eyebrowRight")!
    private lazy var jawEntity = findEntity(named: "jaw")!
    private lazy var upperLipEntity = findEntity(named: "upperLip")!
    private lazy var headEntity = findEntity(named: "head")!
    private lazy var tongueEntity = findEntity(named: "tongue")!
    private lazy var mouthEntity = findEntity(named: "mouth")!
    private lazy var jawHeight: Float = {
        let bounds = jawEntity.visualBounds(relativeTo: jawEntity)
        return (bounds.max.y - bounds.min.y)
    }()
    private lazy var height: Float = {
        let bounds = headEntity.visualBounds(relativeTo: nil)
        return (bounds.max.y - bounds.min.y)
    }()
    required init() {
        super.init()
        if let robotHead = try? Entity.load(named: "robotHead") {
            addChild(robotHead)
        } else {
            fatalError("Error: Unable to load model.")
        }
        originalJawY = jawEntity.position.y
        originalJawZ = jawEntity.position.z
        originalJawX = jawEntity.position.x
        originalUpperLipY = upperLipEntity.position.y
        originalLeftEyebrowY = eyebrowLeftEntity.position.y
        originalRightEyebrowY = eyebrowRightEntity.position.y
        originalTongueZ = tongueEntity.position.z
    }
    // MARK: - Appearance
    enum Appearance {
        case tracked
        case notTracked
        case intersecting
        case anchored
    }
    var appearance: Appearance = .notTracked {
        didSet {
            headEntity.color = headColor
            eyeLeftEntity.color = eyeColor
            eyeRightEntity.color = eyeColor
            eyebrowLeftEntity.color = eyebrowColor
            eyebrowRightEntity.color = eyebrowColor
            upperLipEntity.color = lipColor
            jawEntity.color = lipColor
            mouthEntity.color = mouthColor
            tongueEntity.color = tongueColor
            switch appearance {
            case .anchored:
                headEntity.color = inactiveColor
            case .intersecting:
                headEntity.color = notTrackedColor
                fallthrough
            case .notTracked:
                eyeLeftEntity.color = notTrackedColor
                eyeRightEntity.color = notTrackedColor
                eyebrowLeftEntity.color = notTrackedColor
                eyebrowRightEntity.color = notTrackedColor
                upperLipEntity.color = notTrackedColor
                jawEntity.color = notTrackedColor
                mouthEntity.color = clearColor
                tongueEntity.color = clearColor
            default: break
            }
        }
    }
    // MARK: - Animations
    /// - Tag: InterpretBlendShapes
    func update(with faceAnchor: ARFaceAnchor) {
        let blendShapes = faceAnchor.blendShapes
        guard
            let eyeBlinkLeft         = blendShapes[.eyeBlinkLeft] as? Float,
            let eyeWideLeft          = blendShapes[.eyeWideLeft] as? Float,
            let eyeBlinkRight        = blendShapes[.eyeBlinkRight] as? Float,
            let eyeWideRight         = blendShapes[.eyeWideRight] as? Float,
            let jawOpen              = blendShapes[.jawOpen] as? Float,
            let mouthFunnel          = blendShapes[.mouthFunnel] as? Float,
            let mouthUpperUpLeft     = blendShapes[.mouthUpperUpLeft] as? Float,
            let mouthUpperUpRight    = blendShapes[.mouthUpperUpRight] as? Float,
            let browDownLeft         = blendShapes[.browDownLeft] as? Float,
            let browDownRight        = blendShapes[.browDownRight] as? Float,
            let browInnerUp          = blendShapes[.browInnerUp] as? Float,
            let browOuterUpLeft      = blendShapes[.browOuterUpLeft] as? Float,
            let browOuterUpRight     = blendShapes[.browOuterUpRight] as? Float,
            let tongueOut            = blendShapes[.tongueOut] as? Float
        else { return }
        eyebrowLeftEntity.position.y   = originalLeftEyebrowY + 0.1 * browOuterUpLeft
        eyebrowRightEntity.position.y  = originalRightEyebrowY + 0.1 * browOuterUpRight
        eyebrowLeftEntity.position.y   = originalLeftEyebrowY - 0.04 * browDownLeft
        eyebrowRightEntity.position.y  = originalRightEyebrowY - 0.04 * browDownRight
        eyebrowLeftEntity.orientation  = simd_quatf(angle: -0.6 * browInnerUp, axis: [0, 0, 1])
        eyebrowRightEntity.orientation = simd_quatf(angle: 0.6 * browInnerUp, axis: [0, 0, 1])
        eyeLeftEntity.scale.z = 1 - eyeBlinkLeft
        eyeRightEntity.scale.z = 1 - eyeBlinkRight
        if eyeWideLeft > 0.5 || eyeWideRight > 0.5 {
            eyeLeftEntity.scale.z = 1 + eyeWideLeft
            eyeRightEntity.scale.z = 1 + eyeWideRight
        }
        if tongueOut > 0.5 {
            tongueEntity.position.z = 0.2 * tongueOut
        } else {
            tongueEntity.position.z = originalTongueZ
        }
        if jawOpen > 0.4 {
            jawEntity.position.y = originalJawY - jawHeight * jawOpen
        } else {
            jawEntity.position.y = originalJawY
        }
        if mouthFunnel > 0.3 {
            jawEntity.scale.x = 1 - mouthFunnel
            mouthEntity.scale.x = 1 - mouthFunnel
            upperLipEntity.scale.x = 1 - mouthFunnel
        } else {
            jawEntity.scale.x = 1
            mouthEntity.scale.x = 1
            upperLipEntity.scale.x = 1
        }
        upperLipEntity.position.y = originalUpperLipY + 0.05 * mouthUpperUpLeft
        upperLipEntity.position.y = originalUpperLipY + 0.05 * mouthUpperUpRight
        guard let parent = parent else {
            return
        }
        let cameraTransform = parent.transformMatrix(relativeTo: nil)
        let faceTransformFromCamera = simd_mul(simd_inverse(cameraTransform), faceAnchor.transform)
        self.position.z = -faceTransformFromCamera.columns.3.z
        let rotationEulers = faceTransformFromCamera.eulerAngles
        let mirroredRotation = Transform(pitch: rotationEulers.x, yaw: -rotationEulers.y + .pi, roll: rotationEulers.z)
        self.orientation = mirroredRotation.rotation
    }
    // MARK: - Proximity check to other entities
    func isTooCloseToAnchoredHeads(in scene: Scene) -> Bool {
        let worldPosition = position(relativeTo: nil)
        let anchoredHeads = scene.anchors.filter { $0.isAnchored && $0.anchoring != .init(.camera) }
        let anchoredHeadPositions = anchoredHeads.compactMap { $0.children.first?.position(relativeTo: nil) }
        for anchoredPosition in anchoredHeadPositions where distance(worldPosition, anchoredPosition) < height {
            return true
        }
        return false
    }
}
// swiftlint:enable function_body_length
