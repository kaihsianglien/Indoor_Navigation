
import Foundation

protocol Filter {
    
    func initFilter(_ deviceMotionUpdateInterval: Double)
    
    //func filter<T>(x: T, y: T, z: T) -> (T, T, T)
    func filter(_ x: Double, y: Double, z: Double) -> (Double, Double, Double) 
}
