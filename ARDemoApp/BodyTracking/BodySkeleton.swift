//
//  BodySkeleton.swift
//  ARDemoApp
//
//  Created by Chicmic on 31/08/23.
//

import Foundation
import RealityKit
import ARKit
// swiftlint:disable line_length
class BodySkeleton: Entity {
    var joints: [String: Entity] = [:]
    var bones: [String: Entity] = [:]
    required init(for bodyAnchor: ARBodyAnchor) {
        super.init()
        for jointName in ARSkeletonDefinition.defaultBody3D.jointNames {
            let jointRadius: Float = 0.01
            let jointColor: UIColor = .green
            let jointEntity = createJoint(radius: jointRadius, color: jointColor)
            joints[jointName] = jointEntity
            self.addChild(jointEntity)
        }
        for bone in Bones.allCases {
            guard let skeletonBone = createSkeletonBone(bone: bone, bodyAnchor: bodyAnchor) else {continue}
            let boneEntity = createBoneEntity(for: skeletonBone)
            bones[bone.name] = boneEntity
            self.addChild(boneEntity)
        }
    }
    required init() {
        fatalError("init() has not been implemented")
    }
    func update(with bodyAnchor: ARBodyAnchor) {
        let rootPosition = simd_make_float3(bodyAnchor.transform.columns.3)
        for jointName in ARSkeletonDefinition.defaultBody3D.jointNames {
            if let jointEntity = joints[jointName],
               let jointEntityTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: jointName)) {
                let joinEntityOffsetFromRoot = simd_make_float3(jointEntityTransform.columns.3)
                jointEntity.position = joinEntityOffsetFromRoot + rootPosition
                jointEntity.orientation = Transform(matrix: jointEntityTransform).rotation
            }
        }
        for bone in Bones.allCases {
            let boneName = bone.name
            guard let entity = bones[boneName],
                  let skeletonBone = createSkeletonBone(bone: bone, bodyAnchor: bodyAnchor)
            else {continue}
            entity.position = skeletonBone.centrePosition
            entity.look(at: skeletonBone.toJoint.position, from: skeletonBone.centrePosition, relativeTo: nil)
        }
    }
    private func createJoint(radius: Float, color: UIColor = .white) -> Entity {
        let mesh = MeshResource.generateSphere(radius: radius)
        let material = SimpleMaterial(color: color, roughness: 0.8, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        return entity
    }
    private func createSkeletonBone(bone: Bones, bodyAnchor: ARBodyAnchor) -> SkeletonBone? {
        guard let fromJointEntityTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: bone.jointFromName)),
              let toJointEntityTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: bone.jointToName))
        else {return nil}
        let rootPosition = simd_make_float3(bodyAnchor.transform.columns.3)
        let jointFromEntityOffsetFromRoot = simd_make_float3(fromJointEntityTransform.columns.3)
        let jointFromEntityPosition = jointFromEntityOffsetFromRoot + rootPosition
        let jointToEntityOffsetFromRoot = simd_make_float3(toJointEntityTransform.columns.3)
        let jointToEntityPosition = jointToEntityOffsetFromRoot + rootPosition
        let fromJoint = SkeletonJoint(name: bone.jointFromName, position: jointFromEntityPosition)
        let toJoint = SkeletonJoint(name: bone.jointToName, position: jointToEntityPosition)
        return SkeletonBone(fromJoint: fromJoint, toJoint: toJoint)
    }
    private func createBoneEntity(for skeletonBone: SkeletonBone,
                                  diameter: Float = 0.02,
                                  color: UIColor = .white) -> Entity {
        let mesh = MeshResource.generateBox(size: [diameter, diameter, skeletonBone.length], cornerRadius: diameter/2)
        let material = SimpleMaterial(color: color, isMetallic: true)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        return entity
    }
}
// swiftlint:enable line_length
