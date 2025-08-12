import simd

class BoundingBoxBuilder {
    
    // Object list
    private var objects: [ObjectWrapper]
    
    // Ignored object indexes
    private let infObjectIndexes: [Int] = [5]
    
    // Box min and maxes
    private var boxMin: SIMD4<Float> = SIMD4<Float>(Float.infinity,Float.infinity,Float.infinity,0)
    private var boxMax: SIMD4<Float> = SIMD4<Float>(-Float.infinity,-Float.infinity,-Float.infinity,0)
    
    // All that's needed is the object list
    init (objects: [ObjectWrapper]) {
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
        
        return BoundingBox(boxMin: boxMin, boxMax: boxMax, temp1: SIMD4<Float>(repeating: 0), temp2: SIMD4<Float>(repeating: 0))
    }
    
    func sphereCase(sphere: ObjectWrapper) {
        
        boxMin.x = min(boxMin.x, sphere.origin.x - sphere.bounds[3])
        boxMin.y = min(boxMin.y, sphere.origin.y - sphere.bounds[3])
        boxMin.z = min(boxMin.z, sphere.origin.z - sphere.bounds[3])
        
        boxMax.x = max(boxMax.x, sphere.origin.x + sphere.bounds[3])
        boxMax.y = max(boxMax.y, sphere.origin.y + sphere.bounds[3])
        boxMax.z = max(boxMax.z, sphere.origin.z + sphere.bounds[3])
    }
    
    func boxesCase(box: ObjectWrapper) {
        boxMin.x = min(boxMin.x, box.origin.x - box.bounds[0])
        boxMin.y = min(boxMin.y, box.origin.y - box.bounds[1])
        boxMin.z = min(boxMin.z, box.origin.z - box.bounds[2])
        
        boxMax.x = max(boxMax.x, box.origin.x + box.bounds[0])
        boxMax.y = max(boxMax.y, box.origin.y + box.bounds[1])
        boxMax.z = max(boxMax.z, box.origin.z + box.bounds[2])
    }
    
    func cylinderCase(cylinder: ObjectWrapper) {
//        boxMin.x = min(boxMin.x, cylinder.origin.x - cylinder.bounds[3])
//        boxMin.y = min(boxMin.y, cylinder.origin.y - cylinder.bounds[1])
//        boxMin.z = min(boxMin.z, cylinder.origin.z - cylinder.bounds[3])
//        
//        boxMax.x = max(boxMax.x, cylinder.origin.x + cylinder.bounds[3])
//        boxMax.y = max(boxMax.y, cylinder.origin.y + cylinder.bounds[1])
//        boxMax.z = max(boxMax.z, cylinder.origin.z + cylinder.bounds[3])
//        
//        
//        
//        
        // Saved values
        let norm: SIMD3<Float> = simd_normalize(SIMD3<Float>(cylinder.bounds.x, cylinder.bounds.y, cylinder.bounds.z))
        let origin: SIMD3<Float> = SIMD3<Float>(cylinder.origin.x, cylinder.origin.y, cylinder.origin.z)
        let rad: Float = cylinder.bounds.w
        
        // Half-height vector along cylinder axis
        let halfAxis: SIMD3<Float> = norm * cylinder.origin.w

        // Two points at the ends of the cylinder's axis
        let p1: SIMD3<Float> = origin - halfAxis
        let p2: SIMD3<Float> = origin + halfAxis

        // Create two orthonormal vectors perpendicular to normal
        var u: SIMD3<Float> = simd_normalize(abs(norm.x) < 1 ? SIMD3<Float>(0,1,0) : SIMD3<Float>(1,0,0))
        u = simd_normalize(cross(norm, u))
        let v: SIMD3<Float> = simd_normalize(cross(norm, u))

        // Expand ends by radius in both perpendicular directions
        let offsets: [SIMD3<Float>] = [
            u * rad + v * rad,
            u * rad - v * rad,
           -u * rad + v * rad,
           -u * rad - v * rad
        ]

        // Initialize AABB to extreme values
        var thisBoxMin: SIMD3<Float> = SIMD3<Float>(repeating: 1e30)
        var thisBoxMax: SIMD3<Float> = SIMD3<Float>(repeating: -1e30)

        // Check all 8 extreme points
        for offset in offsets {
            let corner1: SIMD3<Float> = p1 + offset
            let corner2: SIMD3<Float> = p2 + offset
            thisBoxMin = min(SIMD3<Float>(boxMin.x, boxMin.y, boxMin.z), corner1)
            thisBoxMax = max(SIMD3<Float>(boxMax.x, boxMax.y, boxMax.z), corner1)
            thisBoxMin = min(SIMD3<Float>(boxMin.x, boxMin.y, boxMin.z), corner2)
            thisBoxMax = max(SIMD3<Float>(boxMax.x, boxMax.y, boxMax.z), corner2)
        }
        
        boxMin = min(boxMin, SIMD4<Float>(thisBoxMin.x, thisBoxMin.y, thisBoxMin.z, 0.0))
        boxMax = max(boxMax, SIMD4<Float>(thisBoxMax.x, thisBoxMax.y, thisBoxMax.z, 0.0))
        
        
    }
}
