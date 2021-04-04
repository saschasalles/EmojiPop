//
//  ViewController.swift
//  EmojiPop
//
//  Created by Sascha Sallès on 04/04/2021.
//

import UIKit
import SpriteKit
import ARKit

class ViewController: UIViewController, ARSKViewDelegate {

  @IBOutlet var sceneView: ARSKView!
  @IBOutlet weak var hudLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set the view's delegate
    sceneView.delegate = self

    // Show statistics such as fps and node count
    sceneView.showsFPS = true
    sceneView.showsNodeCount = true

    // Load the SKScene from 'Scene.sks'
    if let scene = SKScene(fileNamed: "Scene") {
      sceneView.presentScene(scene)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()

    // Run the view's session
    sceneView.session.run(configuration)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    // Pause the view's session
    sceneView.session.pause()
  }

  // MARK: - ARSKViewDelegate

  func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
    // Create and configure a node for the anchor added to the view's session.
    let spawnNode = SKNode()
    spawnNode.name = "SpawnPoint"

    let boxNode = SKLabelNode(text: "🆘")
    boxNode.verticalAlignmentMode = .center
    boxNode.horizontalAlignmentMode = .left
    boxNode.zPosition = 150
    boxNode.setScale(1.5)
    spawnNode.addChild(boxNode)

    return spawnNode
  }

  func session(_ session: ARSession, didFailWithError error: Error) {
    // Present an error message to the user
    showAlert("Session Failure", error.localizedDescription)
  }

  func sessionWasInterrupted(_ session: ARSession) {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    showAlert("AR Session", "Session was interrupted 😔")
  }

  func sessionInterruptionEnded(_ session: ARSession) {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    let scene = sceneView.scene as! Scene
    scene.startGame()
  }

  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    switch camera.trackingState {
    case .normal:
      break
    case .notAvailable:
      showAlert("Tracking Limited", "AR not available")
      break
    case .limited(let reason):
      switch reason {
      case .initializing, .relocalizing:
        break
      case .excessiveMotion:
        showAlert("Tracking Limited", "Excessive motion!")
        break
      case .insufficientFeatures:
        showAlert("Tracking Limited", "Insufficient features!")
        break
      default:
        break
      }
    }
  }


  //Helper Funcs

  func showAlert(_ title: String, _ message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
}
