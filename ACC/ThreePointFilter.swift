
import Foundation
import CoreMotion

class ThreePointFilter : Filter {
    
    var threePtFilterPointsDone: Int = 0
    let numberOfPointsForThreePtFilter: Int = 3
    
    var arrayX:[Double] = [Double]()
    var arrayY:[Double] = [Double]()
    var arrayZ:[Double] = [Double]()
    
    func initFilter(_ deviceMotionUpdateInterval: Double) {
        threePtFilterPointsDone = 0
        arrayX = [Double]()
        arrayY = [Double]()
        arrayZ = [Double]()
    }
    
    func filter(_ x: Double, y: Double, z: Double) -> (Double, Double, Double) {
        
        arrayX.append(x)
        arrayY.append(y)
        arrayZ.append(z)
        
        threePtFilterPointsDone += 1
        
        // When we have (numberOfPointsForThreePtFilter + 1 = 4) or more elements, 
        // we need to remove the first element.
        if threePtFilterPointsDone > numberOfPointsForThreePtFilter {
            arrayX.removeFirst()
            arrayY.removeFirst()
            arrayZ.removeFirst()
            threePtFilterPointsDone -= 1
        }
        
        var avg = ThreeAxesSystem<Double>(x: 0, y: 0, z: 0)
        for i in 0..<threePtFilterPointsDone {
            avg.x += arrayX[i]
            avg.y += arrayY[i]
            avg.z += arrayZ[i]
        }
        avg.x /= Double(threePtFilterPointsDone)
        avg.y /= Double(threePtFilterPointsDone)
        avg.z /= Double(threePtFilterPointsDone)
        
        return (avg.x, avg.y, avg.z)
    }
}

