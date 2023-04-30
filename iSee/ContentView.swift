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

//Función para reproducir sonido local
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

extension ARMeshClassification {
    
    //Para poder acompletar lo de la línea 36
    func vacio(){}
    
    //definimos comportamiento, para cada caso
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

//Estructura encargada del funcionamiento de ARKit
struct ARViewContainer: UIViewRepresentable{
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView{
        let arVista = ARView(frame: .zero)
        let texto = AnchorEntity()
        texto.addChild(GenerarTexto(textito: "Texto prueba"))
        arVista.scene.addAnchor(texto)
        
        // Inicia la sesión de AR
        let sesion = arVista.session
        let worldConfiguration = ARWorldTrackingConfiguration()
        worldConfiguration.planeDetection = [.horizontal, .vertical]
        sesion.run(worldConfiguration)
        
       //Se agrega la variable para priorizar el plano horizontal
       let coachingOverlay = ARCoachingOverlayView()
       coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       coachingOverlay.session = sesion
       coachingOverlay.goal = .horizontalPlane
       arVista.addSubview(coachingOverlay)
        
        // Opciones para el Debug
       #if DEBUG
       arVista.debugOptions = [.showFeaturePoints, .showAnchorOrigins, .showAnchorGeometry]
       #endif
        
        context.coordinator.view = arVista
        sesion.delegate = context.coordinator
        
        return arVista
    }
    
    //Función encargada de generar el estilo del texto
    func GenerarTexto(textito: String) -> ModelEntity{
        let materialVar = SimpleMaterial(color: .red, roughness: 0, isMetallic: false)
        let depthVar : Float = 0.001
        let fontVar = UIFont.systemFont(ofSize: 0.05)
        let containerFrameVar = CGRect(x: 0.05, y: 0.1, width: 1, height: 0.1)
        let alignmentVar : CTTextAlignment = .center
        let lineBreakModeVar : CTLineBreakMode = .byWordWrapping
        
        let textMeshResource : MeshResource = .generateText(textito, extrusionDepth: depthVar, font: fontVar, containerFrame: containerFrameVar, alignment: alignmentVar, lineBreakMode: lineBreakModeVar)
        
        let textoEntidad = ModelEntity(mesh: textMeshResource, materials: [materialVar])
        
        return textoEntidad
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
         
    }
    
    //Clase para enfoque
    class Coordinator: NSObject, ARSessionDelegate {
    weak var view: ARView?
    var focusEntity: FocusEntity!

        //Función para el enfoque de la cámara
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let view = self.view else { return }
        debugPrint("Aquí tenemos los anchors", anchors)
        
        self.focusEntity = FocusEntity(on: view, style: .colored(onColor: .color(.green), offColor: .color(.blue), nonTrackingColor: .color(.red)))
        if(focusEntity.onPlane == (ARMeshClassification(rawValue: 0) != nil)){
            playSound()
        }
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
