
import UIKit

extension UIView {
    func layerGradient(_ topColor: CGColor, bottomColor: CGColor) {
        let layer: CAGradientLayer = CAGradientLayer()
        layer.frame = self.frame
        //layer.cornerRadius = CGFloat(frame.width / 20)
        
        layer.colors = [topColor, bottomColor]
        self.layer.insertSublayer(layer, at: 0)
    }
}
