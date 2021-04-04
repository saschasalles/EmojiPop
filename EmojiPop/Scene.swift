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
    if gameState != .playing { return }
    if spawnTime == 0 { spawnTime = currentTime + 3 }
    if spawnTime < currentTime {
      spawnEmoji()
      spawnTime = currentTime + 0.5
    }
    updateHUD(withMessage: "SCORE: \(score) • LIVES: \(lives)")
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    switch (self.gameState) {
    case .loading:
      break
    case .tapToStart:
      self.playGame()
      break
    case .playing:
      self.checkTouches(touches)
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

  func spawnEmoji() {
    let emojiNode = SKLabelNode(text: String(self.emojis.randomElement()!))
    emojiNode.name = "Emoji"
    emojiNode.horizontalAlignmentMode = .center
    emojiNode.verticalAlignmentMode = .center
    emojiNode.physicsBody = SKPhysicsBody(circleOfRadius: 15)
    emojiNode.physicsBody?.mass = 0.01


    guard let sceneView = self.view as? ARSKView else { return }
    let spawnNode = sceneView.scene?.childNode(withName: "SpawnPoint")
    spawnNode?.addChild(emojiNode)
    emojiNode.physicsBody?.applyImpulse(CGVector(dx: -5 + 10 * randomCGFloat(), dy: 10))
    emojiNode.physicsBody?.applyTorque(-0.2 + 0.4 * randomCGFloat())

    let spawnSoundAction = SKAction.playSoundFileNamed("SoundEffects/Spawn.wav", waitForCompletion: false)
    let dieSoundAction = SKAction.playSoundFileNamed("SoundEffects/Die.wav", waitForCompletion: false)
    let waitAction = SKAction.wait(forDuration: 3)
    let removeAction = SKAction.removeFromParent()

    let runAction = SKAction.run({
      self.lives -= 1
      if self.lives <= 0 {
        self.stopGame()
      }
    })

    let sequenceAction = SKAction.sequence([
      spawnSoundAction, waitAction, dieSoundAction, runAction, removeAction
    ])
    emojiNode.run(sequenceAction)
  }

  // Helper Methods


  func randomCGFloat() -> CGFloat {
    return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
  }

  func checkTouches(_ touches: Set<UITouch>) {
    guard let touch = touches.first else { return }
    let touchLocation = touch.location(in: self)
    let touchedNode = self.atPoint(touchLocation)

    if touchedNode.name != "Emoji" { return }
    score += 1

    let collectSoundAction = SKAction.playSoundFileNamed("SoundEffects/Collect.wav", waitForCompletion: false)
    let removeAction = SKAction.removeFromParent()
    let sequenceAction = SKAction.sequence([collectSoundAction, removeAction])
    touchedNode.run(sequenceAction)
  }
}
