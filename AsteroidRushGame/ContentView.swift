//
//  ContentView.swift
//  AsteroidRushGame
//
//  Created by Tiago Pereira on 14/02/22.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    private var screenWidth: CGFloat { return UIScreen.main.bounds.size.width }
    private var screenHeight: CGFloat { return UIScreen.main.bounds.size.height }
    
    var asteroidsGameScene: AsteroidsGameScene {
        let scene = AsteroidsGameScene()
        
        scene.size = CGSize(width: screenWidth, height: screenHeight)
        scene.scaleMode = .fill
        
        return scene
    }
    
    var body: some View {
        SpriteView(scene: asteroidsGameScene)
            .frame(width: screenWidth, height: screenHeight)
            .ignoresSafeArea()
            .statusBar(hidden: true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
