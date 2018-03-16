
import Foundation
import Accelerate

class Utilities {

    // exchange x and y;
}

struct Matrix {
    let rows: Int, columns: Int
    var grid: [Double]
    var shape: (Int, Int)
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        self.shape = (rows, columns)
        grid = Array(repeating: 0.0, count: rows * columns)
    }
    func indexIsValid(_ row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    subscript(row: Int, column: Int) -> Double {
        get {
            return grid[(row * columns) + column]
        }
        set {
            grid[(row * columns) + column] = newValue
        }
    }
    func negate(_ x: Matrix) -> Matrix {
        var results = x
        vDSP_vnegD(x.grid, 1, &(results.grid), 1, UInt(x.grid.count))
        return results
    }
    func add(_ x: Matrix, y: Matrix) -> Matrix {
        var results = x
        vDSP_vaddD(x.grid, 1, y.grid, 1, &(results.grid), 1, UInt(x.grid.count))
        return results
    }
    func mul(_ x: Matrix, y: Matrix) -> Matrix {
        var results = x
        vDSP_vmulD(x.grid, 1, y.grid, 1, &(results.grid), 1, vDSP_Length(x.grid.count))
        return results
    }
    func dot(_ x: Matrix, y: Matrix) -> Matrix {
        var results = x //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! size change
        vDSP_dotprD(x.grid, 1, y.grid, 1, &(results.grid), UInt(x.grid.count))
        return results
    }
    func transpose(_ x: Matrix) -> Matrix {
        var results = x
        vDSP_mtransD(x.grid, 1, &(results.grid), 1, vDSP_Length(results.rows), vDSP_Length(results.columns))
        return results
    }
    func inverse(_ x: Matrix) -> Matrix {
        let results = x
        /*
         dgetrf_(UnsafeMutablePointer<__CLPK_integer>, <#T##UnsafeMutablePointer<__CLPK_integer>#>, <#T##UnsafeMutablePointer<__CLPK_doublereal>#>, <#T##UnsafeMutablePointer<__CLPK_integer>#>, <#T##UnsafeMutablePointer<__CLPK_integer>#>, <#T##UnsafeMutablePointer<__CLPK_integer>#>)
         */
        return results
    }
    func invert(_ matrix : [Double]) -> [Double] {
        var inMatrix = matrix
        var N = __CLPK_integer(sqrt(Double(matrix.count)))
        var pivots = [__CLPK_integer](repeating: 0, count: Int(N))
        var workspace = [Double](repeating: 0.0, count: Int(N))
        var error : __CLPK_integer = 0
        dgetrf_(&N, &N, &inMatrix, &N, &pivots, &error)
        dgetri_(&N, &inMatrix, &N, &pivots, &workspace, &N, &error)
        return inMatrix
    }
    
    //inverse
}
