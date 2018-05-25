//
//  GameViewController.swift
//  BasicSpriteKit001
//
//  Created by Raman Singh on 2018-05-25.
//  Copyright © 2018 Raman Singh. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var game = GameHelper.sharedInstance
    var spawnTime:TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupCamera()
        spawnShape()
        
        scnView.showsStatistics = true
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        
    }//load
    
    func shouldAutorotate() -> Bool {
        return true
    }//autoRotate
    
    func prefersStatusBarHidden() -> Bool {
        return true
    }//prefersStatusBarHidden
    
    func setupView() {
        scnView = self.view as! SCNView
        scnView.delegate = self
    }//setupView
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnScene.background.contents = "GeometryFighter.scnassets/Textures/Background_Diffuse.png"
    }//setupScene
    
    func setupCamera() {
        
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        scnScene.rootNode.addChildNode(cameraNode)
        setupHUD()
        scnView.allowsCameraControl = false
    }//setupCamera
    
    
    func spawnShape() {
        var geometry:SCNGeometry
        switch ShapeType.random() {
        case .Box:
            geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        case .Sphere:
            geometry = SCNSphere(radius: 0.5)
        case .Pyramid:
            geometry = SCNPyramid(width: 1.0, height: 1.0, length: 1.0)
        case .Torus:
            geometry = SCNTorus(ringRadius: 0.5, pipeRadius: 0.25)
        case .Capsule:
            geometry = SCNCapsule(capRadius: 0.3, height: 2.5)
        case .Cylinder:
            geometry = SCNCylinder(radius: 0.3, height: 2.5)
        case .Cone:
            geometry = SCNCone(topRadius: 0.0, bottomRadius: 0.5, height: 1.0)
        case .Tube:
            geometry = SCNTube(innerRadius: 0.25, outerRadius: 0.5, height: 1.0)
        }
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        let randomX:Float = 1.2
        let randomY:Float = 12.45
        let force = SCNVector3(x: randomX, y: randomY , z: 0)
        let position = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        geometryNode.physicsBody?.applyForce(force, at: position, asImpulse: true)
        let color = UIColor.random()
        geometry.materials.first?.diffuse.contents = color
        if color == UIColor.black {
            geometryNode.name = "BAD"
        } else {
            geometryNode.name = "GOOD"
        }
        let trailEmitter = createTrail(color: color, geometry: geometry)
        geometryNode.addParticleSystem(trailEmitter)
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
        scnScene.rootNode.addChildNode(geometryNode)
    }//spawnShape
    
    func cleanScene() {
        
        for node in scnScene.rootNode.childNodes {
            if node.presentation.position.y < -2 {
                node.removeFromParentNode()
            }
        }//forLoop
    }//cleanScene
    
    func createTrail(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem {
        let trail = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil)!
        trail.particleColor = color
        trail.emitterShape = geometry
        return trail
    }//createTrail
    
    func setupHUD() {
        game.hudNode.position = SCNVector3(x: 0.0, y: 10.0, z: 0.0)
        scnScene.rootNode.addChildNode(game.hudNode)
    }//setupHUD
    
    func handleTouchFor(node: SCNNode) {
        if node.name == "GOOD" {
            game.score += 1
            node.removeFromParentNode()
            createExplosion(geometry:node.geometry!, position: node.presentation.position,
                            rotation: node.presentation.rotation)
        } else if node.name == "BAD" {
            game.lives -= 1
            node.removeFromParentNode()
            createExplosion(geometry:node.geometry!, position: node.presentation.position,
                            rotation: node.presentation.rotation)
        }
    }//handleTouch
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults.first!
            handleTouchFor(node: result.node)
        }
    }//touchesBegan
    
    func createExplosion(geometry: SCNGeometry, position: SCNVector3,
                         rotation: SCNVector4) {
        let explosion =
            SCNParticleSystem(named: "Explode.scnp", inDirectory:
                nil)!
        explosion.emitterShape = geometry
        explosion.birthLocation = .surface
        let rotationMatrix =
            SCNMatrix4MakeRotation(rotation.w, rotation.x,
                                   rotation.y, rotation.z)
        let translationMatrix =
            SCNMatrix4MakeTranslation(position.x, position.y,
                                      position.z)
        let transformMatrix =
            SCNMatrix4Mult(rotationMatrix, translationMatrix)
        scnScene.addParticleSystem(explosion, transform:
            transformMatrix)
    }
}//end

extension GameViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if time > spawnTime {
            spawnShape()
            spawnTime = time + TimeInterval(0.9)
        }//if
        cleanScene()
        scnView.isPlaying = true
        game.updateHUD()
    }//renderer
    
    
    
    
    
    
    
    
}//extension













