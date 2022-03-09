//
//  ARView.swift
//  Body Tracking
//
//  Created by Grant Jarvis on 3/25/21.
//

import ARKit
import RealityKit
import BodyTracking

class ARSUIView2D: BodyARView {
    

    private var bodyTracker: BodyTracker2D!
    
    ///Use this to display the angle formed at this joint.
    ///See the call to "angleBetween3Joints" below.
    private var angleLabel: UILabel!
    
    
    
// --------------------------------------------------------------
    //declare the path between joints
//    var pathEntity : RKPathEntity!
//    
//    var hitPoints = [simd_float3]() {
//        didSet {
//            self.pathEntity.pathPoints = self.hitPoints
//        }
//    }
// --------------------------------------------------------------

    // Track the screen dimensions:
    lazy var windowWidth: CGFloat = {
        return UIScreen.main.bounds.size.width
    }()
    
    lazy var windowHeight: CGFloat = {
        return UIScreen.main.bounds.size.height
    }()
    
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.bodyTracker = BodyTracker2D(arView: self)
        guard let _ = try? runBodyTrackingConfig2D() else { return }
        self.session.delegate = self
        
        makeRightElbowJointVisible()
// --------------------------------------------------------------
        //Path between joints
//        self.pathEntity = RKPathEntity(arView: self,
//                                      path: [],
//                                      width: 0.15,
//                                      materials: [UnlitMaterial.init(color: .blue)])
// --------------------------------------------------------------
        
        makeOtherJointsVisible()
    }
    
    
    ///This is an example for how to show one joint.
    private func makeRightElbowJointVisible(){
        
        let rightElbowCircle = makeCircle(circleRadius: 20)
        // ** HERE is the useful code: **
        //How to attach views to the skeleton:
        self.bodyTracker.attach(thisView: rightElbowCircle, toThisJoint: .right_forearm_joint)
        
        //Use this to display the angle formed at this joint.
        //See the call to "angleBetween3Joints" below.
        angleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 50)))
        rightElbowCircle.addSubview(angleLabel)
    }
    
    
    ///This is an example for how to show multiple joints, iteratively.
    private func makeOtherJointsVisible(){
        //There are more joints you could attach views to, I'm just using these.
        let jointsToShow : [TwoDBodyJoint] = [.right_hand_joint, .right_shoulder_1_joint,
                                           .left_forearm_joint, .left_hand_joint,
                                           .left_shoulder_1_joint,
                                           .head_joint, .neck_1_joint,
                                           .root, .right_leg_joint,
                                           .right_foot_joint, .left_leg_joint,
                                           .left_foot_joint]
        
        //Another way to attach views to the skeletion, but iteratively this time:
        //CHANGE THE WAY THE CIRCLES LOOK
        jointsToShow.forEach { joint in
            let circle = makeCircle(circleRadius: 40)
            self.bodyTracker.attach(thisView: circle, toThisJoint: joint)
            //self.bodyTracker.jointScreenPositions.distance(from: , to: <#T##Int#>)
           //self.hitPoints.append(joint)
            //print("\(joint) position is: \(joint.rawValue)")
           // self.bodyTracker.drawLine()
        }
        
    }
    
    
    
    

    
    override func stopSession(){
        super.stopSession()
           self.bodyTracker.destroy()
            self.bodyTracker = nil
           self.angleLabel.removeFromSuperview()
       }
    
    //setting the stroke colour to the branded GREEN and circle color to dark grey
    private func makeCircle(circleRadius: CGFloat = 72, stroke: CGColor = #colorLiteral(red: 0.670588235294118, green: 0.898039215686275, blue: 0.12156862745098, alpha: 1),
                            color: CGColor = #colorLiteral(red: 0.250980392156863, green: 0.250980392156863, blue: 0.250980392156863, alpha: 0.5)) -> UIView {
        
        // Place circle at the center of the screen to start.
        let xStart = floor((windowWidth - circleRadius) / 2)
        let yStart = floor((windowHeight - circleRadius) / 2)
        let frame = CGRect(x: xStart, y: yStart, width: circleRadius, height: circleRadius)
        
        let circleView = UIView(frame: frame)
        circleView.layer.cornerRadius = circleRadius / 2
        circleView.layer.backgroundColor = color
        circleView.layer.borderColor = stroke
        circleView.layer.borderWidth = 3
        return circleView
    }
    
    
    
    
    //required function.
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ARSUIView2D: ARSessionDelegate {
    
    //For RealityKit 2 we should use a RealityKit System instead of this update function but that would be limited to devices running iOS 15.0+
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        //The formatting rounds the number.
        if let jointAngle = self.bodyTracker.angleBetween3Joints(.right_hand_joint,
                                                                .right_forearm_joint,
                                                                .right_shoulder_1_joint) {
            self.angleLabel.text = String(format: "%.0f", Float(jointAngle))
        }
        
        //------Draw line between joints-------
//        self.bodyTracker.pathBetween2Joints(.right_forearm_joint, .right_hand_joint){
//            Path { path in
//                path.move(to: <#T##CoreGraphics.CGPoint#>)
//            }
//        }
        
        //-------------------------------------
        
        //Uncomment to show the angle formed by 2 joints instead of by 3 joints.
//        if let jointAngle = self.bodyTracker.angleFrom2Joints(.right_forearm_joint, .right_shoulder_1_joint) {
//            self.angleLabel.text = String(format: "%.0f", Float(jointAngle))
//        }
    }
}


