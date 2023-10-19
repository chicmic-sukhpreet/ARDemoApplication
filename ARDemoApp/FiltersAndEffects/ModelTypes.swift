//
//  Models.swift
//  ARDemoApp
//
//  Created by Chicmic on 28/08/23.
//

import Foundation
import ARKit
import RealityKit

struct ARModel {
    var modelName: String
    var modelEntity: Entity
    var modelOffset: SIMD3<Float>
    var modelScale: SIMD3<Float>
}

struct ARAnimatedModels<T> {
    var animatedAnchor: T
    var entityName: String
}
