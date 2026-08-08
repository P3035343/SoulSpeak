import SceneKit
import AVFoundation
import UIKit

/// Manages the 3D SceneKit rage room — bright industrial space with
/// destructible objects: ragdoll dummy, tires, bottles, TV, table, plates.
/// Red accent lighting for mood. Physics-based destruction with haptics.
@MainActor
class RageRoomSceneManager: ObservableObject {
    let scene = SCNScene()
    let cameraNode = SCNNode()

    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var destructibleNodes: [SCNNode] = []
    private var debrisNodes: [SCNNode] = []

    // MARK: - Setup Room

    func setupRoom() {
        scene.background.contents = UIColor(red: 0.15, green: 0.12, blue: 0.1, alpha: 1)

        setupCamera()
        setupLighting()
        buildRoom()
        addDummy()
        addTires()
        addTable()
        addBottles()
        addTV()
        addPlates()
    }

    // MARK: - Camera
    private func setupCamera() {
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 100
        cameraNode.camera?.fieldOfView = 65
        cameraNode.position = SCNVector3(0, 1.7, 5)
        cameraNode.look(at: SCNVector3(0, 1.2, 0))
        scene.rootNode.addChildNode(cameraNode)
    }

    // MARK: - Lighting (BRIGHT - easy to see everything)
    private func setupLighting() {
        // Main overhead fluorescent-style light (bright white)
        let overheadLight = SCNNode()
        overheadLight.light = SCNLight()
        overheadLight.light?.type = .spot
        overheadLight.light?.color = UIColor(red: 1.0, green: 0.95, blue: 0.9, alpha: 1)
        overheadLight.light?.intensity = 1500
        overheadLight.light?.spotInnerAngle = 50
        overheadLight.light?.spotOuterAngle = 90
        overheadLight.light?.castsShadow = true
        overheadLight.light?.shadowRadius = 4
        overheadLight.position = SCNVector3(0, 4.0, 2)
        overheadLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(overheadLight)

        // Second overhead light (back of room)
        let overheadLight2 = SCNNode()
        overheadLight2.light = SCNLight()
        overheadLight2.light?.type = .spot
        overheadLight2.light?.color = UIColor(red: 1.0, green: 0.95, blue: 0.9, alpha: 1)
        overheadLight2.light?.intensity = 1200
        overheadLight2.light?.spotInnerAngle = 40
        overheadLight2.light?.spotOuterAngle = 80
        overheadLight2.light?.castsShadow = true
        overheadLight2.position = SCNVector3(0, 4.0, -2)
        overheadLight2.look(at: SCNVector3(0, 0, -2))
        scene.rootNode.addChildNode(overheadLight2)

        // Strong ambient fill (so nothing is too dark)
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.color = UIColor(red: 0.5, green: 0.4, blue: 0.35, alpha: 1)
        ambient.light?.intensity = 500
        scene.rootNode.addChildNode(ambient)

        // RED accent light (left wall — rage mood)
        let redLight = SCNNode()
        redLight.light = SCNLight()
        redLight.light?.type = .omni
        redLight.light?.color = UIColor(red: 1.0, green: 0.1, blue: 0.05, alpha: 1)
        redLight.light?.intensity = 400
        redLight.position = SCNVector3(-3, 2.5, -1)
        scene.rootNode.addChildNode(redLight)

        // RED accent light (right wall)
        let redLight2 = SCNNode()
        redLight2.light = SCNLight()
        redLight2.light?.type = .omni
        redLight2.light?.color = UIColor(red: 1.0, green: 0.15, blue: 0.05, alpha: 1)
        redLight2.light?.intensity = 300
        redLight2.position = SCNVector3(3, 2.5, -1)
        scene.rootNode.addChildNode(redLight2)
    }

    // MARK: - Build Room (Industrial Rage Room)
    private func buildRoom() {
        let roomWidth: Float = 7.0
        let roomDepth: Float = 8.0
        let wallHeight: Float = 4.0

        // Floor — concrete grey
        let floor = SCNFloor()
        floor.reflectivity = 0.1
        let floorNode = SCNNode(geometry: floor)
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor(red: 0.35, green: 0.32, blue: 0.3, alpha: 1)
        floorMaterial.roughness.contents = 0.85
        floor.materials = [floorMaterial]
        floorNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(floorNode)

        // Wall material — OSB/plywood panels (like in the reference image)
        let wallMaterial = SCNMaterial()
        wallMaterial.diffuse.contents = UIColor(red: 0.55, green: 0.45, blue: 0.3, alpha: 1)
        wallMaterial.roughness.contents = 0.9

        // Red stripe material (accent strips on walls)
        let redStripeMaterial = SCNMaterial()
        redStripeMaterial.diffuse.contents = UIColor(red: 0.85, green: 0.1, blue: 0.1, alpha: 1)

        // Back wall
        let backWall = SCNBox(width: CGFloat(roomWidth), height: CGFloat(wallHeight), length: 0.2, chamferRadius: 0)
        backWall.materials = [wallMaterial]
        let backNode = SCNNode(geometry: backWall)
        backNode.position = SCNVector3(0, wallHeight / 2, -roomDepth / 2)
        backNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(backNode)

        // Left wall
        let leftWall = SCNBox(width: 0.2, height: CGFloat(wallHeight), length: CGFloat(roomDepth), chamferRadius: 0)
        leftWall.materials = [wallMaterial]
        let leftNode = SCNNode(geometry: leftWall)
        leftNode.position = SCNVector3(-roomWidth / 2, wallHeight / 2, 0)
        leftNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(leftNode)

        // Right wall
        let rightWall = SCNBox(width: 0.2, height: CGFloat(wallHeight), length: CGFloat(roomDepth), chamferRadius: 0)
        rightWall.materials = [wallMaterial]
        let rightNode = SCNNode(geometry: rightWall)
        rightNode.position = SCNVector3(roomWidth / 2, wallHeight / 2, 0)
        rightNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(rightNode)

        // Red accent stripes on walls
        for x: Float in [-3.4, 3.4] {
            let stripe = SCNBox(width: 0.15, height: CGFloat(wallHeight), length: 0.05, chamferRadius: 0)
            stripe.materials = [redStripeMaterial]
            let stripeNode = SCNNode(geometry: stripe)
            stripeNode.position = SCNVector3(x, wallHeight / 2, -roomDepth / 2 + 0.15)
            scene.rootNode.addChildNode(stripeNode)
        }
    }

    // MARK: - Ragdoll Dummy (punching mannequin)
    private func addDummy() {
        // Skin-colored material
        let skinMat = SCNMaterial()
        skinMat.diffuse.contents = UIColor(red: 0.85, green: 0.7, blue: 0.6, alpha: 1)
        skinMat.roughness.contents = 0.7

        // Torso
        let torso = SCNCylinder(radius: 0.25, height: 0.8)
        torso.materials = [skinMat]
        let torsoNode = SCNNode(geometry: torso)
        torsoNode.position = SCNVector3(0, 1.4, -2.5)
        torsoNode.physicsBody = SCNPhysicsBody.dynamic()
        torsoNode.physicsBody?.mass = 20
        torsoNode.physicsBody?.damping = 0.7
        torsoNode.physicsBody?.angularDamping = 0.8
        torsoNode.name = "dummy_torso"
        scene.rootNode.addChildNode(torsoNode)
        destructibleNodes.append(torsoNode)

        // Head
        let head = SCNSphere(radius: 0.18)
        head.materials = [skinMat]
        let headNode = SCNNode(geometry: head)
        headNode.position = SCNVector3(0, 2.0, -2.5)
        headNode.physicsBody = SCNPhysicsBody.dynamic()
        headNode.physicsBody?.mass = 5
        headNode.physicsBody?.damping = 0.5
        headNode.name = "dummy_head"
        scene.rootNode.addChildNode(headNode)
        destructibleNodes.append(headNode)

        // Arms (cylinders)
        for xOffset: Float in [-0.4, 0.4] {
            let arm = SCNCylinder(radius: 0.08, height: 0.6)
            arm.materials = [skinMat]
            let armNode = SCNNode(geometry: arm)
            armNode.position = SCNVector3(xOffset, 1.4, -2.5)
            armNode.eulerAngles.z = xOffset > 0 ? -0.3 : 0.3
            armNode.physicsBody = SCNPhysicsBody.dynamic()
            armNode.physicsBody?.mass = 3
            armNode.name = "dummy_arm"
            scene.rootNode.addChildNode(armNode)
            destructibleNodes.append(armNode)
        }

        // Stand/pole
        let pole = SCNCylinder(radius: 0.05, height: 1.2)
        let metalMat = SCNMaterial()
        metalMat.diffuse.contents = UIColor.darkGray
        metalMat.metalness.contents = 0.8
        pole.materials = [metalMat]
        let poleNode = SCNNode(geometry: pole)
        poleNode.position = SCNVector3(0, 0.6, -2.5)
        poleNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(poleNode)

        // Base
        let base = SCNCylinder(radius: 0.35, height: 0.05)
        base.materials = [metalMat]
        let baseNode = SCNNode(geometry: base)
        baseNode.position = SCNVector3(0, 0.025, -2.5)
        baseNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(baseNode)
    }

    // MARK: - Tires
    private func addTires() {
        let tireMat = SCNMaterial()
        tireMat.diffuse.contents = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        tireMat.roughness.contents = 0.95

        // Stack of tires against left wall
        for i in 0..<3 {
            let tire = SCNTorus(ringRadius: 0.35, pipeRadius: 0.12)
            tire.materials = [tireMat]
            let tireNode = SCNNode(geometry: tire)
            tireNode.position = SCNVector3(-2.5, 0.35 + Float(i) * 0.3, -2.0)
            tireNode.eulerAngles.x = .pi / 2
            tireNode.physicsBody = SCNPhysicsBody.dynamic()
            tireNode.physicsBody?.mass = 8
            tireNode.physicsBody?.friction = 0.8
            tireNode.name = "tire_\(i)"
            scene.rootNode.addChildNode(tireNode)
            destructibleNodes.append(tireNode)
        }
    }

    // MARK: - Table with items
    private func addTable() {
        let woodMat = SCNMaterial()
        woodMat.diffuse.contents = UIColor(red: 0.3, green: 0.2, blue: 0.12, alpha: 1)
        woodMat.roughness.contents = 0.8

        // Table top
        let tableTop = SCNBox(width: 1.8, height: 0.06, length: 0.8, chamferRadius: 0.01)
        tableTop.materials = [woodMat]
        let tableNode = SCNNode(geometry: tableTop)
        tableNode.position = SCNVector3(2.0, 0.85, -1.5)
        tableNode.physicsBody = SCNPhysicsBody.static()
        tableNode.name = "table"
        scene.rootNode.addChildNode(tableNode)

        // Table legs
        let legMat = SCNMaterial()
        legMat.diffuse.contents = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        legMat.metalness.contents = 0.7

        for (x, z) in [(-0.7, -0.3), (0.7, -0.3), (-0.7, 0.3), (0.7, 0.3)] as [(Float, Float)] {
            let leg = SCNCylinder(radius: 0.03, height: 0.85)
            leg.materials = [legMat]
            let legNode = SCNNode(geometry: leg)
            legNode.position = SCNVector3(2.0 + x, 0.425, -1.5 + z)
            legNode.physicsBody = SCNPhysicsBody.static()
            scene.rootNode.addChildNode(legNode)
        }
    }

    // MARK: - Bottles (on table)
    private func addBottles() {
        let glassMat = SCNMaterial()
        glassMat.diffuse.contents = UIColor(red: 0.2, green: 0.5, blue: 0.2, alpha: 0.7)
        glassMat.transparency = 0.6
        glassMat.roughness.contents = 0.1

        for i in 0..<4 {
            let bottle = SCNCylinder(radius: 0.04, height: 0.25)
            bottle.materials = [glassMat]
            let bottleNode = SCNNode(geometry: bottle)
            bottleNode.position = SCNVector3(
                1.5 + Float(i) * 0.3,
                1.0,
                -1.5
            )
            bottleNode.physicsBody = SCNPhysicsBody.dynamic()
            bottleNode.physicsBody?.mass = 0.8
            bottleNode.physicsBody?.friction = 0.3
            bottleNode.name = "bottle_\(i)"
            scene.rootNode.addChildNode(bottleNode)
            destructibleNodes.append(bottleNode)
        }
    }

    // MARK: - TV/Monitor (to smash)
    private func addTV() {
        // TV body
        let tvMat = SCNMaterial()
        tvMat.diffuse.contents = UIColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1)
        tvMat.roughness.contents = 0.3

        let screenMat = SCNMaterial()
        screenMat.diffuse.contents = UIColor(red: 0.05, green: 0.1, blue: 0.2, alpha: 1)
        screenMat.roughness.contents = 0.05
        screenMat.emission.contents = UIColor(red: 0.0, green: 0.05, blue: 0.1, alpha: 1)

        let tv = SCNBox(width: 0.8, height: 0.5, length: 0.08, chamferRadius: 0.01)
        tv.materials = [screenMat, tvMat, tvMat, tvMat, tvMat, tvMat]
        let tvNode = SCNNode(geometry: tv)
        tvNode.position = SCNVector3(-2.0, 1.5, -3.5)
        tvNode.physicsBody = SCNPhysicsBody.dynamic()
        tvNode.physicsBody?.mass = 8
        tvNode.name = "tv"
        scene.rootNode.addChildNode(tvNode)
        destructibleNodes.append(tvNode)

        // TV stand
        let standMat = SCNMaterial()
        standMat.diffuse.contents = UIColor.darkGray
        standMat.metalness.contents = 0.8
        let stand = SCNCylinder(radius: 0.04, height: 0.5)
        stand.materials = [standMat]
        let standNode = SCNNode(geometry: stand)
        standNode.position = SCNVector3(-2.0, 1.0, -3.5)
        standNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(standNode)
    }

    // MARK: - Plates (on shelf)
    private func addPlates() {
        for i in 0..<6 {
            let plate = SCNCylinder(radius: 0.13, height: 0.015)
            let plateMat = SCNMaterial()
            plateMat.diffuse.contents = UIColor.white
            plateMat.roughness.contents = 0.15
            plate.materials = [plateMat]
            let node = SCNNode(geometry: plate)
            node.position = SCNVector3(2.0 + Float(i % 3) * 0.3 - 0.3, 0.92 + Float(i / 3) * 0.02, -1.5)
            node.physicsBody = SCNPhysicsBody.dynamic()
            node.physicsBody?.mass = 0.4
            node.physicsBody?.friction = 0.2
            node.name = "plate_\(i)"
            scene.rootNode.addChildNode(node)
            destructibleNodes.append(node)
        }
    }

    // MARK: - Hit Object (Tap)
    func hitObject(with tool: RageTool) {
        triggerHaptic(tool: tool)

        // Apply force to nearest destructible
        guard let target = destructibleNodes.randomElement() else { return }

        let force = SCNVector3(
            Float.random(in: -4...4),
            Float.random(in: 2...6),
            Float.random(in: -3...3)
        )

        let multiplier: Float
        switch tool {
        case .sledgehammer: multiplier = 4.0
        case .bat: multiplier = 3.0
        case .throwPlates: multiplier = 2.5
        case .fists: multiplier = 2.0
        case .spray: multiplier = 0
        }

        if multiplier > 0 {
            let scaledForce = SCNVector3(force.x * multiplier, force.y * multiplier, force.z * multiplier)
            target.physicsBody?.applyForce(scaledForce, asImpulse: true)
            target.physicsBody?.applyTorque(SCNVector4(
                Float.random(in: -1...1),
                Float.random(in: -1...1),
                Float.random(in: -1...1),
                Float.random(in: -8...8)
            ), asImpulse: true)

            // Spawn debris on hard hits
            if tool == .sledgehammer || tool == .bat {
                spawnDebris(at: target.position, tool: tool)
            }
        }
    }

    // MARK: - Swipe Action (Drag)
    func swipeAction(translation: CGSize, tool: RageTool) {
        if tool == .spray {
            spawnSprayMark(at: SCNVector3(Float(translation.width) * 0.003, 1.5, -3.8))
        }
    }

    func endSwipe(tool: RageTool) {
        if tool == .throwPlates {
            triggerHaptic(tool: tool)
            if let plate = destructibleNodes.first(where: { $0.name?.contains("plate") == true || $0.name?.contains("bottle") == true }) {
                let throwForce = SCNVector3(
                    Float.random(in: -3...3),
                    Float.random(in: 1...4),
                    Float.random(in: (-10)...(-5))
                )
                plate.physicsBody?.applyForce(throwForce, asImpulse: true)
                plate.physicsBody?.applyTorque(SCNVector4(1, 0, 0, 15), asImpulse: true)
            }
        } else if tool != .spray {
            triggerHaptic(tool: tool)
            hitObject(with: tool)
        }
    }

    // MARK: - Haptic Feedback + Sound
    private func triggerHaptic(tool: RageTool) {
        let style: UIImpactFeedbackGenerator.FeedbackStyle
        switch tool {
        case .sledgehammer: style = .heavy
        case .bat: style = .heavy
        case .fists: style = .medium
        case .throwPlates: style = .light
        case .spray: style = .soft
        }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred(intensity: 1.0)

        // Try to play sound file, fall back to system sound
        let soundName = tool.soundFile
        if let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = 0.9
                player.play()
                audioPlayers[soundName] = player
            } catch {
                playSystemSound(for: tool)
            }
        } else {
            playSystemSound(for: tool)
        }
    }

    private func playSystemSound(for tool: RageTool) {
        // Use system sounds as fallback when mp3 files aren't available
        let soundID: UInt32
        switch tool {
        case .sledgehammer: soundID = 1104  // heavy impact
        case .bat: soundID = 1104
        case .fists: soundID = 1103  // medium tap
        case .throwPlates: soundID = 1105  // glass break-like
        case .spray: soundID = 1100  // subtle
        }
        AudioServicesPlaySystemSound(SystemSoundID(soundID))
    }

    // MARK: - Spawn Debris
    private func spawnDebris(at position: SCNVector3, tool: RageTool) {
        let count = tool == .sledgehammer ? 10 : 6
        for _ in 0..<count {
            let size = CGFloat.random(in: 0.02...0.1)
            let debris: SCNGeometry
            if Bool.random() {
                debris = SCNBox(width: size, height: size * 0.6, length: size * 0.8, chamferRadius: 0)
            } else {
                debris = SCNSphere(radius: size * 0.4)
            }
            let debrisMat = SCNMaterial()
            debrisMat.diffuse.contents = UIColor(
                red: CGFloat.random(in: 0.3...0.7),
                green: CGFloat.random(in: 0.2...0.5),
                blue: CGFloat.random(in: 0.1...0.3),
                alpha: 1
            )
            debris.materials = [debrisMat]
            let node = SCNNode(geometry: debris)
            node.position = SCNVector3(
                position.x + Float.random(in: -0.4...0.4),
                position.y + Float.random(in: 0...0.6),
                position.z + Float.random(in: -0.4...0.4)
            )
            node.physicsBody = SCNPhysicsBody.dynamic()
            node.physicsBody?.mass = 0.05
            let force = SCNVector3(
                Float.random(in: -3...3),
                Float.random(in: 2...5),
                Float.random(in: -3...3)
            )
            node.physicsBody?.applyForce(force, asImpulse: true)
            scene.rootNode.addChildNode(node)
            debrisNodes.append(node)
        }

        // Clean up old debris after 8 seconds
        if debrisNodes.count > 50 {
            let toRemove = debrisNodes.prefix(20)
            for node in toRemove {
                node.removeFromParentNode()
            }
            debrisNodes.removeFirst(20)
        }
    }

    // MARK: - Spray Paint
    private func spawnSprayMark(at position: SCNVector3) {
        let dot = SCNSphere(radius: CGFloat.random(in: 0.03...0.08))
        let dotMat = SCNMaterial()
        dotMat.diffuse.contents = UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 0.9
        )
        dotMat.emission.contents = dotMat.diffuse.contents
        dot.materials = [dotMat]
        let node = SCNNode(geometry: dot)
        node.position = position
        scene.rootNode.addChildNode(node)
    }
}
