//
//  GameConstants.swift
//  AsteroidRushGame
//
//  Created by Tiago Pereira on 15/02/22.
//

import SpriteKit

struct SpaceColorPalette {
    static var background = UIColor(red: 78/255, green: 4/255, blue: 63/255, alpha: 1.0)
    static var player = UIColor(red: 241/255, green: 34/255, blue: 90/255, alpha: 1.0)
    static var asteroid = UIColor(red: 252/255, green: 115/255, blue: 96/255, alpha: 1.0)
    static var smallAsteroid = UIColor(red: 247/255, green: 75/255, blue: 93/255, alpha: 1.0)
    static var purple = UIColor(red: 161/255, green: 40/255, blue: 92/255, alpha: 1.0)
}

struct SpaceGameSizes {
    static var asteroidSize = CGSize(width: 40, height: 40)
    static var smallAsteroidSize = CGSize(width: 10, height: 10)
    static var playerSize = CGSize(width: 20, height: 20)
}

struct SpaceGameNames {
    static var player = "player"
    static var playerParticles = "playerParticles"
    static var asteroidParticles = "asteroidParticles"
}
