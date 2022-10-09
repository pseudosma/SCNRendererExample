import SceneKit
import MetalKit

class ExampleViewController: UIViewController {
    
    @IBOutlet var mtkView: MTKView!
    
    var fpsScalar: Double = 0
    var renderer: SCNRenderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("This device doesn't support Metal")
        }
        
        //setup MTKView
        mtkView.device = device
        mtkView.clearColor = MTLClearColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        mtkView.preferredFramesPerSecond = 60
        mtkView.delegate = self
        //we need to manually track frames, so we make a scalar based on the frames per second
        fpsScalar = 1.0 / Double(mtkView.preferredFramesPerSecond)
        
        
        
        //setup scene
        let scn = SCNScene()
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scn.rootNode.addChildNode(cameraNode)
        // place the camera
        cameraNode.simdPosition = simd_float3(x: 0, y: 0, z: 15)
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.simdPosition = simd_float3(x: 0, y: 10, z: 10)
        scn.rootNode.addChildNode(lightNode)
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scn.rootNode.addChildNode(ambientLightNode)
        // create a 3D object
        let cube = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
        cube.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        cube.simdPosition = simd_float3(0,0,0)
        scn.rootNode.addChildNode(cube)
        // animate the 3d object
        cube.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 1)))
        
        

        //setup renderer
        renderer = SCNRenderer(device: device, options: nil)
        renderer!.scene = scn
        renderer!.pointOfView = cameraNode
        renderer!.delegate = self
    }
}

extension ExampleViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //the time needs to be incremented manually inside the render loop
        renderer.sceneTime += fpsScalar
    }
}

extension ExampleViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        //do nothing here for now
    }
    
    func draw(in view: MTKView) {
        if let r = renderer, let renderPassDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable, let commandQueue = r.commandQueue {
            let commandBuffer = commandQueue.makeCommandBuffer()
            
            r.render(
                atTime: r.sceneTime,
                viewport: CGRect(origin: CGPointZero, size: CGSize(width: drawable.texture.width, height: drawable.texture.height)),
                commandBuffer: commandBuffer!,
                passDescriptor: renderPassDescriptor
            )
            
            commandBuffer!.present(drawable)
            commandBuffer!.commit()
        }
    }
}
