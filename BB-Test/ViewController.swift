//
//  ViewController.swift
//  BB-Test
//
//  Created by Joseph Hankin on 12/15/17.
//  Copyright © 2017 Chronocide Labs. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var nodeModel: SCNNode!
    var nodeName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let emptyScene = SCNScene()
        sceneView.scene = emptyScene
        
        let scene = SCNScene(named: "art.scnassets/BB-171213-felt.scn")!
        guard let node = scene.rootNode.childNodes.first else {
            fatalError("Couldn't find the root node")
        }
        nodeName = node.name
        nodeModel = node
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(detectedTap(gestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        // Set the view's delegate
        sceneView.delegate = self
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @objc func detectedTap(gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: sceneView)
        
        let objectHitResults = sceneView.hitTest(location, options: [SCNHitTestOption.boundingBoxOnly : true])
        if let hit = objectHitResults.first {
            if removeObject(hit) { return }
        }
        
        let hitTestResults = sceneView.hitTest(location, types: .featurePoint)
        if let hit = hitTestResults.first {
            let rotation = simd_float4x4(SCNMatrix4MakeRotation(sceneView.session.currentFrame!.camera.eulerAngles.y, 0, 1, 0))
            let finalTransform = simd_mul(hit.worldTransform, rotation)
            sceneView.session.add(anchor: ARAnchor(transform: finalTransform))
        }
    }
    
    func removeObject(_ hit: SCNHitTestResult) -> Bool {
        if let node = getParent(hit.node) {
            node.removeFromParentNode()
            return true
        }
        
        return false
    }
    
    func getParent(_ nodeFound: SCNNode?) -> SCNNode? {
        if let node = nodeFound {
            if node.name == nodeName {
                return node
            } else if let parent = node.parent {
                return getParent(parent)
            }
        }
        return nil
    }

    // MARK: - ARSCNViewDelegate

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor.isKind(of: ARPlaneAnchor.self) { return }

        let modelClone = nodeModel.clone()
        modelClone.position = SCNVector3Zero
        node.addChildNode(modelClone)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
