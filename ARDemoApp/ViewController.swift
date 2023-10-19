//
//  ViewController.swift
//  ARDemoApp
//
//  Created by Chicmic on 23/08/23.
//

import UIKit
import ARKit
// swiftlint:disable line_length
class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    let configuration = ARFaceTrackingConfiguration()
    let scene = SCNScene()
    @IBOutlet weak var captureButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device")
            return
        }
        sceneView.delegate = self
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.scene = scene
        sceneView.session.run(configuration)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    @IBAction func captureButtonClicked(_ sender: UIButton) {
        captureScreenshot()
    }
    func captureScreenshot() {
        let originalButtonHidden = captureButton.isHidden
        captureButton.isHidden = true

        let renderer = UIGraphicsImageRenderer(size: sceneView.bounds.size)
        let screenshot = renderer.image { _ in
            sceneView.drawHierarchy(in: sceneView.bounds, afterScreenUpdates: true)
        }
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as? PreviewViewController
        secondViewController?.delegate = self
        secondViewController?.capturedImage = screenshot
        self.navigationController?.pushViewController(secondViewController!, animated: true)
        captureButton.isHidden = originalButtonHidden
    }
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return nil }
        guard let scene = SCNScene(named: "Glasses.scn"),
              let originalGlassesNode = scene.rootNode.childNode(withName: "glasses", recursively: true) else {
            return nil
        }
        let glassesNode = originalGlassesNode.clone()
        glassesNode.eulerAngles.x = -.pi
        glassesNode.eulerAngles.y = -.pi
        glassesNode.eulerAngles.z = -.pi
        let glassesScale: Float = 0.005
        let glassesPosition = SCNVector3(0, 0.02, 0)
        glassesNode.scale = SCNVector3(glassesScale + 0.008, glassesScale + 0.008, glassesScale)
        glassesNode.position = glassesPosition
        let faceNode = SCNNode()
        faceNode.addChildNode(glassesNode)
        faceNode.transform = SCNMatrix4(faceAnchor.transform)
        return faceNode
    }
}

extension ViewController: PreviewViewControllerDelegate {
    func previewViewControllerDidSaveImage(_ viewController: PreviewViewController) {
        if let image = viewController.previewImage.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        viewController.showSaveAlert()
        self.navigationController?.popViewController(animated: true)
    }

    func previewViewControllerDidDiscardImage(_ viewController: PreviewViewController) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved successfully")
        }
    }
}
// swiftlint:enable line_length
