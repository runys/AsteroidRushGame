//
//  AsteroidsGameScene.swift
//  AsteroidRushGame
//
//  Created by Tiago Pereira on 14/02/22.
//

import SpriteKit

// From Ray Wenderlich
// https://www.raywenderlich.com/71-spritekit-tutorial-for-beginners#toc-anchor-007
struct PhysicsCategory {
    static let none     : UInt32 = 0
    static let all      : UInt32 = UInt32.max
    static let player   : UInt32 = 0b1
    static let asteroid : UInt32 = 0b10
    static let smallAsteroid : UInt32 = 0b11
}

class AsteroidsGameScene: SKScene {
    
    var isMovingToTheRight: Bool = false
    var isMovingToTheLeft: Bool = false
    
    var player: SKShapeNode!
    var particles: SKEmitterNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = SpaceColorPalette.background

        setUpPhysicsWorld()
        setUpPlayer()
        startAsteroidsCycle()
    }
    
    private func setUpPhysicsWorld() {
        // Setting up the physics world
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.5)
        
        // Setting up the contact and collision system
        physicsWorld.contactDelegate = self
    }
    
    private func setUpPlayer() {
        // Create the player node
        self.player = SKShapeNode(circleOfRadius: SpaceGameSizes.playerSize.width/2)
        self.player.name = SpaceGameNames.player
        self.player.fillColor = SpaceColorPalette.player
        self.player.strokeColor = SpaceColorPalette.player
        
        // Player position
        let positionX = self.frame.width / 2
        let positionY = self.frame.height / 6
        
        self.player.position = CGPoint(x: positionX, y: positionY)
        
        // Player physics body
        self.player.physicsBody = SKPhysicsBody(circleOfRadius: SpaceGameSizes.playerSize.width/2)
        self.player.physicsBody?.affectedByGravity = false
        
        // Player contact and collision mask
        self.player.physicsBody?.categoryBitMask = PhysicsCategory.player
        self.player.physicsBody?.contactTestBitMask = PhysicsCategory.asteroid
        self.player.physicsBody?.collisionBitMask = PhysicsCategory.asteroid
        
        // Player particles
        self.particles = SKEmitterNode(fileNamed: "PlayerParticles.sks")
        self.particles.targetNode = self
        self.particles.name = SpaceGameNames.playerParticles
        self.particles.emissionAngle = 1.5 * CGFloat.pi
        
        addChild(player)
        player.addChild(particles)
    }
    
    func startAsteroidsCycle() {
        let createAsteroidAction = SKAction.run(createAsteroid)
        let waitAction = SKAction.wait(forDuration: 5.0)
        let createAndWaitAction = SKAction.sequence([createAsteroidAction, waitAction])
        let asteroidCycleAction = SKAction.repeatForever(createAndWaitAction)
        
        run(asteroidCycleAction)
    }
}


// MARK: - Game Loop
extension AsteroidsGameScene {
    override func update(_ currentTime: TimeInterval) {
        if isMovingToTheRight {
            self.moveRight()
        }
        
        if isMovingToTheLeft {
            self.moveLeft()
        }
    }
}

// MARK: - Handling player movement
extension AsteroidsGameScene {
    
    enum SideOfTheScreen {
        case right, left
    }
    
    private func moveLeft() {
        self.player.physicsBody?.applyForce(CGVector(dx: 5, dy: 0))
    }
    
    private func moveRight() {
        self.player.physicsBody?.applyForce(CGVector(dx: -5, dy: 0))
    }
    
    private func sideTouched(for position: CGPoint) -> SideOfTheScreen {
        if position.x < self.frame.width / 2 {
            return .left
        } else {
            return .right
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1. Check where in the screen the touch happened
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        switch sideTouched(for: touchLocation) {
        case .right:
            print("➡️ Right side of the screen touched")
            self.isMovingToTheRight = true
        case .left:
            print("⬅️ Left side of the screen touched")
            self.isMovingToTheLeft = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("⏹ Stopped moving")
        self.isMovingToTheLeft = false
        self.isMovingToTheRight = false
    }
    
}

// MARK: - Asteroids
extension AsteroidsGameScene {
    
    func createAsteroid() {
        // Create the asteroid
        let newAsteroid = SKShapeNode(rectOf: SpaceGameSizes.asteroidSize)
        newAsteroid.fillColor = SpaceColorPalette.asteroid
        newAsteroid.strokeColor = SpaceColorPalette.asteroid
        
        // Asteroid position
        let initialX: CGFloat = 10
        let finalX: CGFloat = self.frame.width - 10
        let positionX = CGFloat.random(in: initialX...finalX)
        let positionY = frame.height - SpaceGameSizes.asteroidSize.height
        
        newAsteroid.position = CGPoint(x: positionX, y: positionY)
        
        // Asteroid physics body
        newAsteroid.physicsBody = SKPhysicsBody(rectangleOf: SpaceGameSizes.asteroidSize)
        newAsteroid.physicsBody?.affectedByGravity = true
        
        // Asteroid contact and collision mask
        // newAsteroid.physicsBody?.isDynamic = false
        newAsteroid.physicsBody?.categoryBitMask = PhysicsCategory.asteroid
        newAsteroid.physicsBody?.contactTestBitMask = PhysicsCategory.player
        newAsteroid.physicsBody?.collisionBitMask = PhysicsCategory.player
        
        let asteroidParticles = SKEmitterNode(fileNamed: "AsteroidParticle.sks")
        asteroidParticles?.targetNode = self
        // asteroidParticles.name = SpaceGameNames.asteroidParticles
        asteroidParticles?.emissionAngle = 0.5 * CGFloat.pi
        
        addChild(newAsteroid)
        newAsteroid.addChild(asteroidParticles!)
    }
    
}

// MARK: - Contact and Collision
extension AsteroidsGameScene: SKPhysicsContactDelegate {
    
    func damagePlayer() {
        print("Player was damaged")
    }
    
    func destroy(asteroid: SKShapeNode) {
        print("destroying asteroid at \(asteroid.position)")
        
        let bigAsteroidPosition = asteroid.position
        
        var smallAsteroids = [SKSpriteNode]()
        
        for _ in 1...8 {
            let smallAsteroid = SKSpriteNode(color: SpaceColorPalette.smallAsteroid, size: SpaceGameSizes.smallAsteroidSize)
            smallAsteroid.position = bigAsteroidPosition
            smallAsteroid.physicsBody = SKPhysicsBody(rectangleOf: SpaceGameSizes.smallAsteroidSize)
            smallAsteroid.physicsBody?.affectedByGravity = true
            smallAsteroid.physicsBody?.categoryBitMask = PhysicsCategory.smallAsteroid
            smallAsteroid.physicsBody?.contactTestBitMask = PhysicsCategory.none
            smallAsteroid.physicsBody?.collisionBitMask = PhysicsCategory.none
            
            smallAsteroids.append(smallAsteroid)
        }
        
        asteroid.removeFromParent()
        
        for (index, asteroid) in smallAsteroids.enumerated() {
            addChild(asteroid)
            let randomDX = CGFloat.random(in: 0...1) * CGFloat.pi * CGFloat(index % 2 == 0 ? 1 : -1)
            let randomDY = CGFloat.random(in: 0...1) * CGFloat.pi * CGFloat(index % 2 == 0 ? 1 : -1)
            asteroid.physicsBody?.applyImpulse(CGVector(dx: randomDX, dy: randomDY))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask {
            print("First option")
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            print("Second option")
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        let isFirstBodyAsteroid = firstBody.categoryBitMask & PhysicsCategory.asteroid != 0
        let isSecondBodyPlayer = secondBody.categoryBitMask & PhysicsCategory.player != 0
        
        print("isFirstBodyAsteroid: \(isFirstBodyAsteroid)")
        print("isSecondBodyPlayer: \(isSecondBodyPlayer)")
        
        if isFirstBodyAsteroid && isSecondBodyPlayer {
            if let asteroid = firstBody.node as? SKShapeNode,
               let player = secondBody.node as? SKShapeNode {
                damagePlayer()
                destroy(asteroid: asteroid)
            }
        }
    }
    
}
