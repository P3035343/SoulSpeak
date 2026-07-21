import SceneKit
import AVFoundation
import UIKit

/// Manages the 3D SceneKit rage room — creates the environment,
/// handles physics, destruction, and sound effects.
@MainActor
class RageRoomSceneManager: ObservableObject {
    let scene = SCNScene()
    let cameraNode = SCNNode()

    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var destructibleNodes: [SCNNode] = []
    private var debrisNodes: [SCNNode] = []

    // MARK: - Setup Room

    func setupRoom() {
        scene.background.contents = UIColor(red: 0.08, green: 0.06, blue: 0.06, alpha: 1)

        setupCamera()
        setupLighting()
        buildRoom()
        addDestructibles()
    }


    // MARK: - Camera
    private func setupCamera() {
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 100
        cameraNode.camera?.fieldOfView = 70
        cameraNode.position = SCNVector3(0, 1.6, 4) // Eye height, standing back
        cameraNode.look(at: SCNVector3(0, 1, 0))
        scene.rootNode.addChildNode(cameraNode)
    }

    // MARK: - Lighting
    private func setupLighting() {
        // Main overhead light (slightly red/warm for rage mood)
        let overheadLight = SCNNode()
        overheadLight.light = SCNLight()
        overheadLight.light?.type = .spot
        overheadLight.light?.color = UIColor(red: 1.0, green: 0.85, blue: 0.7, alpha: 1)
        overheadLight.light?.intensity = 800
        overheadLight.light?.spotInnerAngle = 40
        overheadLight.light?.spotOuterAngle = 80
        overheadLight.light?.castsShadow = true
        overheadLight.position = SCNVector3(0, 3.5, 0)
        overheadLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(overheadLight)

        // Ambient fill
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.color = UIColor(red: 0.3, green: 0.15, blue: 0.1, alpha: 1)
        ambient.light?.intensity = 200
        scene.rootNode.addChildNode(ambient)

        // Red accent light (mood)
        let redLight = SCNNode()
        redLight.light = SCNLight()
        redLight.light?.type = .omni
        redLight.light?.color = UIColor.red
        redLight.light?.intensity = 100
        redLight.position = SCNVector3(-3, 2, -2)
        scene.rootNode.addChildNode(redLight)
    }


    // MARK: - Build Room (Walls, Floor, Ceiling)
    private func buildRoom() {
        let roomSize: Float = 6.0
        let wallHeight: Float = 3.5

        // Floor — dark concrete
        let floor = SCNFloor()
        floor.reflectivity = 0.05
        let floorNode = SCNNode(geometry: floor)
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor(red: 0.15, green: 0.12, blue: 0.1, alpha: 1)
        floorMaterial.roughness.contents = 0.9
        floor.materials = [floorMaterial]
        floorNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(floorNode)

        // Walls — dark grey/brick color
        let wallMaterial = SCNMaterial()
        wallMaterial.diffuse.contents = UIColor(red: 0.2, green: 0.18, blue: 0.16, alpha: 1)
        wallMaterial.roughness.contents = 0.85

        // Back wall
        let backWall = SCNBox(width: CGFloat(roomSize), height: CGFloat(wallHeight), length: 0.2, chamferRadius: 0)
        backWall.materials = [wallMaterial]
        let backNode = SCNNode(geometry: backWall)
        backNode.position = SCNVector3(0, wallHeight / 2, -roomSize / 2)
        backNode.physicsBody = SCNPhysicsBody.static()
        backNode.name = "wall_back"
        scene.rootNode.addChildNode(backNode)

        // Left wall
        let leftWall = SCNBox(width: 0.2, height: CGFloat(wallHeight), length: CGFloat(roomSize), chamferRadius: 0)
        leftWall.materials = [wallMaterial]
        let leftNode = SCNNode(geometry: leftWall)
        leftNode.position = SCNVector3(-roomSize / 2, wallHeight / 2, 0)
        leftNode.physicsBody = SCNPhysicsBody.static()
        leftNode.name = "wall_left"
        scene.rootNode.addChildNode(leftNode)

        // Right wall
        let rightWall = SCNBox(width: 0.2, height: CGFloat(wallHeight), length: CGFloat(roomSize), chamferRadius: 0)
        rightWall.materials = [wallMaterial]
        let rightNode = SCNNode(geometry: rightWall)
        rightNode.position = SCNVector3(roomSize / 2, wallHeight / 2, 0)
        rightNode.physicsBody = SCNPhysicsBody.static()
        rightNode.name = "wall_right"
        scene.rootNode.addChildNode(rightNode)
    }


    // MARK: - Add Destructible Objects
    private func addDestructibles() {
        // Try loading .usdz models first, fall back to primitives
        addPunchingBag()
        addPlates()
        addWindow()
        addShelf()
        addChair()
    }

    private func addPunchingBag() {
        // Try loading 3D model
        if let modelScene = try? SCNScene(url: Bundle.main.url(forResource: "punching_bag", withExtension: "usdz")!) {
            let node = modelScene.rootNode.clone()
            node.position = SCNVector3(-1.5, 2, -2)
            node.name = "punching_bag"
            scene.rootNode.addChildNode(node)
            destructibleNodes.append(node)
        } else {
            // Fallback: cylinder shaped like a punching bag
            let bag = SCNCylinder(radius: 0.3, height: 1.2)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor(red: 0.6, green: 0.15, blue: 0.1, alpha: 1)
            material.roughness.contents = 0.7
            bag.materials = [material]
            let node = SCNNode(geometry: bag)
            node.position = SCNVector3(-1.5, 2, -2)
            node.physicsBody = SCNPhysicsBody.dynamic()
            node.physicsBody?.mass = 30
            node.physicsBody?.damping = 0.8
            node.name = "punching_bag"
            scene.rootNode.addChildNode(node)
            destructibleNodes.append(node)

            // Chain
            let chain = SCNCylinder(radius: 0.02, height: 0.8)
            let chainMat = SCNMaterial()
            chainMat.diffuse.contents = UIColor.darkGray
            chainMat.metalness.contents = 0.9
            chain.materials = [chainMat]
            let chainNode = SCNNode(geometry: chain)
            chainNode.position = SCNVector3(-1.5, 3, -2)
            scene.rootNode.addChildNode(chainNode)
        }
    }

    private func addPlates() {
        // Stack of plates on a shelf
        for i in 0..<5 {
            let plate = SCNCylinder(radius: 0.15, height: 0.02)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.white
            material.roughness.contents = 0.2
            plate.materials = [material]
            let node = SCNNode(geometry: plate)
            node.position = SCNVector3(1.8, 1.2 + Float(i) * 0.05, -2.5)
            node.physicsBody = SCNPhysicsBody.dynamic()
            node.physicsBody?.mass = 0.5
            node.name = "plate_\(i)"
            scene.rootNode.addChildNode(node)
            destructibleNodes.append(node)
        }
    }

    private func addWindow() {
        // Glass window on back wall
        let glass = SCNBox(width: 1.2, height: 0.8, length: 0.02, chamferRadius: 0)
        let glassMat = SCNMaterial()
        glassMat.diffuse.contents = UIColor(red: 0.7, green: 0.85, blue: 0.95, alpha: 0.5)
        glassMat.transparency = 0.4
        glassMat.roughness.contents = 0.05
        glass.materials = [glassMat]
        let windowNode = SCNNode(geometry: glass)
        windowNode.position = SCNVector3(0, 2, -2.9)
        windowNode.physicsBody = SCNPhysicsBody.dynamic()
        windowNode.physicsBody?.mass = 2
        windowNode.name = "window"
        scene.rootNode.addChildNode(windowNode)
        destructibleNodes.append(windowNode)

        // Window frame
        let frame = SCNBox(width: 1.3, height: 0.9, length: 0.05, chamferRadius: 0)
        let frameMat = SCNMaterial()
        frameMat.diffuse.contents = UIColor(red: 0.3, green: 0.2, blue: 0.15, alpha: 1)
        frame.materials = [frameMat]
        let frameNode = SCNNode(geometry: frame)
        frameNode.position = SCNVector3(0, 2, -2.92)
        scene.rootNode.addChildNode(frameNode)
    }


    private func addShelf() {
        let shelf = SCNBox(width: 1.5, height: 0.05, length: 0.4, chamferRadius: 0)
        let shelfMat = SCNMaterial()
        shelfMat.diffuse.contents = UIColor(red: 0.35, green: 0.22, blue: 0.12, alpha: 1)
        shelf.materials = [shelfMat]
        let shelfNode = SCNNode(geometry: shelf)
        shelfNode.position = SCNVector3(1.8, 1.15, -2.5)
        shelfNode.physicsBody = SCNPhysicsBody.static()
        shelfNode.name = "shelf"
        scene.rootNode.addChildNode(shelfNode)
    }

    private func addChair() {
        // Simple chair geometry
        let seat = SCNBox(width: 0.5, height: 0.05, length: 0.5, chamferRadius: 0.02)
        let chairMat = SCNMaterial()
        chairMat.diffuse.contents = UIColor(red: 0.4, green: 0.25, blue: 0.15, alpha: 1)
        seat.materials = [chairMat]
        let chairNode = SCNNode(geometry: seat)
        chairNode.position = SCNVector3(1.0, 0.5, -0.5)
        chairNode.physicsBody = SCNPhysicsBody.dynamic()
        chairNode.physicsBody?.mass = 5
        chairNode.name = "chair"
        scene.rootNode.addChildNode(chairNode)
        destructibleNodes.append(chairNode)

        // Chair legs
        for (x, z) in [(-0.2, -0.2), (0.2, -0.2), (-0.2, 0.2), (0.2, 0.2)] as [(Float, Float)] {
            let leg = SCNCylinder(radius: 0.025, height: 0.5)
            leg.materials = [chairMat]
            let legNode = SCNNode(geometry: leg)
            legNode.position = SCNVector3(1.0 + x, 0.25, -0.5 + z)
            scene.rootNode.addChildNode(legNode)
        }
    }

    // MARK: - Hit Object (Tap)
    func hitObject(with tool: RageTool) {
        playSound(tool.soundFile)
        hapticFeedback(style: tool == .sledgehammer ? .heavy : .medium)

        // Apply force to nearest destructible
        guard let target = destructibleNodes.randomElement() else { return }

        let force = SCNVector3(
            Float.random(in: -3...3),
            Float.random(in: 2...5),
            Float.random(in: -2...2)
        )

        let multiplier: Float = tool == .sledgehammer ? 3.0 : tool == .fists ? 1.5 : 2.0
        let scaledForce = SCNVector3(force.x * multiplier, force.y * multiplier, force.z * multiplier)

        target.physicsBody?.applyForce(scaledForce, asImpulse: true)
        target.physicsBody?.applyTorque(SCNVector4(0, 1, 0, Float.random(in: -5...5)), asImpulse: true)

        // Spawn debris
        spawnDebris(at: target.position, tool: tool)
    }


    // MARK: - Swipe Action (Drag)
    func swipeAction(translation: CGSize, tool: RageTool) {
        // Swipe creates directional force
        if tool == .spray {
            // Spray paint — add colored marks
            spawnSprayMark(at: SCNVector3(Float(translation.width) * 0.003, 1.5, -2.8))
        }
    }

    func endSwipe(tool: RageTool) {
        if tool != .spray {
            playSound(tool.soundFile)
            hapticFeedback(style: .medium)

            // Throw the nearest plate or object
            if tool == .throwPlates {
                if let plate = destructibleNodes.first(where: { $0.name?.contains("plate") == true }) {
                    let throwForce = SCNVector3(Float.random(in: -2...2), Float.random(in: 1...3), Float.random(in: -8...-4))
                    plate.physicsBody?.applyForce(throwForce, asImpulse: true)
                    plate.physicsBody?.applyTorque(SCNVector4(1, 0, 0, 10), asImpulse: true)
                }
            }
        }
    }

    // MARK: - Spawn Debris
    private func spawnDebris(at position: SCNVector3, tool: RageTool) {
        let count = tool == .sledgehammer ? 8 : 4
        for _ in 0..<count {
            let size = CGFloat.random(in: 0.02...0.08)
            let debris = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
            let debrisMat = SCNMaterial()
            debrisMat.diffuse.contents = UIColor(
                red: CGFloat.random(in: 0.3...0.6),
                green: CGFloat.random(in: 0.2...0.4),
                blue: CGFloat.random(in: 0.1...0.3),
                alpha: 1
            )
            debris.materials = [debrisMat]
            let node = SCNNode(geometry: debris)
            node.position = SCNVector3(
                position.x + Float.random(in: -0.3...0.3),
                position.y + Float.random(in: 0...0.5),
                position.z + Float.random(in: -0.3...0.3)
            )
            node.physicsBody = SCNPhysicsBody.dynamic()
            node.physicsBody?.mass = 0.1
            let force = SCNVector3(Float.random(in: -2...2), Float.random(in: 1...4), Float.random(in: -2...2))
            node.physicsBody?.applyForce(force, asImpulse: true)
            scene.rootNode.addChildNode(node)
            debrisNodes.append(node)
        }
    }

    // MARK: - Spray Paint
    private func spawnSprayMark(at position: SCNVector3) {
        let dot = SCNSphere(radius: 0.05)
        let dotMat = SCNMaterial()
        dotMat.diffuse.contents = UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 0.8
        )
        dot.materials = [dotMat]
        let node = SCNNode(geometry: dot)
        node.position = position
        scene.rootNode.addChildNode(node)
    }


    // MARK: - Sound Effects
    private func playSound(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("[SoulSpeak] Sound not found: \(name).mp3")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.8
            player.play()
            audioPlayers[name] = player
        } catch {
            print("[SoulSpeak] Sound playback error: \(error)")
        }
    }

    // MARK: - Haptic Feedback
    private func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
