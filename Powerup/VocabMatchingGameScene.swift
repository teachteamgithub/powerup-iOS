import SpriteKit

class VocabMatchingGameScene: SKScene {
    // TODO: Store the information of each round in the database.
    // Matching ID, Texture name.
    let tileTypes = [
        (0, "vocabmatching_tile_lingerie"),
        (1, "vocabmatching_tile_pimple"),
        (2, "vocabmatching_tile_pad"),
    ]
    
    // Matching ID, description Text.
    let clipboardEachRound = [
        (0, "Lingerie"),
        (1, "Pimple"),
        (2, "Sanitary Pad")
    ]
    
    // MARK: Constants
    let timeForTileToReachClipboard = 12.0
    let totalRounds = 5
    let tilesPerRound = 2
    let timeBetweenTileSpawns = 2.5
    
    // Sizing and position of the nodes (They are relative to the width and height of the game scene.)
    // Score Box
    let scoreBoxSpriteWidth = 0.09
    let scoreBoxSpriteHeight = 0.15
    let scoreBoxSpritePosY = 0.9
    
    // The following two is relative to the score box.
    let scoreLabelPosX = 0.4
    let scoreLabelPosY = -0.1
    
    // The positionY of each lane. (That is, the posY of tiles and clipboards.)
    let lanePositionsY = [0.173, 0.495, 0.828]
    
    // Tile
    let tileSpriteSizeRelativeToWidth = 0.14
    let tileSpriteSpawnPosX = 0.0
    let tileTouchesClipboardPosX = 0.7
    
    // Clipboard
    let clipboardSpriteWidth = 0.24
    let clipboardSpriteHeight = 0.29
    let clipboardSpritePosX = 0.855
    
    // Continue button
    let continueButtonBottomMargin = 0.08
    let continueButtonHeightRelativeToSceneHeight = 0.15
    let continueButtonAspectRatio = 2.783
    
    // End scene labels
    let endSceneTitleLabelPosX = 0.0
    let endSceneTitleLabelPosY = 0.1
    let endSceneScoreLabelPosX = 0.0
    let endSceneScoreLabelPosY = -0.1
    
    // Sprite Nodes
    let scoreBoxSprite = SKSpriteNode(imageNamed: "vocabmatching_scorebox")
    let backgroundSprite = SKSpriteNode(imageNamed: "vocabmatching_background")
    let endSceneSprite = SKSpriteNode()
    let continueButton = SKSpriteNode(imageNamed: "continue_button")
    
    // Label Nodes & Label Wrapper Node
    let scoreLabelWrapper = SKNode()
    let endSceneTitleLabelWrapper = SKNode()
    let endSceneScoreLabelWrapper = SKNode()
    let scoreLabel = SKLabelNode()
    let endSceneTitleLabel = SKLabelNode()
    let endSceneScoreLabel = SKLabelNode()
    
    // Textures
    let tileTexture = SKTexture(imageNamed: "vocabmatching_tile")
    let clipboardTexture = SKTexture(imageNamed: "vocabmatching_clipboard")
    
    // Layers (zPosition)
    let backgroundLayer = CGFloat(-0.1)
    let clipboardLayer = CGFloat(0.2)
    let clipboardDraggingLayer = CGFloat(0.3)
    let tileLayer = CGFloat(0.4)
    let uiLayer = CGFloat(0.5)
    let uiTextLayer = CGFloat(0.6)
    let endSceneLayer = CGFloat(1.5)
    
    // Fonts
    let fontName = "Montserrat-Bold"
    let fontColor = UIColor(colorLiteralRed: 21.0 / 255.0, green: 124.0 / 255.0, blue: 129.0 / 255.0, alpha: 1.0)
    
    // Font size
    let clipboardFontSize = CGFloat(14)
    let scoreFontSize = CGFloat(16)
    let endSceneTitleFontSize = CGFloat(20)
    
    // If there are too many (longTextDef) characters in the string of the pad, shrink it.
    let clipboardLongTextFontSize = CGFloat(10)
    let clipboardLongTextDef = 12
    
    // Animations
    let swappingAnimationDuration = 0.2
    let endSceneFadeInAnimationDuration = 0.5
    
    // Strings
    let endSceneTitleLabelText = "Game Over"
    let scoreLabelPrefix = "Score: "
    
    // MARK: Properties
    // The clipboards which could be swapped.
    var clipboards: [VocabMatchingClipboard]
    
    var currRound: Int = -1
    
    // Keep a reference to the mini game view controller for end game transition.
    var viewController: MiniGameViewController!
    
    // The clipboard currently being dragged.
    var clipboardDragged: VocabMatchingClipboard? = nil
    
    // Cannot perform another swap if some clipboards are currently swapping.
    var isSwapping = false
    
    var isContinueButtonInteractable = false
    
    var score: Int = 0
    
    // Avoid spawning the same type / same lane in a row.
    var lastTileTypeIndex = -1
    var lastTileLaneNumber = -1
    
    // MARK: Constructors
    override init(size: CGSize) {
        let gameWidth = Double(size.width)
        let gameHeight = Double(size.height)
        
        // Sizing and positioning the background image.
        backgroundSprite.position = CGPoint(x: gameWidth / 2.0, y: gameHeight / 2.0)
        backgroundSprite.size = size
        backgroundSprite.zPosition = backgroundLayer
        
        // Sizing and positioning the score box.
        // Score box's pivot is at the middle left.
        scoreBoxSprite.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        scoreBoxSprite.position = CGPoint(x: 0.0, y: gameHeight * scoreBoxSpritePosY)
        scoreBoxSprite.size = CGSize(width: gameWidth * scoreBoxSpriteWidth, height: gameHeight * scoreBoxSpriteHeight)
        scoreBoxSprite.zPosition = uiLayer
        
        // Initialize the clipboards.
        clipboards = [VocabMatchingClipboard]()
        for index in 0..<lanePositionsY.count {
            let currClipboard = VocabMatchingClipboard(texture: clipboardTexture, size: CGSize(width: gameWidth * clipboardSpriteWidth, height: gameHeight * clipboardSpriteHeight), matchingID: clipboardEachRound[index].0, description: clipboardEachRound[index].1)
            
            // Configure font.
            currClipboard.descriptionLabel.fontName = fontName
            currClipboard.descriptionLabel.fontColor = fontColor
            if currClipboard.descriptionLabel.text!.characters.count >= clipboardLongTextDef {
                currClipboard.descriptionLabel.fontSize = clipboardLongTextFontSize
            } else {
                currClipboard.descriptionLabel.fontSize = clipboardFontSize
            }
            
            // Positioning
            currClipboard.position = CGPoint(x: gameWidth * clipboardSpritePosX, y: gameHeight * lanePositionsY[index])
            currClipboard.zPosition = clipboardLayer
            
            clipboards.append(currClipboard)
        }
        
        // Score Label
        scoreBoxSprite.addChild(scoreLabelWrapper)
        scoreLabelWrapper.position = CGPoint(x: Double(scoreBoxSprite.size.width) * scoreLabelPosX, y: Double(scoreBoxSprite.size.height) * scoreLabelPosY)
        scoreLabelWrapper.addChild(scoreLabel)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.zPosition = uiTextLayer
        scoreLabel.fontName = fontName
        scoreLabel.fontColor = fontColor
        scoreLabel.fontSize = scoreFontSize
        scoreLabel.text = "0"
        
        // Sizing and positioning ending scene.
        endSceneSprite.size = CGSize(width: size.width, height: size.height)
        endSceneSprite.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        endSceneSprite.color = UIColor.white
        endSceneSprite.zPosition = endSceneLayer
        
        // End scene labels.
        endSceneSprite.addChild(endSceneTitleLabelWrapper)
        endSceneTitleLabelWrapper.position = CGPoint(x: gameWidth * endSceneTitleLabelPosX, y: gameHeight * endSceneTitleLabelPosY)
        endSceneTitleLabelWrapper.zPosition = uiTextLayer
        endSceneTitleLabelWrapper.addChild(endSceneTitleLabel)
        
        endSceneTitleLabel.fontName = fontName
        endSceneTitleLabel.fontColor = fontColor
        endSceneTitleLabel.fontSize = endSceneTitleFontSize
        endSceneTitleLabel.text = endSceneTitleLabelText
        endSceneTitleLabel.horizontalAlignmentMode = .center
        endSceneTitleLabel.verticalAlignmentMode = .center
        
        endSceneSprite.addChild(endSceneScoreLabelWrapper)
        endSceneScoreLabelWrapper.position = CGPoint(x: gameWidth * endSceneScoreLabelPosX, y: gameHeight * endSceneScoreLabelPosY)
        endSceneScoreLabelWrapper.zPosition = uiTextLayer
        endSceneScoreLabelWrapper.addChild(endSceneScoreLabel)
        
        endSceneScoreLabel.fontName = fontName
        endSceneScoreLabel.fontColor = fontColor
        endSceneScoreLabel.fontSize = scoreFontSize
        endSceneScoreLabel.text = scoreLabelPrefix
        endSceneScoreLabel.horizontalAlignmentMode = .center
        endSceneScoreLabel.verticalAlignmentMode = .center
        
        // End scene continue button.
        endSceneSprite.addChild(continueButton)
        continueButton.anchorPoint = CGPoint(x: 1.0, y: 0.0)
        continueButton.size = CGSize(width: continueButtonAspectRatio * continueButtonHeightRelativeToSceneHeight * gameHeight, height: gameHeight * continueButtonHeightRelativeToSceneHeight)
        continueButton.position = CGPoint(x: gameWidth / 2.0, y: gameHeight * (-0.5 + continueButtonBottomMargin))
        continueButton.zPosition = uiLayer
        
        // Hide end scene.
        endSceneSprite.isHidden = true
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented.")
    }
    
    // MARK: Functions
    
    // For initializing the nodes of the game.
    override func didMove(to view: SKView) {
        // Add background image.
        addChild(backgroundSprite)
        
        // Add clipboards.
        for clipboard in clipboards {
            addChild(clipboard)
        }
        
        // Add scorebox.
        addChild(scoreBoxSprite)
        
        // Add end scene.
        addChild(endSceneSprite)
        
        // Start the game.
        nextRound()
    }
    
    // Spawn tiles for the next round.
    func nextRound() {
        currRound += 1
        
        var actionSequence = [SKAction]()
        
        for _ in 0..<tilesPerRound {
            // Tile spawn.
            actionSequence.append(SKAction.run({self.spawnNextTile()}))
            
            // Delay time.
            actionSequence.append(SKAction.wait(forDuration: timeBetweenTileSpawns))
        }
        
        // Delay time to next round.
        actionSequence.append(SKAction.wait(forDuration: timeForTileToReachClipboard - timeBetweenTileSpawns))
        
        // Run action.
        run(SKAction.sequence(actionSequence)) {
            
            // If it is not the last round, spawn next tile.
            if self.currRound + 1 < self.totalRounds {
                self.nextRound()
            } else {
                // Fade in end scene.
                self.endSceneSprite.alpha = 0.0
                self.endSceneSprite.isHidden = false
                self.endSceneScoreLabel.text = self.scoreLabelPrefix + String(self.score)
                self.endSceneSprite.run(SKAction.fadeIn(withDuration: self.endSceneFadeInAnimationDuration)) {
                    self.isContinueButtonInteractable = true
                }
            }
        }
    }
    
    // Spawn the next tile and moving it towards clipboards.
    func spawnNextTile() {
        // Randomize tile spawn. (Avoid spawning the same type / lane in a row)
        var tileTypeIndex: Int
        repeat {
            tileTypeIndex = Int(arc4random_uniform(UInt32(tileTypes.count)))
        } while tileTypeIndex == lastTileTypeIndex
        
        var laneNumber: Int
        repeat {
            laneNumber = Int(arc4random_uniform(UInt32(lanePositionsY.count)))
        } while laneNumber == lastTileLaneNumber
        
        lastTileTypeIndex = tileTypeIndex
        lastTileLaneNumber = laneNumber
        
        let tileType = tileTypes[tileTypeIndex]
        
        // Configure tile.
        let currTile = VocabMatchingTile(matchingID: tileType.0, textureName: tileType.1, size: CGSize(width: Double(size.width) * tileSpriteSizeRelativeToWidth, height: Double(size.width) * tileSpriteSizeRelativeToWidth))
        currTile.laneNumber = laneNumber
        
        // Positioning
        currTile.position = CGPoint(x: Double(size.width) * tileSpriteSpawnPosX, y: Double(size.height) * lanePositionsY[laneNumber])
        currTile.zPosition = tileLayer
        addChild(currTile)
        
        // Spawn and move the tile.
        let destination = CGPoint(x: size.width * CGFloat(tileTouchesClipboardPosX), y: currTile.position.y)
        let moveAction = SKAction.move(to: destination, duration: timeForTileToReachClipboard)
        currTile.run(moveAction) {
            self.checkIfMatches(tile: currTile)
        }
    }
    
    // Check if the tile and the clipboard matches. If so, increment score. Then start the next round.
    func checkIfMatches(tile: VocabMatchingTile) {
        let tileLane = tile.laneNumber
        if tile.matchingID == clipboards[tileLane].matchingID {
            // Is a match. Increment score.
            score += 1
            scoreLabel.text = String(score)
        }
        
        // Remove the current tile.
        tile.removeFromParent()
    }
    
    // After dragging and dropping a clipboard, check which lane is closer, and snap it to the lane and swap the positions. If it isn't dragged to the other lanes, no swapping will be performed, just snap it back to its original lane.
    func snapClipboardToClosestLane(droppedClipboard: VocabMatchingClipboard, dropLocationPosY: Double) {
        // Check which clipboard is being dragged.
        var clipboardIndex = 0
        while clipboards[clipboardIndex] != droppedClipboard {
            clipboardIndex += 1
        }
        
        // Find the closest lane to snap to.
        var closestLaneIndex = 0
        var closestLaneDistance = Double.infinity
        for (index, positionY) in lanePositionsY.enumerated() {
            let distanceToCurrentLane = abs(positionY * Double(size.height) - dropLocationPosY)
            if distanceToCurrentLane < closestLaneDistance {
                closestLaneIndex = index
                closestLaneDistance = distanceToCurrentLane
            }
        }
        
        let snappingDestination = CGPoint(x: Double(size.width) * clipboardSpritePosX, y: Double(size.height) * lanePositionsY[closestLaneIndex])
        
        // Snap to the original lane.
        if clipboardIndex == closestLaneIndex {
            isSwapping = true
            
            // Perform snapping animation.
            let snappingAnimation = SKAction.move(to: snappingDestination, duration: swappingAnimationDuration)
            droppedClipboard.run(snappingAnimation) {
                self.isSwapping = false
            }
        } else {
            // Swap with the clipboard on the other lane.
            isSwapping = true
            
            // The original location of the dropped clipboard.
            let originalLocation = CGPoint(x: Double(size.width) * clipboardSpritePosX, y: Double(size.height) * lanePositionsY[clipboardIndex])
            
            // Perform swapping animation.
            let droppedClipboardSwapAnimation = SKAction.move(to: snappingDestination, duration: swappingAnimationDuration)
            let destinationClipboardSwapAnimation = SKAction.move(to: originalLocation, duration: swappingAnimationDuration)
            
            // Set the dragged clipboard to the front.
            droppedClipboard.zPosition = clipboardDraggingLayer
            
            droppedClipboard.run(droppedClipboardSwapAnimation)
            clipboards[closestLaneIndex].run(destinationClipboardSwapAnimation) {
                // Swap the indices.
                (self.clipboards[closestLaneIndex], self.clipboards[clipboardIndex]) = (self.clipboards[clipboardIndex], self.clipboards[closestLaneIndex])
                
                self.isSwapping = false
                
                // Set the z position back.
                droppedClipboard.zPosition = self.clipboardLayer
            }
        }
    }
    
    // MARK: Touch Inputs
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If the previous swapping animation isn't finished, return.
        if isSwapping { return }
        
        // Only the first touch is effective.
        guard let touch = touches.first else { return }
        
        // Check if the end game continue button is pressed.
        if isContinueButtonInteractable && continueButton.contains(touch.location(in: endSceneSprite)) {
            // End the game, transition to result view controller.
            viewController.endGame()
            
            return
        }
        
        let location = touch.location(in: self)
        
        // Check if the touch lands on a clipboard, if so, start dragging it.
        if let clipboard = atPoint(location) as? VocabMatchingClipboard {
            // Update clipboard's zPosition so that it appears at the front.
            clipboard.zPosition = clipboardDraggingLayer
            
            clipboardDragged = clipboard
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If the previous swapping animation isn't finished, return.
        if isSwapping { return }
        
        // Only the first touch is effective.
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        // If there is a clipboard currently being dragged, update its position.
        if clipboardDragged != nil {
            clipboardDragged!.position = CGPoint(x: CGFloat(clipboardSpritePosX) * size.width, y: location.y)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If the previous swapping animation isn't finished, return.
        if isSwapping { return }
        
        // Only the first touch is effective.
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        // If there is a clipboard currently dragged, drop it.
        if let clipboard = clipboardDragged {
            // Reset cardboard's zPosition.
            clipboard.zPosition = clipboardLayer
            
            // Make the cardboard appear in the front by readding it to the scene.
            clipboard.removeFromParent()
            addChild(clipboard)
            
            // Snap the clipboard.
            snapClipboardToClosestLane(droppedClipboard: clipboard, dropLocationPosY: Double(location.y))
            
            // Stop dragging.
            clipboardDragged = nil
        }
    }
}
