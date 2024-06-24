//
//  GameScene.swift
//  Space_Invader
//
//  Created by 이성재 on 19/06/24.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameScore = 0
    var scoreLabel = SKLabelNode.init(fontNamed: "Chalkduster")
    var levelNumber = 0
    var livesLabel = SKLabelNode.init(fontNamed: "Chalkduster")
    var livesNumber = 3
    
    
    
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    
    
    struct PhysicsCategories {
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1
        static let Bullet : UInt32 = 0b10
        static let Enemy : UInt32 = 0b100
        
    }
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    let gameArea: CGRect
    
    override init(size: CGSize){
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = size.width - playableWidth
        
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        player.physicsBody!.affectedByGravity = false
        self.addChild(player)
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height * 0.9)
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 30
        livesLabel.fontColor = SKColor.white
        livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height * 0.9)
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.verticalAlignmentMode = .top
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
    
        
        
        
        startNewLevel()
        
        
    }
    
    func loseALife() {
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run (scaleSequence)
        
    }
    
    
    func addScore() {
        
        gameScore += 1
        scoreLabel.text = "Score \(gameScore)"
        
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50 {
        startNewLevel ()
        }
        
        
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var Body1 = SKPhysicsBody()
        var Body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            Body1 = contact.bodyA
            Body2 = contact.bodyB
        }
        else {
            Body1 = contact.bodyB
            Body2 = contact.bodyA
        }
        
        
        if Body1.categoryBitMask == PhysicsCategories.Player && Body2.categoryBitMask == PhysicsCategories.Enemy{
            
            if Body1.node != nil {
                spawnExplosion(spawnPosition: Body1.node!.position)
            }
            
            
            if Body2.node != nil {
                spawnExplosion(spawnPosition: Body2.node!.position)
            }
            
            
            Body1.node?.removeFromParent()
            Body2.node?.removeFromParent()
            
        }
        
        if Body1.categoryBitMask == PhysicsCategories.Bullet && Body2.categoryBitMask == PhysicsCategories.Enemy && (Body2.node?.position.y)!  < self.size.height {
            
            addScore()
            
            if Body2.node != nil {
                spawnExplosion(spawnPosition: Body2.node!.position)
            }
            
            Body1.node?.removeFromParent()
            Body2.node?.removeFromParent()
        }
    }
    
    func fireBullet() {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        
        
    }
    
    func spawnEnemy() {
        
        let randomXStart = random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
        let randomXEnd = random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Bullet | PhysicsCategories.Player
        
        self.addChild(enemy)
        
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 2)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        enemy.run(enemySequence)
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
        
        
    }
    
    func spawnExplosion(spawnPosition: CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        
        self.addChild(explosion)
        
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        
        let explosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        fireBullet()
        
        
        
    }
    
    func startNewLevel() {
        levelNumber+=1
        
        if self.action(forKey: "spawningEnemies") != nil {
            
            self.removeAction(forKey: "spawningEnemies")
            
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber {
        case 1: levelDuration = 3.0
        case 2: levelDuration = 2.5
        case 3: levelDuration = 2.0
        case 4: levelDuration = 1.5
        default:
            levelDuration = 1.5
            print("Cannot find level information.")
        }
        
       
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
        
        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            player.position.x += amountDragged
            
            if player.position.x > CGRectGetMaxX(gameArea) - player.size.width/2 {
                player.position.x = CGRectGetMaxX(gameArea) - player.size.width/2
            }
            
            if player.position.x < CGRectGetMinX(gameArea) + player.size.width/2 {
                player.position.x = CGRectGetMinX(gameArea) + player.size.width/2
            }
            
            
            
            
        }
        
        
    }
}
