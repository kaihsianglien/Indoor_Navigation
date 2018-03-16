
import UIKit

class PathLayer: CAShapeLayer {
    /// Indicate the color of the grid line.
    @IBInspectable var pathColor:UIColor = UIColor.blue {
        didSet {
            self.strokeColor = pathColor.cgColor
            self.setNeedsDisplay()
        }
    }
    
    var circleColor: UIColor = UIColor.init(red: 0, green: 71/255.0, blue: 102/255.0, alpha: 0.8) {
        didSet {
            self.fillColor = circleColor.cgColor
            self.setNeedsDisplay()
        }
    }
    
    init(frame: CGRect) {
        super.init()
        self.strokeColor = pathColor.cgColor
        self.fillColor = circleColor.cgColor
        self.backgroundColor = UIColor.clear.cgColor
        self.frame = frame
    }
    
    internal convenience required init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRect.zero)
    }
    
    override var frame: CGRect {
        didSet {
            updatePath(bounds)
            updateRoutePath()
        }
    }
    
    
    
    /* MARK: Private instances */
    // Not yet implement "Z" axis
    fileprivate var routePath = UIBezierPath()
    fileprivate var pathPoints = [ThreeAxesSystem<CGFloat>]() // an array that keeps the original path points which are used to re-draw the routePath when the scale is changed.
    fileprivate var previousOrigin = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z:0)
    fileprivate var currentOrigin = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z:0)
    fileprivate var previousPoint = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z: 0)
    fileprivate var currentPoint = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z: 0)
    fileprivate var resetOffset = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z:0)
    
    fileprivate var isResetScale = false
    fileprivate var accumulatedScale: CGFloat = 1.0
    
    
    /* MARK: Public APIs */
    func setScale(_ scale: Double) {
        accumulatedScale *= CGFloat(scale)
        resetOffset.x *= CGFloat(scale)
        resetOffset.y *= CGFloat(scale)
        
        if !pathPoints.isEmpty {
            for i in 0..<pathPoints.count {
                pathPoints[i].x *= CGFloat(scale)
                pathPoints[i].y *= CGFloat(scale)
                pathPoints[i].z *= CGFloat(scale)
            }
            
            currentPoint.x = pathPoints[pathPoints.count-1].x
            currentPoint.y = pathPoints[pathPoints.count-1].y
            isResetScale = true
        }
        updateRoutePath()
    }
    
    func setOrigin(_ x: Double, y: Double) {
        
        previousOrigin.x = currentOrigin.x
        previousOrigin.y = currentOrigin.y
        
        if !pathPoints.isEmpty {
            for i in 0..<pathPoints.count {
                pathPoints[i].x -= (currentOrigin.x - previousOrigin.x)
                pathPoints[i].y -= (currentOrigin.x - previousOrigin.x)
            }
            
            currentPoint.x = pathPoints[pathPoints.count-1].x
            currentPoint.y = pathPoints[pathPoints.count-1].y
            isResetScale = true
        }

        resetOffset.x += (currentOrigin.x - previousOrigin.x)
        resetOffset.y += (currentOrigin.y - previousOrigin.y)
        
        currentOrigin.x = CGFloat(x)
        currentOrigin.y = CGFloat(y)
        updateRoutePath()
    }
    
    func movePointTo(_ x: Double, y: Double) {
        
        previousPoint.x = currentPoint.x
        previousPoint.y = currentPoint.y

        currentPoint.x = CGFloat(x)*accumulatedScale - resetOffset.x
        currentPoint.y = CGFloat(y)*accumulatedScale - resetOffset.y
        
        pathPoints.append(ThreeAxesSystem<CGFloat>(x: currentPoint.x, y: currentPoint.y, z: 0)) // z has not yet been implemented
        updateRoutePath()
    }
    
    func cleanPath() {
        
        if !pathPoints.isEmpty {
            resetOffset.x += currentPoint.x
            resetOffset.y += currentPoint.y
        }
        currentPoint.x = 0
        currentPoint.y = 0
        previousPoint.x = 0
        previousPoint.y = 0
        
        routePath.removeAllPoints()
        pathPoints.removeAll()
        updateRoutePath()
    }
    
    fileprivate func updatePath(_ rect: CGRect) {
        // Draw nothing when the rect is too small
        if rect.width < 1 || rect.height < 1 {
            return
        }
        self.setNeedsDisplay()
    }
    
    fileprivate func updateRoutePath() {
        
        let drawing = UIBezierPath()
        
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
        
        var circle = UIBezierPath()
        circle = getCircle(atCenter: CGPoint(x: currentPoint.x + currentOrigin.x, y: currentPoint.y + currentOrigin.y), radius: CGFloat(5))
        
        drawing.append(routePath)
        drawing.append(circle)
        self.path = drawing.cgPath
        
        self.setNeedsDisplay()
    }
}



