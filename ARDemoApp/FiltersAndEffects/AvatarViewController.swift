//
//  AvatarViewController.swift
//  ARDemoApp
//
//  Created by Chicmic on 19/10/23.
//

import UIKit
import SceneKit
import ARKit

class AvatarViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var contentNode: SCNNode?
    var morphs: [SCNGeometry] = []
    let morpher = SCNMorpher()
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        let scene = SCNScene(named: "Head_Final.scn")!
        contentNode = scene.rootNode
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetTracking()
    }
    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard anchor is ARFaceAnchor else { return nil }
        return contentNode
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        DispatchQueue.main.async {
            let blendShapes = faceAnchor.blendShapes
            for (key, value) in blendShapes {
                if let fValue = value as? Float {
                    self.contentNode?.childNodes[0].morpher?.setWeight(CGFloat(fValue), forTargetNamed: key.rawValue)
                }
            }
        }
    }
}
