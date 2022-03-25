
import RealityKit
import Combine
import CoreGraphics
import ARKit
import UIKit
import SwiftUI
import CoreMotion
var motion = CMMotionManager()
public var gyrox: Double = 0.0


public extension ARView {
    func runBodyTrackingConfig2D() throws {
        //This is more efficient if you are just using 2D and Not 3D tracking.
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.bodyDetection) else {
            let errorMessage = "This device does Not support body detection."
            print(errorMessage)
            return //throw BodyTrackingError.runtimeError(errorMessage)
        }
        let config2D = ARWorldTrackingConfiguration()
        config2D.frameSemantics = .bodyDetection
        self.session.run(config2D)
    }
}


public class BodyTracker2D {
    
    internal weak var arView : ARView!
    
    private var cancellableForUpdate : Cancellable?
    
    ///The positions of the joints on screen.
    ///
    /// - (0,0) is in the top-left.
    /// - Use the `rawValue` of a `TwoDBodyJoint` to index.
    public private(set) var jointScreenPositions : [CGPoint]!

    public private(set) var trackedViews = [TwoDBodyJoint : UIView]()
    
    //adding a variable to store the view for bones, so that I can remove them
    public private(set) var trackedBones = [String : UIView]()
    
    ///True if a body is detected in the current frame.
    public private(set) var bodyIsDetected = false
    
    public required init(arView: ARView) {
        self.arView = arView
        self.subscribeToUpdates()
        self.populateJointPositions()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    /// Destroy this Entity and its references to any ARViews
    /// This helps prevent memory leaks.
    public func destroy() {
      self.arView = nil
        self.cancellableForUpdate?.cancel()
        self.cancellableForUpdate = nil
        self.jointScreenPositions = []
        self.trackedViews.forEach { view in
            view.value.removeFromSuperview()
        }
        
        //removing all bones
        self.trackedBones.forEach { view in
            view.value.removeFromSuperview()
        }
        self.trackedViews.removeAll()
        
        self.trackedBones.removeAll()
    }
    
    
    
    
    //Subscribe to scene updates so we can run code every frame without a delegate.
    //For RealityKit 2 we should use a RealityKit System instead of this update function but that would be limited to devices running iOS 15.0+
    private func subscribeToUpdates(){
        self.cancellableForUpdate = self.arView.scene.subscribe(to: SceneEvents.Update.self, updateBody)
    }
    
    private func populateJointPositions() {
        jointScreenPositions = []
        for _ in 0...16 {
            jointScreenPositions.append(CGPoint())
            
            
        
        }
    }
    
    ///Allows only one view per joint.
    ///- This will add `thisView` to ARView automatically.
    ///- If you would like to attach more than one view per joint, then try attaching additional views to the view that is already attached to this joint.
    ///This function ATTACHES CIRCLES for every joint
    public func attach(thisView: UIView, toThisJoint thisJoint: TwoDBodyJoint){
        self.trackedViews[thisJoint] = thisView
        if thisView.superview == nil {
            arView.addSubview(thisView)
        }
    }
    
    public func attachLine(thisNewView: UIView, ofThisBone: String){
        self.trackedBones[ofThisBone] = thisNewView
        if thisNewView.superview == nil {
            arView.addSubview(thisNewView)
        }
    }
    
  
    
    
    public func removeJoint(_ joint: TwoDBodyJoint){
        self.trackedViews[joint]?.removeFromSuperview()
        self.trackedViews.removeValue(forKey: joint)
    }
    
    public func removeBone(_ bone: String){
        self.trackedBones[bone]?.removeFromSuperview()
        self.trackedBones.removeValue(forKey: bone)
    }
    
    //Run this code every frame to get the joints.
    public func updateBody(event: SceneEvents.Update? = nil) {
        guard
            let frame = self.arView.session.currentFrame
        else {return}
        updateJointScreenPositions(frame: frame)
        updateTrackedViews(frame: frame)

    }
    
    private func updateJointScreenPositions(frame: ARFrame) {
        guard let detectedBody = frame.detectedBody else {
            if bodyIsDetected == true {bodyIsDetected = false}
            return
        }
        if bodyIsDetected == false {bodyIsDetected = true}
        
        guard let interfaceOrientation = self.arView.window?.windowScene?.interfaceOrientation else { return }
        
        let jointLandmarks = detectedBody.skeleton.jointLandmarks
        
        //----------------------------------------------------------------------------------------------------
        //Convert the normalized joint points into screen-space CGPoints.
        let transform = frame.displayTransform(for: interfaceOrientation, viewportSize: self.arView.frame.size)
        //----------------------------------------------------------------------------------------------------
        
        for i in 0..<jointLandmarks.count {
                if jointLandmarks[i].x.isNaN || jointLandmarks[i].y.isNaN {
                    continue
                }
            
                let point = CGPoint(x: CGFloat(jointLandmarks[i].x),
                                    y: CGFloat(jointLandmarks[i].y))
            
            //----------------------------------------------------------------------------------------------------
                //Convert from normalized pixel coordinates (0,0 top-left, 1,1 bottom-right)
                //to screen-space coordinates.
                let normalizedCenter = point.applying(transform)
                let center = normalizedCenter.applying(CGAffineTransform.identity.scaledBy(x: self.arView.frame.width, y: self.arView.frame.height))
                self.jointScreenPositions[i] = center
           
          
            
        }
       
    }
    
    func updateTrackedViews(frame: ARFrame){
        guard frame.detectedBody != nil,
              jointScreenPositions.count > 0
        else {return}
        
        for view in trackedViews {
            let jointIndex = view.key.rawValue
            //print("jointIndex in trackedViews is: \(jointIndex)") this is the number of the joint
            let screenPosition = jointScreenPositions[jointIndex]
            //print("screenPosition in trackedViews is: \(screenPosition)") this returns the creen position of the joint every frame
            view.value.center = screenPosition
        }
    }

    ///Returns the angle (in degrees) between 3 given joints, treating joint2 as the center point.
    /// - The maximum angle is 180.0°
    /// - See "ARView2D.swift" for an example usage.
    public func angleBetween3Joints(_ joint1: TwoDBodyJoint,
                                   _ joint2: TwoDBodyJoint,
                                   _ joint3: TwoDBodyJoint) -> CGFloat? {
        let joint1Index = joint1.rawValue
        let joint2Index = joint2.rawValue
        let joint3Index = joint3.rawValue
        
        //Make sure the joints we are looking for are included in jointScreenPositions.
        guard let maxIndex = [joint1Index, joint2Index, joint3Index].max(),
              (jointScreenPositions.count - 1) >= maxIndex else { return nil }
        
        let joint1ScreenPosition = jointScreenPositions[joint1Index]
        let joint2ScreenPosition = jointScreenPositions[joint2Index]
        let joint3ScreenPosition = jointScreenPositions[joint3Index]
        
        let vect1 = (joint1ScreenPosition - joint2ScreenPosition).simdVect()
        let vect2 = (joint3ScreenPosition - joint2ScreenPosition).simdVect()
        
        let top = dot(vect1, vect2)
        let bottom = length(vect1) * length(vect2)
        let angleInRadians = CGFloat(acos(top / bottom))
        let angleInDegrees = (angleInRadians * 180) / .pi
        return angleInDegrees
    }
    

    ///
    /// Returns the angle (in degrees) between down and the vector formed by the two given points.
    /// - In the UIKit coordinate system, (0,0) is in the top-left corner.
    /// - See "ARView2D.swift" for an example usage.
    /// - Returns: A vector pointing straight down returns 0.0.
    ///A vector pointing to the right returns 270.0.
    ///A vector pointing up returns 180.0.
    ///A vector pointing to the left returns 90.0.
    public func angleFrom2Joints(_ joint1: TwoDBodyJoint,
                                 _ joint2: TwoDBodyJoint) -> CGFloat? {
        let joint1Index = joint1.rawValue
        let joint2Index = joint2.rawValue
        
        //Make sure the joints we are looking for are included in jointScreenPositions.
        guard (jointScreenPositions.count - 1) >= max(joint1Index, joint2Index) else { return nil }
        
        let joint1ScreenPosition = jointScreenPositions[joint1Index]
        let joint2ScreenPosition = jointScreenPositions[joint2Index]
        
      //  print("joint 1 Position X: \(joint1ScreenPosition.x) \n")
      //  print("joint 1 Position: \(joint1ScreenPosition)")

        return angleBetween2Points(point1: joint1ScreenPosition,
                                         point2: joint2ScreenPosition)
    }
    
    private func angleBetween2Points(point1: CGPoint, point2: CGPoint) -> CGFloat {
        let difference = point1 - point2
        let angleInRadians = atan2(difference.y, difference.x)
        var angleInDegrees = GLKMathRadiansToDegrees(Float(angleInRadians))
        angleInDegrees -= 90
        if (angleInDegrees < 0) { angleInDegrees += 360.0 }
        return CGFloat(angleInDegrees)
    }
    
//    //------ Angle between 3 joints to test is the back is rounding ------
//    public func angleBetween3Joints(_ joint1: TwoDBodyJoint,
//                                   _ joint2: TwoDBodyJoint,
//                                   _ joint3: TwoDBodyJoint) -> CGFloat? {
//        let joint1Index = joint1.rawValue
//        let joint2Index = joint2.rawValue
//        let joint3Index = joint3.rawValue
//
//        //Make sure the joints we are looking for are included in jointScreenPositions.
//        guard let maxIndex = [joint1Index, joint2Index, joint3Index].max(),
//              (jointScreenPositions.count - 1) >= maxIndex else { return nil }
//
//        let joint1ScreenPosition = jointScreenPositions[joint1Index]
//        let joint2ScreenPosition = jointScreenPositions[joint2Index]
//        let joint3ScreenPosition = jointScreenPositions[joint3Index]
//
//        let vect1 = (joint1ScreenPosition - joint2ScreenPosition).simdVect()
//        let vect2 = (joint3ScreenPosition - joint2ScreenPosition).simdVect()
//
//        let top = dot(vect1, vect2)
//        let bottom = length(vect1) * length(vect2)
//        let angleInRadians = CGFloat(acos(top / bottom))
//        let angleInDegrees = (angleInRadians * 180) / .pi
//        return angleInDegrees
//    }
    
    
    
    
    
    
//    //-------------------- Calculate a spine joint at 1/4th of the distance between hip and shoulder --------------------------------------
//        public func spine_1_Line(_ joint1: TwoDBodyJoint,
//                                 _ joint2: CGPoint) -> UIView {
//            let joint1Index = joint1.rawValue
//            let joint2Index = joint2
//
//
//
//            let joint1ScreenPosition = jointScreenPositions[joint1Index]
//            let joint2ScreenPosition = joint2Index
//
//            let fillColor: CGColor = #colorLiteral(red: 0.250980392156863, green: 0.250980392156863, blue: 0.250980392156863, alpha: 0.0)
//            let strokeColor: CGColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
//
//
//            return DrawLine(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), start:  joint1ScreenPosition, end: joint2ScreenPosition, fill: fillColor, stroke: strokeColor, strokeWidth: 3)
//        }
    //---------------------------------------------------------------------------------------------
    
    
    
    //-------------------- return the coordinates of a joint in TwoDBodyJoint --------------------------------------
        public func joint_coord(coordForJoint: TwoDBodyJoint) -> CGPoint {
           
            let joint1Index = coordForJoint.rawValue
            let joint1ScreenPosition = jointScreenPositions[joint1Index]
      
            return joint1ScreenPosition
        }
    //---------------------------------------------------------------------------------------------
    
    
    
    
    
    //-------------------- Draw line between hip and spine 1 --------------------------------------
//        public func spine_joint(_ lowerJoint: TwoDBodyJoint,
//                                _ upperJoint: TwoDBodyJoint, dist: CGFloat, segment: CGFloat) -> CGPoint {
//
//            let joint1Index = lowerJoint.rawValue
//            let joint2Index = upperJoint.rawValue
//
//
//
//            let joint1ScreenPosition = jointScreenPositions[joint1Index]
//            let joint2ScreenPosition = jointScreenPositions[joint2Index]
//            var spineJoint = joint1ScreenPosition //we initialize the spine joint with the hip joint for reference purposes (turns spineJoint into a CGPoint)
//
//            if joint1ScreenPosition.x <= joint2ScreenPosition.x  {
//                spineJoint.x = joint1ScreenPosition.x + (abs(joint1ScreenPosition.x - joint2ScreenPosition.x) / dist)
//            } else {
//                spineJoint.x = joint2ScreenPosition.x + (abs(joint1ScreenPosition.x - joint2ScreenPosition.x) / dist)
//
//            }
//
//            if joint1ScreenPosition.y >= joint2ScreenPosition.y {
//                spineJoint.y = abs(joint1ScreenPosition.y - (abs(joint1ScreenPosition.y - joint2ScreenPosition.y) / dist))
//            } else {
//                spineJoint.y = abs(joint2ScreenPosition.y - (abs(joint1ScreenPosition.y - joint2ScreenPosition.y) / dist))
//            }
//
//
//
//
//
//
//
//            return spineJoint
//        }
    //---------------------------------------------------------------------------------------------
    
    
    //---------- Create a ghost joint to calculate the sheer force from the shoulder --------------------------------------
    //New function to determine the angle betwen the shoulder and a fixed point at the bottom of the screen modified to be offset to the right based on the .right_foot_joint, in order to create the path of a sheer force during a squat. The angle between the ground point and the shoulder should always be 0 (or close to 0) which will determine a perfect squat position
    public func angleFromShoulderToGround() -> CGFloat? {
        //joint 1 has to be the modified right foot joint which is planted on the ground
        //joint 2 always has to be the shoulder joint
        let joint1Index = 10 // right_foot_joint = 10
        let joint2Index = 2 //right_shoulder_1_joint = 2
        
        let joint1ScreenPosition = jointScreenPositions[joint1Index] //this needs modified
        let joint2ScreenPosition = jointScreenPositions[joint2Index] //this is accurate and we keep
        var joint1ScreenPositionOffset = jointScreenPositions[joint1Index] //we initialise the offset so that reference can occur which enables us to access the x and y values
        
        joint1ScreenPositionOffset.x = joint1ScreenPosition.x + 10
        joint1ScreenPositionOffset.y = UIScreen.main.bounds.size.height
        
//        print("joint 1 Position X: \(joint1ScreenPositionOffset.x) , Y: \(joint1ScreenPositionOffset.y)\n")
//        print("joint 1 Position: \(joint1ScreenPosition)")
        


        return angleBetweenShoulderAndGround(point1: joint1ScreenPositionOffset,
                                         point2: joint2ScreenPosition)
    }
    
    private func angleBetweenShoulderAndGround(point1: CGPoint, point2: CGPoint) -> CGFloat {
        let difference = point1 - point2
        let angleInRadians = atan2(difference.y, difference.x)
        var angleInDegrees = GLKMathRadiansToDegrees(Float(angleInRadians))
        angleInDegrees -= 90
        if (angleInDegrees < 0) { angleInDegrees += 360.0 }
        return CGFloat(angleInDegrees)
    }
    
    
    
    
    ///AM I USING THIS?????
//---------- Hard code parameters to calculate the 3 point angle at the neck / shoulder between the sheer force at the ground, the neck and the hip --------------------------------------
    public func angleBetweenForceNeckHip() -> CGFloat? {
        let joint1Index = 10 // right_foot_joint = 10 , to be offset x + 10
        let joint2Index = 1 // neck joint = shoulder joint from the side neck_1_joint = 1
        let joint3Index = 8 //right_upLeg_joint = 8
        
        //Make sure the joints we are looking for are included in jointScreenPositions.
       // guard let maxIndex = [joint1Index, joint2Index, joint3Index].max(),
             // (jointScreenPositions.count - 1) >= maxIndex else { return nil }
        
        let joint1ScreenPosition = jointScreenPositions[joint1Index] //this needs modified
        let joint2ScreenPosition = jointScreenPositions[joint2Index] //this is the angle we want
        let joint3ScreenPosition = jointScreenPositions[joint3Index] //this is the hip
        var joint1ScreenPositionOffset = jointScreenPositions[joint1Index] //we initialise the offset so that reference can occur which enables us to access the x and y values
        
        joint1ScreenPositionOffset.x = joint1ScreenPosition.x + 10
        joint1ScreenPositionOffset.y = UIScreen.main.bounds.size.height
        
        let vect1 = (joint1ScreenPositionOffset - joint2ScreenPosition).simdVect()
        let vect2 = (joint3ScreenPosition - joint2ScreenPosition).simdVect()
        
        let top = dot(vect1, vect2)
        let bottom = length(vect1) * length(vect2)
        let angleInRadians = CGFloat(acos(top / bottom))
        let angleInDegrees = (angleInRadians * 180) / .pi
        return angleInDegrees
    }
    
    
//--------------------ADD Path between two joints --------------------------------------
    public func lineBetween2Joints(_ joint1: TwoDBodyJoint,
                                 _ joint2: TwoDBodyJoint) -> UIView {
        let joint1Index = joint1.rawValue
        let joint2Index = joint2.rawValue


        let joint1ScreenPosition = jointScreenPositions[joint1Index]
        let joint2ScreenPosition = jointScreenPositions[joint2Index]
        
        let fillColor: CGColor = #colorLiteral(red: 0.250980392156863, green: 0.250980392156863, blue: 0.250980392156863, alpha: 0.0)
        let strokeColor: CGColor = #colorLiteral(red: 0.670588235294118, green: 0.898039215686275, blue: 0.12156862745098, alpha: 1)
        


        return DrawLine(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), start: joint1ScreenPosition, end: joint2ScreenPosition, fill: fillColor, stroke: strokeColor, strokeWidth: 3.0)
    }
//---------------------------------------------------------------------------------------------
    
    
//stroke: CGColor = (red: 0.670588235294118, green: 0.898039215686275, blue: 0.12156862745098, alpha: 1) //#colorLiteral
    
    
    
//-------------------- Draw Sheer Force Angle line between shoulder and foot --------------------------------------
    public func sheerForceAngleLine() -> UIView {
        let joint1Index = 10 // right_foot_joint = 10
        let joint2Index = 2 //right_shoulder_1_joint = 2


        let joint1ScreenPosition = jointScreenPositions[joint1Index] //this needs modified
        let joint2ScreenPosition = jointScreenPositions[joint2Index] //this is accurate and we keep
        var joint1ScreenPositionOffset = jointScreenPositions[joint1Index] //we initialise the offset so that reference can occur which enables us to access the x and y values
        
        joint1ScreenPositionOffset.x = joint1ScreenPosition.x + 10
        joint1ScreenPositionOffset.y = joint1ScreenPosition.y - 10
        
        let fillColor: CGColor = #colorLiteral(red: 0.250980392156863, green: 0.250980392156863, blue: 0.250980392156863, alpha: 0.0)
        let strokeColor: CGColor = #colorLiteral(red: 0.670588235294118, green: 0.898039215686275, blue: 0.12156862745098, alpha: 1)


        return DrawLine(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), start:  joint1ScreenPositionOffset, end: joint2ScreenPosition, fill: fillColor, stroke: strokeColor, strokeWidth: 4.5)
    }
//---------------------------------------------------------------------------------------------

//-------------------- Draw Sheer Force PATH for user self analysis --------------------------------------
    public func sheerForcePath() -> UIView {
        let joint1Index = 10 // right_foot_joint = 10
        let joint2Index = 2 //right_shoulder_1_joint = 2


        var joint1ScreenPosition = jointScreenPositions[joint1Index] //this is the ghost joint offsetted from the right foot joint
        joint1ScreenPosition.x = joint1ScreenPosition.x + 10
        joint1ScreenPosition.y = joint1ScreenPosition.y + 25
        
        var joint2ScreenPosition = jointScreenPositions[joint2Index] //this the point to be offset at the shoulder height and perpendicular to the ghost joint
        joint2ScreenPosition.x = joint1ScreenPosition.x //so that the points are perpendicular
        joint2ScreenPosition.y = joint2ScreenPosition.y - 30 //to raise is slightli higher for visibility
        
        let fillColor: CGColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0)
        let strokeColor: CGColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0.5)


        return DrawLine(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), start:  joint1ScreenPosition, end: joint2ScreenPosition, fill: fillColor, stroke: strokeColor, strokeWidth: 70)
    }
//---------------------------------------------------------------------------------------------
    
    
    
    
    
    
    
    
//--------------------Calculate distance between two joints --------------------------------------
        public func distanceBetween2Joints(_ joint1: TwoDBodyJoint,
                                     _ joint2: TwoDBodyJoint) -> CGFloat {
            let joint1Index = joint1.rawValue
            let joint2Index = joint2.rawValue


            let joint1ScreenPosition = jointScreenPositions[joint1Index]
            let joint2ScreenPosition = jointScreenPositions[joint2Index]
            
            let xDist : CGFloat = joint2ScreenPosition.x - joint1ScreenPosition.x //[2]
            let yDist : CGFloat = (joint2ScreenPosition.y - joint1ScreenPosition.y) //[3]
            let distance : CGFloat = sqrt((xDist * xDist) + (yDist * yDist)) //[4]
            
            return distance
        }
//---------------------------------------------------------------------------------------------
    
    
//--------------------Calculate distance between a joint and a screen edge --------------------------------------
        public func distanceBetweenJointAndScreenEdge(_ joint: TwoDBodyJoint,
                                                      _ edge: String) -> CGFloat {
            let joint1Index = joint.rawValue
            let joint1ScreenPosition = jointScreenPositions[joint1Index]
            var joint2ScreenPosition = joint1ScreenPosition
            
            if edge == "top"{
                joint2ScreenPosition.y = 0
            }
            if edge == "bottom"{
                 joint2ScreenPosition.y = UIScreen.main.bounds.size.height
            }
            if edge == "middle"{
                 joint2ScreenPosition.x = UIScreen.main.bounds.size.width / 2
            }
//            if edge == "left"{
//                 joint2ScreenPosition.x = 0
//            }
//            if edge == "right"{
//                 joint2ScreenPosition.x = UIScreen.main.bounds.size.width
//            }
           
                
            let xDist : CGFloat = joint2ScreenPosition.x - joint1ScreenPosition.x //[2]
            let yDist : CGFloat = (joint2ScreenPosition.y - joint1ScreenPosition.y) //[3]
            let distance : CGFloat = sqrt((xDist * xDist) + (yDist * yDist)) //[4]
                
            return distance
        }


           
            
        
//---------------------------------------------------------------------------------------------
    
    
    ///GYROSCOPE
    public func MyGyro() -> Double {
        motion.gyroUpdateInterval = 0.5
        motion.startGyroUpdates(to: OperationQueue.current!) { (data, error) in
            if let trueData = data{
                gyrox = trueData.rotationRate.x
            }
            
        }
        return gyrox
    }
        
        
        
        
        
        //-------------------
    
}

public extension CGPoint {

    /// Extracts the screen space point from a vector returned by SCNView.projectPoint(_:).
    init(_ vector: SCNVector3) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }
    
    func simdVect() -> simd_float2 {
        return simd_float2(Float(self.x), Float(self.y))
    }
    
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
    
    static func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }

    /// Returns the length of a point when considered as a vector. (Used with gesture recognizers.)
    var length: CGFloat {
        return sqrt(x * x + y * y)
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint{
        return CGPoint(x: lhs.x - rhs.x,
                       y: lhs.y - rhs.y)
    }
    
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint{
        return CGPoint(x: lhs.x + rhs.x,
                       y: lhs.y + rhs.y)
    }
    
    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint{
        return CGPoint(x: lhs.x * rhs,
                       y: lhs.y * rhs)
    }
    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint{
        return CGPoint(x: lhs.x / rhs,
                       y: lhs.y / rhs)
    }

}


///ARSkeleton.JointName only contains 8 of these but this includes all of them :)
///
///Includes 17 joints.
///- Use TwoDBodyJoint.allCases to access an array of all joints
public enum TwoDBodyJoint: Int, CaseIterable {
    case head_joint = 0
    case neck_1_joint = 1
    case right_shoulder_1_joint = 2
    case right_forearm_joint = 3
    case right_hand_joint = 4
    case left_shoulder_1_joint = 5
    case left_forearm_joint = 6
    case left_hand_joint = 7
    case right_upLeg_joint = 8
    case right_leg_joint = 9
    case right_foot_joint = 10
    case left_upLeg_joint = 11
    case left_leg_joint = 12
    case left_foot_joint = 13
    case right_eye_joint = 14
    case left_eye_joint = 15
    case root = 16 //hips
}






//---------------------------- Add Line between points------------

class DrawLine: UIView {
    
    var path: UIBezierPath!
    var startPoint: CGPoint?
    var endPoint: CGPoint?
    var strokeColour: CGColor?
    var fillColour: CGColor?
    var strokeWidth: CGFloat?

    
    init(frame: CGRect, start: CGPoint, end: CGPoint, fill: CGColor, stroke: CGColor, strokeWidth: CGFloat){
      
      self.startPoint = start
      self.endPoint = end
      self.fillColour = fill
      self.strokeColour = stroke
      self.strokeWidth = strokeWidth
      super.init(frame: frame)
      
      simpleShapeLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        
       super.init(coder: aDecoder)
    }
    
    func createLine(start: CGPoint, end: CGPoint) {
        path = UIBezierPath()
        
        path.move(to: start)
        path.addLine(to: end)
    }
        
    
    //create the CAShapeLayer Object because it's more versatile and can define stroke width. We assign the path of the BezierPath from above
    func simpleShapeLayer() {
        self.createLine(start: startPoint!, end: endPoint!)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = self.path.cgPath
        
        
        shapeLayer.fillColor = fillColour
        shapeLayer.strokeColor = strokeColour
        shapeLayer.lineWidth = strokeWidth!
        
        self.layer.addSublayer(shapeLayer)
        
        
    }
    
    
}


