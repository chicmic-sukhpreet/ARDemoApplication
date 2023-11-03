//
//  ARDemoViewController+Calculations.swift
//  ARDemoApp
//
//  Created by Chicmic on 13/10/23.
//

import Foundation
import ARKit
import UIKit
import RealityKit

extension ARDemoViewController {
    func applyFilterToImageView(ciImage: CIImage, filterIndex: Int, imageViewForFilter: UIImageView) {
        guard let filterContext = self.filterContext else { return }
        effects[filterIndex]?.setValue(ciImage, forKey: kCIInputImageKey)
        if filterIndex == 0 {
            effects[filterIndex]?.setValue(0.0, forKey: kCIInputIntensityKey)
        } else if filterIndex == 1 {
            effects[filterIndex]?.setValue(0.7, forKey: kCIInputIntensityKey)
        }
        if let outputImage = effects[filterIndex]?.outputImage {
            if let cgImage = filterContext.createCGImage(outputImage, from: outputImage.extent) {
                DispatchQueue.main.async {
                    let image = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
                    imageViewForFilter.image = image
                }
            }
        }
//        // Create a face detector
//        let detector = CIDetector(ofType: CIDetectorTypeFace,
//                                  context: filterContext,
//                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
//        // Get an array of detected face features
//        if let features = detector?.features(in: ciImage) as? [CIFaceFeature] {
//            for face in features {
//                var filteredImage = ciImage
//                // Apply the Bump Distortion filter to the face
//                if let bumpDistortion = CIFilter(name: "CIBumpDistortion") {
//                    bumpDistortion.setValue(filteredImage, forKey: kCIInputImageKey)
//                    bumpDistortion.setValue(CIVector(x: face.bounds.midX, y: face.bounds.midY),
//                                            forKey: kCIInputCenterKey)
//                    bumpDistortion.setValue(2000.0, forKey: kCIInputRadiusKey)
//                    bumpDistortion.setValue(1.0, forKey: kCIInputScaleKey)
//                    if let distortedImage = bumpDistortion.outputImage {
//                        filteredImage = distortedImage
//                    }
//                }
//                // Render the filtered image
//                if let outputCGImage = filterContext.createCGImage(filteredImage, from: filteredImage.extent) {
//                    DispatchQueue.main.async {
//                        let resultImage = UIImage(cgImage: outputCGImage, scale: 1, orientation: .right)
//                        imageViewForFilter.image = resultImage
//                    }
//                }
//            }
//        }
    }
    func getRotationForEye(withTransform transform: simd_float4x4) -> simd_quatf {
        let m23 = transform[1][2]
        let m33 = transform[2][2]
        let pitch = atan2(-m23, m33)
        let m11 = transform[0][0]
        let m31 = transform[2][0]
        let yaw = atan2(m31, m11)
        let rotationQuaternionX = simd_quatf(angle: -1 * pitch - .pi / 2, axis: [1, 0, 0])
        let rotationQuaternionY = simd_quatf(angle: yaw, axis: [0, 1, 0])
        let combinedRotation = rotationQuaternionX * rotationQuaternionY
        return combinedRotation
    }
    func updateAnimoji(withAnchor faceAnchor: ARFaceAnchor?) {
        let lefteyeTransform = faceAnchor!.leftEyeTransform
        let righteyeTransform = faceAnchor!.rightEyeTransform
        let combinedRotationForLeftEye = getRotationForEye(withTransform: lefteyeTransform)
        let combinedRotationForRightEye = getRotationForEye(withTransform: righteyeTransform)
        rightEyeBallEntity?.orientation = combinedRotationForRightEye
        leftEyeBallEntity?.orientation = combinedRotationForLeftEye
        guard let blendShapes = faceAnchor?.blendShapes else { return }
        guard
            let browOuterUpLeft      = blendShapes[.browOuterUpLeft] as? Float,
            let browOuterUpRight     = blendShapes[.browOuterUpRight] as? Float,
            let tongueOut            = blendShapes[.tongueOut] as? Float,
            let eyeBlinkLeft         = blendShapes[.eyeBlinkLeft] as? Float,
            let eyeBlinkRight        = blendShapes[.eyeBlinkRight] as? Float
        else { return }
        if browOuterUpLeft > 0.3 {
            leftEyeBrowEntity?.position.z = eyeBrowLeftOriginalZ - 0.01 * browOuterUpLeft
        } else {
            leftEyeBrowEntity?.position.z = eyeBrowLeftOriginalZ
        }
        if browOuterUpRight > 0.3 {
            rightEyeBrowEntity?.position.z = eyeBrowRightOriginalZ - 0.01 * browOuterUpRight
        } else {
            rightEyeBrowEntity?.position.z = eyeBrowRightOriginalZ
        }
        if eyeBlinkLeft > 0.4 {
            leftEyeLashEntity?.orientation = simd_quatf(angle: eyeBlinkLeft - .pi / 2, axis: [1, 0, 0])
            rightEyeBallEntity?.position.z = rightEyeBallOriginalZ - 0.01 * eyeBlinkLeft
        } else {
            leftEyeLashEntity?.orientation = leftEyeLashOriginalOrientation!
            rightEyeBallEntity?.position.z = rightEyeBallOriginalZ
        }
        if eyeBlinkRight > 0.4 {
            rightEyeLashEntity?.orientation = simd_quatf(angle: eyeBlinkRight - .pi / 2, axis: [1, 0, 0])
            leftEyeBallEntity?.position.z = leftEyeBallOriginalZ - 0.01 * eyeBlinkRight
        } else {
            rightEyeLashEntity?.orientation = righEyeLashOriginalOrientation!
            leftEyeBallEntity?.position.z = leftEyeBallOriginalZ
        }
        if tongueOut > 0.3 {
            tongueEntity?.position.y = tongueOriginalY + 0.1 * tongueOut
        } else {
            tongueEntity?.position.y = tongueOriginalY
        }
        arView.scene.anchors.append(animatedModelsForEye[0].animatedAnchor)
    }
    func updateTongueModel(anchors: [ARAnchor]) {
        var faceAnchor: ARFaceAnchor?
        label.text = "show your tongue"
        for (index, anc) in anchors.enumerated() {
            guard let anchor = anc as? ARFaceAnchor else { continue }
            faceAnchor = anchor
            guard let blendShapes = faceAnchor?.blendShapes,
                  let tongueOut = blendShapes[.tongueOut]?.floatValue
            else { return }
            if tongueOut > 0.5 {
                arView.scene.anchors.append(animatedModelsForTongue[index].animatedAnchor)
                guard index == 0 else { continue }
                label.text = ""
            } else {
                arView.scene.anchors.remove(animatedModelsForTongue[index].animatedAnchor)
                guard index == 0 else { continue }
                label.text = "show your tongue"
            }
        }
    }
    func updateSmileModel(anchors: [ARAnchor]) {
        var faceAnchor: ARFaceAnchor?
        label.text = "smile"
        for (index, anc) in anchors.enumerated() {
            guard let anchor = anc as? ARFaceAnchor else { continue }
            faceAnchor = anchor
            guard let blendShapes = faceAnchor?.blendShapes,
                  let mouthSmileLeft = blendShapes[.mouthSmileLeft]?.floatValue,
                  let mouthSmileRight = blendShapes[.mouthSmileRight]?.floatValue
            else { return }
            if mouthSmileLeft > 0.3 || mouthSmileRight > 0.3 {
                arView.scene.anchors.append(animatedModelsForSmile[index].animatedAnchor)
                guard index == 0 else { continue }
                label.text = ""
            } else {
                arView.scene.anchors.remove(animatedModelsForSmile[index].animatedAnchor)
                guard index == 0 else { continue }
                label.text = "smile"
            }
        }
    }
    /*
     Enable animation in the reality composer for an animated USDZ file:
     https://forum.sketchfab.com/t/my-usdz-animations-not-playing-in-ar-app/43834
     
     By default, reality composer does not include the animations which comes with the
     USDZ file. We have to enable it by addding behaviour to the entities in the reality composer.
     */
    func updateHeartModel(anchors: [ARAnchor]) {
        for (index, anc) in anchors.enumerated() {
            guard anc as? ARFaceAnchor != nil else { continue }
            arView.scene.anchors.append(heartModels[index].animatedAnchor)
        }
    }
    func updateAntModel(anchors: [ARAnchor]) {
        for (index, anc) in anchors.enumerated() {
            guard anc as? ARFaceAnchor != nil else { continue }
            arView.scene.anchors.append(antModels[index].animatedAnchor)
        }
    }
    func updateBeardModel(anchors: [ARAnchor]) {
        for (index, anc) in anchors.enumerated() {
            guard anc as? ARFaceAnchor != nil else { continue }
            arView.scene.anchors.append(beardModels[index].animatedAnchor)
        }
    }
    func updateFilters(faceAnchor: ARFaceAnchor, index: Int) {
        let anchorEntity = AnchorEntity(anchor: faceAnchor)
        if index == 0 {
            let glassModelInstance = models[selectedIndexForFilters].modelEntity
            glassModelInstance.scale = models[selectedIndexForFilters].modelScale
            let positionOffsetForGlassModel: SIMD3<Float> = models[selectedIndexForFilters].modelOffset
            anchorEntity.addChild(glassModelInstance)
            anchorEntity.position += positionOffsetForGlassModel
        } else if index == 1 {
            let glassModelInstance = models[selectedIndexForFilters + 4].modelEntity
            glassModelInstance.scale = models[selectedIndexForFilters + 4].modelScale
            let positionOffsetForGlassModel: SIMD3<Float> = models[selectedIndexForFilters + 4].modelOffset
            anchorEntity.addChild(glassModelInstance)
            anchorEntity.position += positionOffsetForGlassModel
        } else {
            let glassModelInstance = models[selectedIndexForFilters + 8].modelEntity
            glassModelInstance.scale = models[selectedIndexForFilters + 8].modelScale
            let positionOffsetForGlassModel: SIMD3<Float> = models[selectedIndexForFilters + 8].modelOffset
            anchorEntity.addChild(glassModelInstance)
            anchorEntity.position += positionOffsetForGlassModel
        }
        arView.scene.anchors.append(anchorEntity)
    }
    func getDataOfCurrentDay() -> (day: String, time: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let currentDate = Date()
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: currentDate)
        let dayString = dateFormatter.weekdaySymbols[dayOfWeek - 1]
        dateFormatter.dateFormat = "hh:mm a"
        let currentTimeString = dateFormatter.string(from: currentDate)
        return (dayString, currentTimeString)
    }
}
