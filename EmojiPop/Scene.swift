//
//  Scene.swift
//  EmojiPop
//
//  Created by Sascha Sallès on 04/04/2021.
//

import SpriteKit
import ARKit

public enum GameState {
  case loading
  case tapToStart
  case playing
  case gameOver
}

class Scene: SKScene {
  var gameState = GameState.loading
  var anchor: ARAnchor?
  var emojis = "😀🤣😍🤪🥳🥸😎🤡🎃🤖💀🤗"
  var spawnTime: TimeInterval = 0
  var score: Int = 0
  var lives: Int = 10

  override func didMove(to view: SKView) {
    startGame()
  }

  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    switch (self.gameState) {
    case .loading:
      break
    case .tapToStart:
      self.playGame()
      break
    case .playing:
      //checkTouches(touches)
      break
    case .gameOver:
      self.startGame()
      break
    }
  }

  func updateHUD(withMessage message: String) {
    guard let sceneView = self.view as? ARSKView else { return }
    let viewController = sceneView.delegate as! ViewController
    viewController.hudLabel.text = message
  }


  public func startGame() {
    self.gameState = .tapToStart
    self.updateHUD(withMessage: "- TAP TO START -")
    self.removeAnchor()
  }

  public func playGame() {
    self.gameState = .playing
    self.score = 0
    self.lives = 10
    self.spawnTime = 0
    self.addAnchor()
  }

  public func stopGame() {
    self.gameState = .gameOver
    self.updateHUD(withMessage: "GAME OVER! SCORE: \(self.score)")
  }

  func addAnchor() {
    guard let sceneView = self.view as? ARSKView else { return }
    if let currentFrame = sceneView.session.currentFrame {
      var translation = matrix_identity_float4x4
      translation.columns.3.z = -0.5
      let transform = simd_mul(currentFrame.camera.transform, translation)
      self.anchor = ARAnchor(transform: transform)
      sceneView.session.add(anchor: anchor!)
    }
  }

  func removeAnchor() {
    guard let sceneView = self.view as? ARSKView else { return }
    if self.anchor != nil {
      sceneView.session.remove(anchor: anchor!)
    }
  }

}
