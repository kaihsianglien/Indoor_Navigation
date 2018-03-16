
import UIKit


class MapViewController: UIViewController, DataProcessorDelegate {
    
    // MARK: Model
    var dataSource: DataProcessor? = nil
    var origin = ThreeAxesSystem<Double>(x: 0, y: 0, z: 0)
    
    // MARK: PublicDB used to pass the object of DataProcessor
    var publicDB = UserDefaults.standard
    
    // MARK: Multi-views declaration
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var mapView: MapView! {
        didSet {
            
            // add pinch gesture recog
            mapView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: self, action: #selector(MapViewController.changeScale(_:))
                ))
            
            // add swipe gestures recog
            let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MapViewController.moveScreenToRight))
            rightSwipeGestureRecognizer.direction = .right
            mapView.addGestureRecognizer(rightSwipeGestureRecognizer)
            
            let upSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MapViewController.moveScreenToUp))
            upSwipeGestureRecognizer.direction = .up
            mapView.addGestureRecognizer(upSwipeGestureRecognizer)
            
            let downSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MapViewController.moveScreenToDown))
            downSwipeGestureRecognizer.direction = .down
            mapView.addGestureRecognizer(downSwipeGestureRecognizer)
            
            let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MapViewController.moveScreenToLeft))
            leftSwipeGestureRecognizer.direction = .left
            mapView.addGestureRecognizer(leftSwipeGestureRecognizer)
            
        }
    }
    
    /* MARK: Gesture Functions */
    var pinchScale: CGFloat = 1
    
    func changeScale(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            pinchScale *= recognizer.scale
            pinchScale = toZeroPointFiveMultiples(pinchScale) // let pinchScale always be the multiples of 0.5 to keep the textLayer clean.
            
            if pinchScale == 0 { // restrict the minimum scale to 0.5 instead of 0, otherwise the scale will always be 0 afterwards.
                pinchScale = 0.5
            }
            
            let times = pinchScale/CGFloat(gridView.scaleValueForTheText)
            
            if gridView.scaleValueForTheText != 0.5 || pinchScale != 0.5 {
                mapView.setScale(Double(1/times))
            }
            
            gridView.setScale(Double(pinchScale))
            recognizer.scale = 1
        default:
            break
        }

    }
    
    var shiftedBySwipe = ThreeAxesSystem<Double>(x:0, y:0, z:0)
    let shiftAmount: Double = 20
    
    func moveScreenToRight() {
        shiftedBySwipe.x += shiftAmount
        origin.x += shiftAmount
        setOrigin(origin.x, y: origin.y)
    }
    
    func moveScreenToUp() {
        shiftedBySwipe.y -= shiftAmount
        origin.y -= shiftAmount
        setOrigin(origin.x, y: origin.y)
    }
    
    func moveScreenToDown() {
        shiftedBySwipe.y += shiftAmount
        origin.y += shiftAmount
        setOrigin(origin.x, y: origin.y)
    }
    
    func moveScreenToLeft() {
        shiftedBySwipe.x -= shiftAmount
        origin.x -= shiftAmount
        setOrigin(origin.x, y: origin.y)
    }
    
    // MARK: Outlets
    @IBOutlet weak var accX: UILabel!
    @IBOutlet weak var accY: UILabel!
    @IBOutlet weak var velX: UILabel!
    @IBOutlet weak var velY: UILabel!
    @IBOutlet weak var disX: UILabel!
    @IBOutlet weak var disY: UILabel!
    
    @IBAction func cleanpath(_ sender: UIButton) {
        mapView?.cleanPath()
    }
    
    fileprivate func setOrigin(_ x: Double, y: Double) {
        gridView?.setOrigin(x, y: y)
        mapView?.setOrigin(x, y: y)
    }
    
    fileprivate func updateUIWithGivenFrame(_ originX: CGFloat, originY: CGFloat, width: CGFloat, height: CGFloat) {
        // All view are set based on the "gradientView" (background)
        gradientView.frame = CGRect(x: originX, y: originY, width: width, height: height)
        gridView.frame = gradientView.frame
        mapView.frame = gradientView.frame
        (origin.x, origin.y) = (Double(gradientView.frame.midX) + shiftedBySwipe.x, Double(gradientView.frame.midY) + shiftedBySwipe.y)
        setOrigin(origin.x, y: origin.y)
    }
    
    // MARK: Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(receiveDataSource(_:)), name:NSNotification.Name(rawValue: "dataSource"), object: nil)
        
        // Objects setup
        gradientView.colorSetUp(UIColor.white.cgColor, bottomColor: UIColor.cyan.withAlphaComponent(0.5).cgColor)
        
        gridView.backgroundColor = UIColor.clear
        gridView.setScale(1.0)
        
        mapView.backgroundColor = UIColor.clear
        mapView.setScale(1.0)
        
        updateUIWithGivenFrame(view.frame.origin.x, originY: view.frame.origin.y, width: view.frame.width, height: view.frame.height)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            // Landscape orientation
            if mapView != nil {
                updateUIWithGivenFrame(view.frame.origin.x, originY: view.frame.origin.y, width: view.frame.height, height: view.frame.width)
            }
     } else {
            // Portrait orientation
            if mapView != nil {
                updateUIWithGivenFrame(view.frame.origin.x, originY: view.frame.origin.y, width: view.frame.height, height: view.frame.width)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource?.delegate = self
    }
    
    // MARK: Notification center functions
    func receiveDataSource(_ notification: Notification) {
        if let source = notification.object as? DataProcessor {
            dataSource = source
            dataSource!.startsDetection()
        }
    }
    
    // MARK: Delegate
    func sendingNewData(_ person: DataProcessor, type: speedDataType, data: ThreeAxesSystemDouble) {
        switch type {
        case .accelerate:
            accX.text = "\(roundNum(Double(data.x)))"
            accY.text = "\(roundNum(Double(data.y)))"
        case .velocity:
            velX.text = "\(roundNum(Double(data.x)))"
            velY.text = "\(roundNum(Double(data.y)))"
        case .distance:
            let magnify = 20.0 // this var is used to make the movement more observable. Basically, if the scale of the map is 1, then magnify should be 20. if 2, then 40.
            mapView.movePointTo(Double(data.x) * magnify, y: Double(data.y) * magnify)
            disX.text = "\(roundNum(Double(data.x)))"
            disY.text = "\(roundNum(Double(data.y)))"
        }
    }
    
    func sendingNewStatus(_ person: DataProcessor, status: String) {
        // intentionally left blank in order to conform to the protocol
    }
}
