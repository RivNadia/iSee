//
//  ContentView.swift
//  iSee
//
//  Created by iOS Lab on 30/04/23.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity
import AVFoundation

var player : AVAudioPlayer!

extension ARMeshClassification {
    func playSound(){
        let url = Bundle.main.url(forResource: "pruebas", withExtension: "mp3")
        
        guard url != nil else { return }
        
        do{
            player = try AVAudioPlayer(contentsOf: url!)
            player?.play()
        } catch {
            print("Eror")
        }
    }
    
    func vacio(){
        print("puto")
    }
    
    var description: Void {
        switch self {
        case .door: return playSound()
        case .seat: return playSound()
        case .table: return playSound()
        case .wall: return playSound()
        case .window: return playSound()
        case .none: return playSound()
        case .floor:
            return vacio()
        case .ceiling:
            return vacio()
        @unknown default: return playSound()
        }
    }
    
    var color: UIColor {
        switch self {
        case .ceiling: return .red
        case .door: return .green
        case .floor: return .blue
        case .seat: return .cyan
        case .table: return .magenta
        case .wall: return .yellow
        case .window: return .black
        case .none: return .systemOrange
        @unknown default: return .gray
        }
    }
}

struct ARViewContainer: UIViewRepresentable{
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView{
        let arView = ARView(frame: .zero)
        let textAnchor = AnchorEntity()
        textAnchor.addChild(textGen(textString: "Puto el que lo lea"))
        arView.scene.addAnchor(textAnchor)
        
        // Start AR session
        let session = arView.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        session.run(config)
        
        func renderer(_ renderer: SCNSceneRenderer,
                      didAdd node: SCNNode,
                       for anchor: ARAnchor){
            guard let planeAnchor = anchor as? ARPlaneAnchor
                else { return }
                if planeAnchor.alignment == .horizontal {
                    print("Horizontal")
                } else if planeAnchor.alignment == .vertical {
                    print("Vertical")
                }
        }
        
        let planeAnchor = AnchorEntity(plane: .vertical, classification: [.wall, .table], minimumBounds: [1.0, 1.0])
        arView.scene.anchors.append(planeAnchor)
        
        // Add coaching overlay
       let coachingOverlay = ARCoachingOverlayView()
       coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       coachingOverlay.session = session
       coachingOverlay.goal = .horizontalPlane
       arView.addSubview(coachingOverlay)
        
        // Set debug options
       #if DEBUG
       arView.debugOptions = [.showFeaturePoints, .showAnchorOrigins, .showAnchorGeometry]
       #endif
        
        context.coordinator.view = arView
        session.delegate = context.coordinator
        
        arView.addGestureRecognizer(
            UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap)
            )
        )
        
        return arView
    }
    
    func textGen(textString: String) -> ModelEntity{
        let materialVar = SimpleMaterial(color: .red, roughness: 0, isMetallic: false)
        let depthVar : Float = 0.001
        let fontVar = UIFont.systemFont(ofSize: 0.05)
        let containerFrameVar = CGRect(x: 0.05, y: 0.1, width: 1, height: 0.1)
        let alignmentVar : CTTextAlignment = .center
        let lineBreakModeVar : CTLineBreakMode = .byWordWrapping
        
        let textMeshResource : MeshResource = .generateText(textString, extrusionDepth: depthVar, font: fontVar, containerFrame: containerFrameVar, alignment: alignmentVar, lineBreakMode: lineBreakModeVar)
        
        let textEntity = ModelEntity(mesh: textMeshResource, materials: [materialVar])
        
        return textEntity
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
         
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
    weak var view: ARView?
    var focusEntity: FocusEntity?

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let view = self.view else { return }
        debugPrint("Aquí tenemos los anchors", anchors)
        
        self.focusEntity = FocusEntity(on: view, style: .classic(color: .red))
        }
        
        @objc func handleTap(){
            /*guard let view = self.view, let focusEntity = self.focusEntity else { return}
            
            let anchor = AnchorEntity()
            view.scene.anchors.append(anchor)
            
            let box = MeshResource.generateBox(size: 0.5, cornerRadius: 0.05)
            let material = SimpleMaterial(color: .blue, isMetallic: true)
            let diceEntity = ModelEntity(mesh: box, materials: [material])
            diceEntity.position = focusEntity.position

            anchor.addChild(diceEntity)*/
        }
   }
}

struct ContentView: View {
    var body: some View{
        ARViewContainer().ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
