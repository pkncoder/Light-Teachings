class BoundingBoxBuilder {
    
    // Object list
    var objects: [SceneBuilder.ObjectWrapper]
    
    // Ignored object indexes
    private let infObjectIndexes: [Int] = [5]
    
    // Box min and maxes
    private var boxMin: SIMD4<Float> = SIMD4<Float>(Float.infinity,Float.infinity,Float.infinity,0)
    private var boxMax: SIMD4<Float> = SIMD4<Float>(-Float.infinity,-Float.infinity,-Float.infinity,0)
    
    // All that's needed is the object list
    init (objects: [SceneBuilder.ObjectWrapper]) {
        self.objects = objects
    }
    
    // Full build
    func fullBuild() -> BoundingBox {
        
        // For each object
        for i in 0..<objects.count {
            let currentObject = objects[i]
            
            // Check to make sure thayt the object isn't infinate
            if !(infObjectIndexes.contains(Int(currentObject.objectData[0]))) {
                
                // Switch each object and do each case
                switch Objects.getObjectFromIndex(currentObject.objectData[0]) {
                    // Spheres
                    case .sphere:
                        sphereCase(sphere: currentObject)
                        
                    // Boxes
                    case .box:
                        boxesCase(box: currentObject)
                    case .roundedBox:
                        boxesCase(box: currentObject)
                    case .borderedBox:
                        boxesCase(box: currentObject)
                        
                    // cylinder
                    case .cylinder:
                        cylinderCase(cylinder: currentObject)
                        
                        
                    default:
                        sphereCase(sphere: currentObject)
                }
            }
        }
        
        return BoundingBox(boxMin: boxMin, boxMax: boxMax)
    }
    
    func sphereCase(sphere: SceneBuilder.ObjectWrapper) {
        
        boxMin.x = min(boxMin.x, sphere.origin.x - sphere.bounds[3])
        boxMin.y = min(boxMin.y, sphere.origin.y - sphere.bounds[3])
        boxMin.z = min(boxMin.z, sphere.origin.z - sphere.bounds[3])
        
        boxMax.x = max(boxMax.x, sphere.origin.x + sphere.bounds[3])
        boxMax.y = max(boxMax.y, sphere.origin.y + sphere.bounds[3])
        boxMax.z = max(boxMax.z, sphere.origin.z + sphere.bounds[3])
    }
    
    func boxesCase(box: SceneBuilder.ObjectWrapper) {
        boxMin.x = min(boxMin.x, box.origin.x - box.bounds[0])
        boxMin.y = min(boxMin.y, box.origin.y - box.bounds[1])
        boxMin.z = min(boxMin.z, box.origin.z - box.bounds[2])
        
        boxMax.x = max(boxMax.x, box.origin.x + box.bounds[0])
        boxMax.y = max(boxMax.y, box.origin.y + box.bounds[1])
        boxMax.z = max(boxMax.z, box.origin.z + box.bounds[2])
    }
    
    func cylinderCase(cylinder: SceneBuilder.ObjectWrapper) {
        boxMin.x = min(boxMin.x, cylinder.origin.x - cylinder.bounds[3])
        boxMin.y = min(boxMin.y, cylinder.origin.y - cylinder.bounds[1])
        boxMin.z = min(boxMin.z, cylinder.origin.z - cylinder.bounds[3])
        
        boxMax.x = max(boxMax.x, cylinder.origin.x + cylinder.bounds[3])
        boxMax.y = max(boxMax.y, cylinder.origin.y + cylinder.bounds[1])
        boxMax.z = max(boxMax.z, cylinder.origin.z + cylinder.bounds[3])
    }
}
