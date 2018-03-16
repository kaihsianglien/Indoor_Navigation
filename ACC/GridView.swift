
import UIKit

class GridView: UIView {
    
    // MARK: Instance variables
    var scaleValueForTheText: Double = 1
    var origin = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z: 0)
    
    // MARK: Public APIs
    func setScale(_ scale: Double) {
        scaleValueForTheText = scale
        setNeedsDisplay()
    }
    
    func setOrigin(_ x: Double, y: Double) {
        origin.x = CGFloat(x)
        origin.y = CGFloat(y)
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
        // Draw nothing when the rect is too small
        if rect.width < 1 || rect.height < 1 {
            return
        }
        
        /* Draw Texts */
        self.layer.sublayers?.removeAll() // removes the previous textLayer if has any
        let textLayer: TextLayer = TextLayer(frame: self.frame)
        textLayer.scaleValue = scaleValueForTheText
        textLayer.setOrigin(Double(origin.x), y: Double(origin.y))
        self.layer.addSublayer(textLayer)
        
        
        /* Draw Grids */
        let centerPoint = CGPoint(x: origin.x, y: origin.y)
        
        // draw the grid
        let gridPath = UIBezierPath()
        let gridSize = CGFloat(10)
        let pattern: [CGFloat] = [4, 2]
        gridPath.setLineDash(pattern, count: 2, phase: 0.0)
        gridPath.lineWidth = 1
        
        // draw the scales
        let scalePath = UIBezierPath()
        scalePath.lineWidth = 2
        
        // draw X, Y axises
        let axisPath = UIBezierPath()
        axisPath.lineWidth = 2
        
        for i in 0...Int(bounds.height) {
            if i == 0 {
                axisPath.move(to: CGPoint(x: CGFloat(0), y: centerPoint.y + CGFloat(i) * gridSize))
                axisPath.addLine(to: CGPoint(x: bounds.width, y: centerPoint.y + CGFloat(i) * gridSize))
                continue
            }
            if Double(i).truncatingRemainder(dividingBy: 2) == 0 {
                scalePath.move(to: CGPoint(x: centerPoint.x, y: centerPoint.y + CGFloat(i) * gridSize))
                scalePath.addLine(to: CGPoint(x: centerPoint.x + 5, y: centerPoint.y + CGFloat(i) * gridSize))
                
                scalePath.move(to: CGPoint(x: centerPoint.x, y: centerPoint.y - CGFloat(i) * gridSize))
                scalePath.addLine(to: CGPoint(x: centerPoint.x + 5, y: centerPoint.y - CGFloat(i) * gridSize))
            }
            
            gridPath.move(to: CGPoint(x: CGFloat(0), y: centerPoint.y + CGFloat(i) * gridSize))
            gridPath.addLine(to: CGPoint(x: bounds.width, y: centerPoint.y + CGFloat(i) * gridSize))
            
            gridPath.move(to: CGPoint(x: CGFloat(0), y: centerPoint.y - CGFloat(i) * gridSize))
            gridPath.addLine(to: CGPoint(x: bounds.width, y: centerPoint.y - CGFloat(i) * gridSize))
        }
        
        for i in 0...Int(bounds.width) {
            if i == 0 {
                axisPath.move(to: CGPoint(x: centerPoint.x +  CGFloat(i) * gridSize, y: CGFloat(0)))
                axisPath.addLine(to: CGPoint(x: centerPoint.x + CGFloat(i) * gridSize, y: bounds.height))
                continue
            }
            if Double(i).truncatingRemainder(dividingBy: 2) == 0 {
                scalePath.move(to: CGPoint(x: centerPoint.x +  CGFloat(i) * gridSize, y: centerPoint.y - 5))
                scalePath.addLine(to: CGPoint(x: centerPoint.x + CGFloat(i) * gridSize, y: centerPoint.y))
                
                scalePath.move(to: CGPoint(x: centerPoint.x -  CGFloat(i) * gridSize, y: centerPoint.y - 5))
                scalePath.addLine(to: CGPoint(x: centerPoint.x - CGFloat(i) * gridSize, y: centerPoint.y))
            }
            
            gridPath.move(to: CGPoint(x: centerPoint.x +  CGFloat(i) * gridSize, y: CGFloat(0)))
            gridPath.addLine(to: CGPoint(x: centerPoint.x + CGFloat(i) * gridSize, y: bounds.height))
            
            
            gridPath.move(to: CGPoint(x: centerPoint.x -  CGFloat(i) * gridSize, y: CGFloat(0)))
            gridPath.addLine(to: CGPoint(x: centerPoint.x - CGFloat(i) * gridSize, y: bounds.height))
        }
        
        UIColor.black.withAlphaComponent(0.1).set()
        gridPath.stroke()
        UIColor.black.set()
        scalePath.stroke()
        UIColor.black.set()
        axisPath.stroke()
    }
}


class GradientView: UIView {
    
    override var frame: CGRect { didSet { setNeedsDisplay() } }
    
    fileprivate var topColor: CGColor = UIColor.clear.cgColor
    fileprivate var bottomColor: CGColor = UIColor.clear.cgColor
    
    func colorSetUp(_ topColor: CGColor, bottomColor: CGColor) {
        self.topColor = topColor
        self.bottomColor = bottomColor
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        self.layer.sublayers?.removeAll()
        self.layerGradient(topColor, bottomColor: bottomColor)
    }
}
