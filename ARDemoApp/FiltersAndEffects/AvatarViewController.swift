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
    var blackBackground = true
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        let scene = SCNScene(named: "facial-setup-final.scn")!
        if blackBackground {
            sceneView.scene.background.contents = UIColor(white: 0.0, alpha: 0.2)
        }
        contentNode = scene.rootNode
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if blackBackground {
            sceneView.scene.background.contents = UIColor(white: 0.0, alpha: 0.2)
        }
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
        if blackBackground {
            sceneView.scene.background.contents = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        }
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
