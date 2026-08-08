import SceneKit
import AVFoundation
import UIKit

/// Manages the 3D SceneKit rage room - industrial warehouse with concrete walls,
/// exposed pipes/beams, destructible objects: ragdoll dummy, tires, bottles, TV,
/// table, dining set, picture frames, plates. Red accent lighting for mood.
/// Physics-based destruction with haptics, spray paint on walls, and varied sound effects.
@MainActor
class RageRoomSceneManager: ObservableObject {
    let scene = SCNScene()
    let cameraNode = SCNNode()

    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var destructibleNodes: [SCNNode] = []
    private var debrisNodes: [SCNNode] = []
    private var sprayNodes: [SCNNode] = []
    private var currentSprayColor: UIColor = .red
    private var backWallNode: SCNNode?
    private var leftWallNode: SCNNode?
    private var rightWallNode: SCNNode?

    // MARK: - Setup Room

    func setupRoom() {
        scene.background.contents = UIColor(red: 0.08, green: 0.07, blue: 0.06, alpha: 1)

        setupCamera()
        setupLighting()
        buildRoom()
        addCeilingBeams()
        addExposedPipes()
        addDummy()
        addTires()
        addTable()
        addDiningSet()
        addBottles()
        addTV()
        addPlates()
        addPictureFrames()
        startBackgroundMusic()
    }

    // MARK: - Background Music
    private func startBackgroundMusic() {
        AudioPlayerService.shared.playBackgroundMusic(fileName: "rock_instrumental")
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

    // MARK: - Lighting (Industrial mood - darker with red accents)
    private func setupLighting() {
        // Main overhead industrial light (slightly dim, warm)
        let overheadLight = SCNNode()
        overheadLight.light = SCNLight()
        overheadLight.light?.type = .spot
        overheadLight.light?.color = UIColor(red: 1.0, green: 0.9, blue: 0.75, alpha: 1)
        overheadLight.light?.intensity = 1200
        overheadLight.light?.spotInnerAngle = 40
        overheadLight.light?.spotOuterAngle = 80
        overheadLight.light?.castsShadow = true
        overheadLight.light?.shadowRadius = 6
        overheadLight.position = SCNVector3(0, 4.0, 2)
        overheadLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(overheadLight)

        // Second overhead light (back of room, dimmer)
        let overheadLight2 = SCNNode()
        overheadLight2.light = SCNLight()
        overheadLight2.light?.type = .spot
        overheadLight2.light?.color = UIColor(red: 1.0, green: 0.85, blue: 0.7, alpha: 1)
        overheadLight2.light?.intensity = 800
        overheadLight2.light?.spotInnerAngle = 35
        overheadLight2.light?.spotOuterAngle = 70
        overheadLight2.light?.castsShadow = true
        overheadLight2.position = SCNVector3(0, 4.0, -2)
        overheadLight2.look(at: SCNVector3(0, 0, -2))
        scene.rootNode.addChildNode(overheadLight2)

        // Dim ambient fill (industrial dark)
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.color = UIColor(red: 0.25, green: 0.2, blue: 0.18, alpha: 1)
        ambient.light?.intensity = 400
        scene.rootNode.addChildNode(ambient)

        // RED overhead accent light (left - rage mood, like red ceiling strip)
        let redLight = SCNNode()
        redLight.light = SCNLight()
        redLight.light?.type = .omni
        redLight.light?.color = UIColor(red: 1.0, green: 0.05, blue: 0.02, alpha: 1)
        redLight.light?.intensity = 600
        redLight.light?.attenuationStartDistance = 1.0
        redLight.light?.attenuationEndDistance = 6.0
        redLight.position = SCNVector3(-2, 3.8, -1)
        scene.rootNode.addChildNode(redLight)

        // RED overhead accent light (right)
        let redLight2 = SCNNode()
        redLight2.light = SCNLight()
        redLight2.light?.type = .omni
        redLight2.light?.color = UIColor(red: 1.0, green: 0.08, blue: 0.02, alpha: 1)
        redLight2.light?.intensity = 500
        redLight2.light?.attenuationStartDistance = 1.0
        redLight2.light?.attenuationEndDistance = 6.0
        redLight2.position = SCNVector3(2, 3.8, -1)
        scene.rootNode.addChildNode(redLight2)

        // Additional red accent on back wall
        let redLight3 = SCNNode()
        redLight3.light = SCNLight()
        redLight3.light?.type = .spot
        redLight3.light?.color = UIColor(red: 1.0, green: 0.1, blue: 0.05, alpha: 1)
        redLight3.light?.intensity = 400
        redLight3.light?.spotInnerAngle = 20
        redLight3.light?.spotOuterAngle = 50
        redLight3.position = SCNVector3(0, 3.5, 0)
        redLight3.look(at: SCNVector3(0, 1.5, -4))
        scene.rootNode.addChildNode(redLight3)
    }

    // MARK: - Build Room (Industrial Concrete Warehouse)
    private func buildRoom() {
        let roomWidth: Float = 8.0
        let roomDepth: Float = 9.0
        let wallHeight: Float = 4.5

        // Floor - dark stained concrete with cracks
        let floor = SCNFloor()
        floor.reflectivity = 0.05
        let floorNode = SCNNode(geometry: floor)
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor(red: 0.18, green: 0.16, blue: 0.15, alpha: 1)
        floorMaterial.roughness.contents = 0.95
        floor.materials = [floorMaterial]
        floorNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(floorNode)

        // Scattered floor debris (small concrete chunks)
        for _ in 0..<12 {
            let chunk = SCNBox(
                width: CGFloat.random(in: 0.05...0.15),
                height: CGFloat.random(in: 0.02...0.06),
                length: CGFloat.random(in: 0.05...0.12),
                chamferRadius: 0
            )
            let chunkMat = SCNMaterial()
            chunkMat.diffuse.contents = UIColor(
                red: CGFloat.random(in: 0.2...0.4),
                green: CGFloat.random(in: 0.18...0.35),
                blue: CGFloat.random(in: 0.16...0.3),
                alpha: 1
            )
            chunkMat.roughness.contents = 0.9
            chunk.materials = [chunkMat]
            let chunkNode = SCNNode(geometry: chunk)
            chunkNode.position = SCNVector3(
                Float.random(in: -3...3),
                0.02,
                Float.random(in: -3...2)
            )
            chunkNode.eulerAngles.y = Float.random(in: 0...(.pi * 2))
            scene.rootNode.addChildNode(chunkNode)
        }

        // Concrete panel wall material - grey with subtle texture variation
        let concreteMaterial = SCNMaterial()
        concreteMaterial.diffuse.contents = UIColor(red: 0.38, green: 0.36, blue: 0.34, alpha: 1)
        concreteMaterial.roughness.contents = 0.92
        concreteMaterial.normal.intensity = 0.3

        // Darker concrete for variation
        let darkConcreteMaterial = SCNMaterial()
        darkConcreteMaterial.diffuse.contents = UIColor(red: 0.28, green: 0.26, blue: 0.25, alpha: 1)
        darkConcreteMaterial.roughness.contents = 0.95

        // Red stripe material (accent strips on walls - hazard marking)
        let redStripeMaterial = SCNMaterial()
        redStripeMaterial.diffuse.contents = UIColor(red: 0.8, green: 0.08, blue: 0.08, alpha: 1)
        redStripeMaterial.roughness.contents = 0.6

        // Back wall - concrete panels
        let backWall = SCNBox(width: CGFloat(roomWidth), height: CGFloat(wallHeight), length: 0.25, chamferRadius: 0)
        backWall.materials = [concreteMaterial]
        let backNode = SCNNode(geometry: backWall)
        backNode.position = SCNVector3(0, wallHeight / 2, -roomDepth / 2)
        backNode.physicsBody = SCNPhysicsBody.static()
        backNode.name = "wall_back"
        scene.rootNode.addChildNode(backNode)
        self.backWallNode = backNode

        // Concrete panel line details on back wall
        for i in 0..<4 {
            let panelLine = SCNBox(width: CGFloat(roomWidth), height: 0.02, length: 0.01, chamferRadius: 0)
            let lineMat = SCNMaterial()
            lineMat.diffuse.contents = UIColor(red: 0.22, green: 0.2, blue: 0.19, alpha: 1)
            panelLine.materials = [lineMat]
            let lineNode = SCNNode(geometry: panelLine)
            lineNode.position = SCNVector3(0, Float(i + 1) * 1.0, -roomDepth / 2 + 0.14)
            scene.rootNode.addChildNode(lineNode)
        }

        // Left wall
        let leftWall = SCNBox(width: 0.25, height: CGFloat(wallHeight), length: CGFloat(roomDepth), chamferRadius: 0)
        leftWall.materials = [darkConcreteMaterial]
        let leftNode = SCNNode(geometry: leftWall)
        leftNode.position = SCNVector3(-roomWidth / 2, wallHeight / 2, 0)
        leftNode.physicsBody = SCNPhysicsBody.static()
        leftNode.name = "wall_left"
        scene.rootNode.addChildNode(leftNode)
        self.leftWallNode = leftNode

        // Right wall
        let rightWall = SCNBox(width: 0.25, height: CGFloat(wallHeight), length: CGFloat(roomDepth), chamferRadius: 0)
        rightWall.materials = [concreteMaterial]
        let rightNode = SCNNode(geometry: rightWall)
        rightNode.position = SCNVector3(roomWidth / 2, wallHeight / 2, 0)
        rightNode.physicsBody = SCNPhysicsBody.static()
        rightNode.name = "wall_right"
        scene.rootNode.addChildNode(rightNode)
        self.rightWallNode = rightNode

        // Ceiling - dark industrial
        let ceiling = SCNBox(width: CGFloat(roomWidth), height: 0.2, length: CGFloat(roomDepth), chamferRadius: 0)
        let ceilingMat = SCNMaterial()
        ceilingMat.diffuse.contents = UIColor(red: 0.12, green: 0.11, blue: 0.1, alpha: 1)
        ceilingMat.roughness.contents = 0.95
        ceiling.materials = [ceilingMat]
        let ceilingNode = SCNNode(geometry: ceiling)
        ceilingNode.position = SCNVector3(0, wallHeight, 0)
        scene.rootNode.addChildNode(ceilingNode)

        // Red hazard stripes on walls (horizontal)
        let stripeHeight: Float = 0.12
        for z: Float in [-roomDepth / 2 + 0.15] {
            for xPos: Float in [-2.5, 0, 2.5] {
                let stripe = SCNBox(width: 1.8, height: CGFloat(stripeHeight), length: 0.02, chamferRadius: 0)
                stripe.materials = [redStripeMaterial]
                let stripeNode = SCNNode(geometry: stripe)
                stripeNode.position = SCNVector3(xPos, 2.8, z)
                scene.rootNode.addChildNode(stripeNode)
            }
        }

        // Vertical red accent stripes on side walls
        for x: Float in [-roomWidth / 2 + 0.15, roomWidth / 2 - 0.15] {
            let stripe = SCNBox(width: 0.02, height: CGFloat(wallHeight), length: 0.12, chamferRadius: 0)
            stripe.materials = [redStripeMaterial]
            let stripeNode = SCNNode(geometry: stripe)
            stripeNode.position = SCNVector3(x, wallHeight / 2, -2)
            scene.rootNode.addChildNode(stripeNode)
        }
    }

    // MARK: - Ceiling Beams (Industrial)
    private func addCeilingBeams() {
        let beamMat = SCNMaterial()
        beamMat.diffuse.contents = UIColor(red: 0.2, green: 0.18, blue: 0.16, alpha: 1)
        beamMat.metalness.contents = 0.6
        beamMat.roughness.contents = 0.7

        // Cross beams (I-beam style)
        for z: Float in stride(from: -3.5, through: 3.0, by: 2.0) {
            let beam = SCNBox(width: 7.5, height: 0.25, length: 0.15, chamferRadius: 0)
            beam.materials = [beamMat]
            let beamNode = SCNNode(geometry: beam)
            beamNode.position = SCNVector3(0, 4.2, z)
            scene.rootNode.addChildNode(beamNode)

            // Bottom flange of I-beam
            let flange = SCNBox(width: 7.5, height: 0.04, length: 0.3, chamferRadius: 0)
            flange.materials = [beamMat]
            let flangeNode = SCNNode(geometry: flange)
            flangeNode.position = SCNVector3(0, 4.08, z)
            scene.rootNode.addChildNode(flangeNode)
        }
    }

    // MARK: - Exposed Pipes
    private func addExposedPipes() {
        let pipeMat = SCNMaterial()
        pipeMat.diffuse.contents = UIColor(red: 0.35, green: 0.32, blue: 0.3, alpha: 1)
        pipeMat.metalness.contents = 0.8
        pipeMat.roughness.contents = 0.4

        let rustMat = SCNMaterial()
        rustMat.diffuse.contents = UIColor(red: 0.45, green: 0.25, blue: 0.12, alpha: 1)
        rustMat.metalness.contents = 0.5
        rustMat.roughness.contents = 0.85

        // Horizontal pipes along ceiling on left side
        for z: Float in stride(from: -3.0, through: 2.0, by: 2.5) {
            let pipe = SCNCylinder(radius: 0.04, height: 7.0)
            pipe.materials = [pipeMat]
            let pipeNode = SCNNode(geometry: pipe)
            pipeNode.position = SCNVector3(-3.5, 3.7, z)
            pipeNode.eulerAngles.z = .pi / 2
            scene.rootNode.addChildNode(pipeNode)
        }

        // Vertical pipe on right wall
        let vertPipe = SCNCylinder(radius: 0.05, height: 4.0)
        vertPipe.materials = [rustMat]
        let vertNode = SCNNode(geometry: vertPipe)
        vertNode.position = SCNVector3(3.7, 2.0, -2.5)
        scene.rootNode.addChildNode(vertNode)

        // Elbow joint (sphere at connection point)
        let joint = SCNSphere(radius: 0.07)
        joint.materials = [rustMat]
        let jointNode = SCNNode(geometry: joint)
        jointNode.position = SCNVector3(3.7, 3.7, -2.5)
        scene.rootNode.addChildNode(jointNode)

        // Another horizontal pipe from joint
        let hPipe = SCNCylinder(radius: 0.05, height: 3.0)
        hPipe.materials = [rustMat]
        let hPipeNode = SCNNode(geometry: hPipe)
        hPipeNode.position = SCNVector3(3.7, 3.7, -1.0)
        hPipeNode.eulerAngles.x = .pi / 2
        scene.rootNode.addChildNode(hPipeNode)
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
        tableNode.position = SCNVector3(2.5, 0.85, -1.5)
        tableNode.physicsBody = SCNPhysicsBody.dynamic()
        tableNode.physicsBody?.mass = 15
        tableNode.physicsBody?.friction = 0.6
        tableNode.name = "table"
        scene.rootNode.addChildNode(tableNode)
        destructibleNodes.append(tableNode)

        // Table legs
        let legMat = SCNMaterial()
        legMat.diffuse.contents = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        legMat.metalness.contents = 0.7

        for (x, z) in [(-0.7, -0.3), (0.7, -0.3), (-0.7, 0.3), (0.7, 0.3)] as [(Float, Float)] {
            let leg = SCNCylinder(radius: 0.03, height: 0.85)
            leg.materials = [legMat]
            let legNode = SCNNode(geometry: leg)
            legNode.position = SCNVector3(2.5 + x, 0.425, -1.5 + z)
            legNode.physicsBody = SCNPhysicsBody.dynamic()
            legNode.physicsBody?.mass = 2
            legNode.name = "table_leg"
            scene.rootNode.addChildNode(legNode)
            destructibleNodes.append(legNode)
        }

        // Second smaller table against back wall
        let table2Top = SCNBox(width: 1.2, height: 0.05, length: 0.6, chamferRadius: 0.01)
        let darkWoodMat = SCNMaterial()
        darkWoodMat.diffuse.contents = UIColor(red: 0.22, green: 0.14, blue: 0.08, alpha: 1)
        darkWoodMat.roughness.contents = 0.85
        table2Top.materials = [darkWoodMat]
        let table2Node = SCNNode(geometry: table2Top)
        table2Node.position = SCNVector3(-2.5, 0.75, -3.0)
        table2Node.physicsBody = SCNPhysicsBody.dynamic()
        table2Node.physicsBody?.mass = 10
        table2Node.physicsBody?.friction = 0.5
        table2Node.name = "table_small"
        scene.rootNode.addChildNode(table2Node)
        destructibleNodes.append(table2Node)

        for (x, z) in [(-0.5, -0.25), (0.5, -0.25), (-0.5, 0.25), (0.5, 0.25)] as [(Float, Float)] {
            let leg = SCNCylinder(radius: 0.025, height: 0.75)
            leg.materials = [legMat]
            let legNode = SCNNode(geometry: leg)
            legNode.position = SCNVector3(-2.5 + x, 0.375, -3.0 + z)
            legNode.physicsBody = SCNPhysicsBody.dynamic()
            legNode.physicsBody?.mass = 1.5
            legNode.name = "table_leg"
            scene.rootNode.addChildNode(legNode)
            destructibleNodes.append(legNode)
        }
    }

    // MARK: - Dining Set (Table + Chairs)
    private func addDiningSet() {
        let woodMat = SCNMaterial()
        woodMat.diffuse.contents = UIColor(red: 0.35, green: 0.22, blue: 0.1, alpha: 1)
        woodMat.roughness.contents = 0.8

        let legMat = SCNMaterial()
        legMat.diffuse.contents = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        legMat.metalness.contents = 0.7

        // Dining table (center-left area)
        let diningTop = SCNBox(width: 1.4, height: 0.05, length: 1.4, chamferRadius: 0.02)
        diningTop.materials = [woodMat]
        let diningNode = SCNNode(geometry: diningTop)
        diningNode.position = SCNVector3(-1.0, 0.8, 0.5)
        diningNode.physicsBody = SCNPhysicsBody.dynamic()
        diningNode.physicsBody?.mass = 18
        diningNode.physicsBody?.friction = 0.5
        diningNode.name = "dining_table"
        scene.rootNode.addChildNode(diningNode)
        destructibleNodes.append(diningNode)

        // Dining table legs
        for (x, z) in [(-0.55, -0.55), (0.55, -0.55), (-0.55, 0.55), (0.55, 0.55)] as [(Float, Float)] {
            let leg = SCNCylinder(radius: 0.035, height: 0.78)
            leg.materials = [legMat]
            let legNode = SCNNode(geometry: leg)
            legNode.position = SCNVector3(-1.0 + x, 0.39, 0.5 + z)
            legNode.physicsBody = SCNPhysicsBody.dynamic()
            legNode.physicsBody?.mass = 2.5
            legNode.name = "dining_leg"
            scene.rootNode.addChildNode(legNode)
            destructibleNodes.append(legNode)
        }

        // 4 Chairs around the dining table
        let chairPositions: [(Float, Float, Float)] = [
            (-1.0, 0, -0.5),   // front
            (-1.0, 0, 1.5),    // back
            (-2.0, 0, 0.5),    // left
            (0.0, 0, 0.5),     // right
        ]
        let chairRotations: [Float] = [0, .pi, .pi / 2, -.pi / 2]

        for (i, (cx, _, cz)) in chairPositions.enumerated() {
            addChair(at: SCNVector3(cx, 0, cz), rotation: chairRotations[i], index: i, woodMat: woodMat, legMat: legMat)
        }
    }

    private func addChair(at position: SCNVector3, rotation: Float, index: Int, woodMat: SCNMaterial, legMat: SCNMaterial) {
        // Seat
        let seat = SCNBox(width: 0.4, height: 0.04, length: 0.4, chamferRadius: 0.01)
        seat.materials = [woodMat]
        let seatNode = SCNNode(geometry: seat)
        seatNode.position = SCNVector3(position.x, 0.48, position.z)
        seatNode.eulerAngles.y = rotation
        seatNode.physicsBody = SCNPhysicsBody.dynamic()
        seatNode.physicsBody?.mass = 4
        seatNode.physicsBody?.friction = 0.4
        seatNode.name = "chair_\(index)"
        scene.rootNode.addChildNode(seatNode)
        destructibleNodes.append(seatNode)

        // Chair back
        let back = SCNBox(width: 0.4, height: 0.45, length: 0.03, chamferRadius: 0.005)
        back.materials = [woodMat]
        let backNode = SCNNode(geometry: back)
        backNode.position = SCNVector3(position.x, 0.72, position.z - 0.18)
        backNode.eulerAngles.y = rotation
        backNode.physicsBody = SCNPhysicsBody.dynamic()
        backNode.physicsBody?.mass = 2
        backNode.name = "chair_back_\(index)"
        scene.rootNode.addChildNode(backNode)
        destructibleNodes.append(backNode)

        // Chair legs
        for (lx, lz) in [(-0.15, -0.15), (0.15, -0.15), (-0.15, 0.15), (0.15, 0.15)] as [(Float, Float)] {
            let leg = SCNCylinder(radius: 0.02, height: 0.46)
            leg.materials = [legMat]
            let legNode = SCNNode(geometry: leg)
            legNode.position = SCNVector3(position.x + lx, 0.23, position.z + lz)
            legNode.physicsBody = SCNPhysicsBody.dynamic()
            legNode.physicsBody?.mass = 0.8
            legNode.name = "chair_leg_\(index)"
            scene.rootNode.addChildNode(legNode)
            destructibleNodes.append(legNode)
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
                2.0 + Float(i) * 0.3,
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

        // Extra bottles on dining table
        let brownGlassMat = SCNMaterial()
        brownGlassMat.diffuse.contents = UIColor(red: 0.35, green: 0.2, blue: 0.05, alpha: 0.8)
        brownGlassMat.transparency = 0.7

        for i in 0..<3 {
            let bottle = SCNCylinder(radius: 0.035, height: 0.22)
            bottle.materials = [brownGlassMat]
            let node = SCNNode(geometry: bottle)
            node.position = SCNVector3(-1.0 + Float(i) * 0.25 - 0.25, 0.94, 0.5)
            node.physicsBody = SCNPhysicsBody.dynamic()
            node.physicsBody?.mass = 0.6
            node.physicsBody?.friction = 0.3
            node.name = "bottle_dining_\(i)"
            scene.rootNode.addChildNode(node)
            destructibleNodes.append(node)
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

    // MARK: - Plates (on tables)
    private func addPlates() {
        for i in 0..<6 {
            let plate = SCNCylinder(radius: 0.13, height: 0.015)
            let plateMat = SCNMaterial()
            plateMat.diffuse.contents = UIColor.white
            plateMat.roughness.contents = 0.15
            plate.materials = [plateMat]
            let node = SCNNode(geometry: plate)
            node.position = SCNVector3(2.5 + Float(i % 3) * 0.3 - 0.3, 0.92 + Float(i / 3) * 0.02, -1.5)
            node.physicsBody = SCNPhysicsBody.dynamic()
            node.physicsBody?.mass = 0.4
            node.physicsBody?.friction = 0.2
            node.name = "plate_\(i)"
            scene.rootNode.addChildNode(node)
            destructibleNodes.append(node)
        }

        // Plates on dining table
        for i in 0..<4 {
            let plate = SCNCylinder(radius: 0.12, height: 0.012)
            let plateMat = SCNMaterial()
            plateMat.diffuse.contents = UIColor(red: 0.95, green: 0.93, blue: 0.88, alpha: 1)
            plateMat.roughness.contents = 0.12
            plate.materials = [plateMat]
            let node = SCNNode(geometry: plate)
            let angle = Float(i) * (.pi / 2)
            node.position = SCNVector3(
                -1.0 + cos(angle) * 0.4,
                0.86,
                0.5 + sin(angle) * 0.4
            )
            node.physicsBody = SCNPhysicsBody.dynamic()
            node.physicsBody?.mass = 0.35
            node.physicsBody?.friction = 0.2
            node.name = "dining_plate_\(i)"
            scene.rootNode.addChildNode(node)
            destructibleNodes.append(node)
        }
    }

    // MARK: - Picture Frames (on walls, smashable)
    private func addPictureFrames() {
        let frameMat = SCNMaterial()
        frameMat.diffuse.contents = UIColor(red: 0.2, green: 0.15, blue: 0.08, alpha: 1)
        frameMat.roughness.contents = 0.7

        // Picture content colors (different "paintings")
        let pictureColors: [UIColor] = [
            UIColor(red: 0.3, green: 0.4, blue: 0.6, alpha: 1),  // blue abstract
            UIColor(red: 0.6, green: 0.3, blue: 0.2, alpha: 1),  // warm landscape
            UIColor(red: 0.2, green: 0.5, blue: 0.3, alpha: 1),  // green nature
            UIColor(red: 0.5, green: 0.2, blue: 0.4, alpha: 1),  // purple portrait
            UIColor(red: 0.7, green: 0.6, blue: 0.3, alpha: 1),  // gold classic
            UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1), // dark modern
        ]

        // Frames on back wall
        let backWallZ: Float = -4.35
        let backFramePositions: [(Float, Float, CGFloat, CGFloat)] = [
            (-2.0, 2.2, 0.7, 0.5),   // left upper
            (0.0, 2.0, 0.9, 0.6),    // center
            (2.0, 2.3, 0.6, 0.45),   // right upper
        ]

        for (i, (x, y, w, h)) in backFramePositions.enumerated() {
            addFrame(
                position: SCNVector3(x, y, backWallZ),
                size: (w, h),
                rotation: SCNVector3(0, 0, 0),
                color: pictureColors[i],
                frameMat: frameMat,
                name: "frame_back_\(i)"
            )
        }

        // Frames on left wall
        let leftWallX: Float = -3.85
        let leftFramePositions: [(Float, Float, CGFloat, CGFloat)] = [
            (1.8, 0.6, 0.5, 0.5),
            (2.2, -1.5, 0.65, 0.5),
        ]

        for (i, pos) in leftFramePositions.enumerated() {
            let y = pos.0
            let z = pos.1
            let w: CGFloat = pos.2
            let h: CGFloat = pos.3
            addFrame(
                position: SCNVector3(leftWallX, y, z),
                size: (w, h),
                rotation: SCNVector3(0, .pi / 2, 0),
                color: pictureColors[3 + i],
                frameMat: frameMat,
                name: "frame_left_\(i)"
            )
        }

        // Frame on right wall
        addFrame(
            position: SCNVector3(3.85, 2.0, -1.0),
            size: (0.8, 0.55),
            rotation: SCNVector3(0, -.pi / 2, 0),
            color: pictureColors[5],
            frameMat: frameMat,
            name: "frame_right_0"
        )
    }

    private func addFrame(position: SCNVector3, size: (CGFloat, CGFloat), rotation: SCNVector3, color: UIColor, frameMat: SCNMaterial, name: String) {
        let (w, h) = size

        // Picture/canvas (slightly recessed)
        let canvas = SCNBox(width: w - 0.06, height: h - 0.06, length: 0.02, chamferRadius: 0)
        let canvasMat = SCNMaterial()
        canvasMat.diffuse.contents = color
        canvasMat.roughness.contents = 0.5
        canvas.materials = [canvasMat]

        // Frame border (4 pieces)
        let frameNode = SCNNode()
        frameNode.position = position
        frameNode.eulerAngles = rotation
        frameNode.name = name

        let canvasNode = SCNNode(geometry: canvas)
        canvasNode.position = SCNVector3(0, 0, 0)
        frameNode.addChildNode(canvasNode)

        // Frame border - top
        let topBorder = SCNBox(width: w, height: 0.04, length: 0.04, chamferRadius: 0)
        topBorder.materials = [frameMat]
        let topNode = SCNNode(geometry: topBorder)
        topNode.position = SCNVector3(0, Float(h / 2), 0.01)
        frameNode.addChildNode(topNode)

        // Frame border - bottom
        let bottomNode = SCNNode(geometry: topBorder)
        bottomNode.position = SCNVector3(0, Float(-h / 2), 0.01)
        frameNode.addChildNode(bottomNode)

        // Frame border - left
        let sideBorder = SCNBox(width: 0.04, height: h, length: 0.04, chamferRadius: 0)
        sideBorder.materials = [frameMat]
        let leftBorderNode = SCNNode(geometry: sideBorder)
        leftBorderNode.position = SCNVector3(Float(-w / 2), 0, 0.01)
        frameNode.addChildNode(leftBorderNode)

        // Frame border - right
        let rightBorderNode = SCNNode(geometry: sideBorder)
        rightBorderNode.position = SCNVector3(Float(w / 2), 0, 0.01)
        frameNode.addChildNode(rightBorderNode)

        // Physics - the whole frame is dynamic so it can fall when hit
        frameNode.physicsBody = SCNPhysicsBody.dynamic()
        frameNode.physicsBody?.mass = 3
        frameNode.physicsBody?.friction = 0.4
        frameNode.physicsBody?.damping = 0.3

        scene.rootNode.addChildNode(frameNode)
        destructibleNodes.append(frameNode)
    }

    // MARK: - Hit Object (Tap)
    func hitObject(with tool: RageTool) {
        triggerHaptic(tool: tool)
        playImpactSound(for: tool)

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
            // Spray paint on back wall - SCNPlane nodes flat against the surface
            let wallZ: Float = -4.3
            let x = Float(translation.width) * 0.004
            let y = 1.8 + Float(-translation.height) * 0.003
            let clampedX = max(-3.0, min(3.0, x))
            let clampedY = max(0.5, min(3.8, y))
            spawnSprayMark(at: SCNVector3(clampedX, clampedY, wallZ))
        }
    }

    /// Set the spray paint color (called from the view)
    func setSprayColor(_ color: UIColor) {
        currentSprayColor = color
    }

    func endSwipe(tool: RageTool) {
        if tool == .throwPlates {
            triggerHaptic(tool: tool)
            playImpactSound(for: tool)
            if let throwable = destructibleNodes.first(where: {
                $0.name?.contains("plate") == true ||
                $0.name?.contains("bottle") == true ||
                $0.name?.contains("chair") == true
            }) {
                let throwForce = SCNVector3(
                    Float.random(in: -3...3),
                    Float.random(in: 1...4),
                    Float.random(in: (-10)...(-5))
                )
                throwable.physicsBody?.applyForce(throwForce, asImpulse: true)
                throwable.physicsBody?.applyTorque(SCNVector4(1, 0, 0, 15), asImpulse: true)
            }
        } else if tool != .spray {
            triggerHaptic(tool: tool)
            playImpactSound(for: tool)
            hitObject(with: tool)
        }
    }

    // MARK: - Haptic Feedback
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
    }

    // MARK: - Sound Effects (multiple varied sounds)
    private func playImpactSound(for tool: RageTool) {
        // Try to play sound file, fall back to system sound
        let soundName = tool.soundFile
        if let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = Float.random(in: 0.7...1.0)
                player.rate = Float.random(in: 0.9...1.1)
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
        // Varied system sounds for different impact types
        // Each tool has multiple possible sounds for variety
        let soundIDs: [UInt32]
        switch tool {
        case .sledgehammer:
            soundIDs = [1104, 1105, 1023, 1070]  // heavy impacts, metal
        case .bat:
            soundIDs = [1104, 1103, 1071, 1025]  // wood crack, thud
        case .fists:
            soundIDs = [1103, 1052, 1057, 1073]  // medium taps, flesh hits
        case .throwPlates:
            soundIDs = [1105, 1106, 1109, 1110]  // glass/ceramic shatter
        case .spray:
            soundIDs = [1100, 1101, 1054]        // subtle hiss
        }
        let soundID = soundIDs.randomElement() ?? 1104
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

    // MARK: - Spray Paint (SCNPlane nodes flat against wall)
    private func spawnSprayMark(at position: SCNVector3) {
        // Create a flat plane mark on the wall surface
        let size = CGFloat.random(in: 0.06...0.14)
        let sprayDot = SCNPlane(width: size, height: size)
        let dotMat = SCNMaterial()
        dotMat.diffuse.contents = currentSprayColor
        dotMat.emission.contents = currentSprayColor.withAlphaComponent(0.3)
        dotMat.transparent.contents = UIColor(white: 1, alpha: 0.85)
        dotMat.isDoubleSided = true
        dotMat.writesToDepthBuffer = true
        sprayDot.materials = [dotMat]
        sprayDot.cornerRadius = size / 2  // Make it circular

        let node = SCNNode(geometry: sprayDot)
        node.position = position
        // Flat against back wall (facing camera)
        node.name = "spray_mark"
        scene.rootNode.addChildNode(node)
        sprayNodes.append(node)

        // Add a subtle spray hiss sound (varied)
        let sprayHissSounds: [UInt32] = [1100, 1101, 1054]
        if Int.random(in: 0...3) == 0 {  // Only play sound every few marks
            AudioServicesPlaySystemSound(SystemSoundID(sprayHissSounds.randomElement() ?? 1100))
        }

        // Limit total spray marks to prevent performance issues
        if sprayNodes.count > 200 {
            let toRemove = sprayNodes.prefix(50)
            for old in toRemove {
                old.removeFromParentNode()
            }
            sprayNodes.removeFirst(50)
        }
    }
}
