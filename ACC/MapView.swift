
import UIKit


class MapView: UIView {
    
    /* MARK: Private instances */
    // Not yet implement "Z" axis
    fileprivate var routePath = UIBezierPath()
    fileprivate var pathPoints = [ThreeAxesSystem<CGFloat>]() // an array that keeps the original path points which are used to re-draw the routePath when the scale is changed.
    fileprivate var previousOrigin = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z: 0)
    fileprivate var currentOrigin = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z: 0)
    fileprivate var previousPoint = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z: 0)
    fileprivate var currentPoint = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z: 0)
    fileprivate var resetOffset = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z: 0)
    
    fileprivate var isResetScale = false
    fileprivate var accumulatedScale: CGFloat = 1.0
    
    /* MARK: Public APIs */
    func setScale(_ scale: Double) {
        accumulatedScale *= CGFloat(scale)
        threeAxisSysOperation(&resetOffset, operation: .multiply, aValue: CGFloat(scale))
        
        if !pathPoints.isEmpty {
            for i in 0..<pathPoints.count {
                threeAxisSysOperation(&pathPoints[i], operation: .multiply, aValue: CGFloat(scale))
            }
            
            threeAxisSysOperation(&currentPoint, operation: .assign, operandPoint: pathPoints[pathPoints.count - 1])
            isResetScale = true
        }
        setNeedsDisplay()
    }
    
    func setOrigin(_ x: Double, y: Double) {
        
        threeAxisSysOperation(&previousOrigin, operation: .assign, operandPoint: currentOrigin)
        threeAxisSysOperation(
            &currentOrigin,
            operation: .assign,
            operandPoint: ThreeAxesSystem<CGFloat>(x: CGFloat(x), y: CGFloat(y), z: CGFloat(0))
        )
        
        if !pathPoints.isEmpty {
            isResetScale = true
        }
        
        setNeedsDisplay()
    }
    
    func movePointTo(_ x: Double, y: Double) {
        
        threeAxisSysOperation(&previousPoint, operation: .assign, operandPoint: currentPoint)
        
        let incomingPoint =
            ThreeAxesSystem<CGFloat>(x: CGFloat(x)*accumulatedScale - resetOffset.x, y: CGFloat(y)*accumulatedScale - resetOffset.y, z: 0)
        threeAxisSysOperation(&currentPoint, operation: .assign, operandPoint: incomingPoint)
        
        pathPoints.append(ThreeAxesSystem<CGFloat>(x: currentPoint.x, y: currentPoint.y, z: 0)) // z has not yet been implemented
        setNeedsDisplay()
    }
    
    func cleanPath() {
        
        if !pathPoints.isEmpty {
            threeAxisSysOperation(&resetOffset, operation: .add, operandPoint: currentPoint)
        }
        
        threeAxisSysOperation(&currentPoint, operation: .assign, aValue: 0)
        threeAxisSysOperation(&previousPoint, operation: .assign, aValue: 0)
        
        routePath.removeAllPoints()
        pathPoints.removeAll()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
        if isResetScale {
            routePath.removeAllPoints()
            for i in 0..<(pathPoints.count - 1) {
                routePath.move(to: CGPoint(x: pathPoints[i].x + currentOrigin.x, y: pathPoints[i].y + currentOrigin.y))
                routePath.addLine(to: CGPoint(x: pathPoints[i+1].x + currentOrigin.x, y: pathPoints[i+1].y + currentOrigin.y))
            }
            isResetScale = false
            
        } else {
            routePath.move(to: CGPoint(x: previousPoint.x + currentOrigin.x, y: previousPoint.y + currentOrigin.y))
            routePath.addLine(to: CGPoint(x: currentPoint.x + currentOrigin.x, y: currentPoint.y + currentOrigin.y))
        }
        
        let circle =
            getCircle(atCenter: CGPoint(x: currentPoint.x + currentOrigin.x, y: currentPoint.y + currentOrigin.y), radius: CGFloat(5))
        
        UIColor.black.set()
        routePath.stroke()
        
        UIColor.black.set()
        circle.fill()
    }
}

func getCircle(atCenter center: CGPoint, radius: CGFloat) -> UIBezierPath {
    return UIBezierPath(arcCenter: center, radius: radius, startAngle: 0.0, endAngle: CGFloat(2*M_PI), clockwise: false)
}

func getLinePath(_ startPoint: CGPoint, endPoint: CGPoint) -> UIBezierPath {
    
    let linePath = UIBezierPath()
    linePath.move(to: startPoint)
    linePath.addLine(to: endPoint)
    
    return linePath
}

func threeAxisSysOperation(_ threeAxisSysPoint: inout ThreeAxesSystem<CGFloat>, operation: Operation, aValue: CGFloat) {
    let threeAxisSysPointWithValue = ThreeAxesSystem<CGFloat>(x: aValue, y: aValue, z: aValue)
    threeAxisSysOperation(&threeAxisSysPoint, operation: operation, operandPoint: threeAxisSysPointWithValue)
}

func threeAxisSysOperation(_ threeAxisSysPoint: inout ThreeAxesSystem<CGFloat>, operation: Operation, operandPoint: ThreeAxesSystem<CGFloat>) {
    switch operation {
    case .assign:
        threeAxisSysPoint.x = operandPoint.x
        threeAxisSysPoint.y = operandPoint.y
        threeAxisSysPoint.z = operandPoint.z
    case .add:
        threeAxisSysPoint.x += operandPoint.x
        threeAxisSysPoint.y += operandPoint.y
        threeAxisSysPoint.z += operandPoint.z
    case .minus:
        threeAxisSysPoint.x -= operandPoint.x
        threeAxisSysPoint.y -= operandPoint.y
        threeAxisSysPoint.z -= operandPoint.z
    case .multiply:
        threeAxisSysPoint.x *= operandPoint.x
        threeAxisSysPoint.y *= operandPoint.y
        threeAxisSysPoint.z *= operandPoint.z
    case .divide:
        threeAxisSysPoint.x /= operandPoint.x
        threeAxisSysPoint.y /= operandPoint.y
        threeAxisSysPoint.z /= operandPoint.z
    }
}

enum Operation {
    case assign     // =
    case add        // +=
    case minus      // -=
    case multiply   // *=
    case divide     // /=
}
