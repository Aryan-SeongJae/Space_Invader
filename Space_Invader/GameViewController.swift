//
//  GameViewController.swift
//  Space_Invader
//
//  Created by 이성재 on 19/06/24.
//

import UIKit
import SpriteKit


class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            let scene = GameScene(size: CGSize(width: 1536, height: 2048))
            // Load the SKScene from 'GameScene.sks'
            
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        
            }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return.allButUpsideDown
        } else {
            return.all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

