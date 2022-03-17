//
//  ARView.swift
//  Body Tracking
//
//  Created by Grant Jarvis on 3/25/21.
//
import SwiftUI
import UIKit
import ARKit
import RealityKit
import BodyTracking




class ARSUIViewSquat: BodyARView {
    

    private var bodyTracker: BodyTracker2D!
    
    ///Use this to display the angle formed at this joint.
    ///See the call to "angleBetween3Joints" below.
    private var rightElbowAngleLabel: UILabel!
    private var rightShoulderAngleLabel: UILabel!
    private var rightLegAngleLabel: UILabel!
    private var rightKneeAngleLabel: UILabel!
    
    
    

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
        
        makeJointAngleVisible()
        
       // makeOtherJointsVisible()

    }
    
    
    ///This is an example for how to show one joint.
    private func makeJointAngleVisible(){
        let rightElbowCircle = makeCircle(circleRadius: 20)
        // ** HERE is the useful code: **
        //How to attach views to the skeleton:
        self.bodyTracker.attach(thisView: rightElbowCircle, toThisJoint: .right_forearm_joint)
        
        //Use this to display the angle formed at this joint.
        //See the call to "angleBetween3Joints" below.
        rightElbowAngleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 50)))
        rightElbowCircle.addSubview(rightElbowAngleLabel)
        
        //Right Shoudler
        let rightShoulderCircle = makeCircle(circleRadius: 20)
        self.bodyTracker.attach(thisView: rightShoulderCircle, toThisJoint: .right_shoulder_1_joint)
        
        rightShoulderAngleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 50)))
        rightShoulderCircle.addSubview(rightShoulderAngleLabel)
        
        
        //Right Leg
        let rightLegCircle = makeCircle(circleRadius: 20)
        self.bodyTracker.attach(thisView: rightLegCircle, toThisJoint: .right_upLeg_joint)
        
        rightLegAngleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 50)))
        rightLegCircle.addSubview(rightLegAngleLabel)
        
        //Right Knee
        let rightKneeCircle = makeCircle(circleRadius: 20)
        self.bodyTracker.attach(thisView: rightKneeCircle, toThisJoint: .right_leg_joint)
        
        rightKneeAngleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 50)))
        rightKneeCircle.addSubview(rightKneeAngleLabel)
    }
    
/*
    ///This is an example for how to show multiple joints, iteratively.
    private func makeOtherJointsVisible(){
        //There are more joints you could attach views to, I'm just using these.
        let jointsToShow : [TwoDBodyJoint] = [.right_hand_joint, .right_shoulder_1_joint,
                                           .left_forearm_joint, .left_hand_joint,
                                           .left_shoulder_1_joint,
                                           .head_joint, .neck_1_joint,
                                              .root, .right_upLeg_joint, .right_leg_joint,
                                              .right_foot_joint, .left_upLeg_joint, .left_leg_joint,
                                           .left_foot_joint]
  
        
        //Another way to attach views to the skeletion, but iteratively this time:
        //CHANGE THE WAY THE CIRCLES LOOK
        jointsToShow.forEach { joint in
            let circle = makeCircle(circleRadius: 40)
            self.bodyTracker.attach(thisView: circle, toThisJoint: joint)
           
        }
        
    }
 */
    

    
    override func stopSession(){
        super.stopSession()
           self.bodyTracker.destroy()
            self.bodyTracker = nil
           self.rightElbowAngleLabel.removeFromSuperview()
        self.rightShoulderAngleLabel.removeFromSuperview()
        self.rightLegAngleLabel.removeFromSuperview()
        self.rightKneeAngleLabel.removeFromSuperview()
  
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



//defining bones of the skeleton

let squatBonesToShow : [String : [TwoDBodyJoint]] = [
    "rightForearm" : [
         .right_hand_joint , .right_forearm_joint
    ],
    "rightArm" : [
        .right_forearm_joint , .right_shoulder_1_joint
    ],
    "rightShoulder" : [
        .right_shoulder_1_joint , .neck_1_joint
    ],
    "rightFoot" : [
        .right_foot_joint , .right_leg_joint
    ],
    "rightLeg" : [
        .right_leg_joint , .right_upLeg_joint
    ],
    "rightHip" : [
        .right_upLeg_joint , .root
    ],
    "spine" : [
        .root , .neck_1_joint
    ],
    "head" : [
        .neck_1_joint , .head_joint
    ]

]


   


extension ARSUIViewSquat: ARSessionDelegate {
    
    //For RealityKit 2 we should use a RealityKit System instead of this update function but that would be limited to devices running iOS 15.0+
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        //-------------------------------- RIGHT ----------------------------
        //Right Elbow
        //The formatting rounds the number.
        if let rightElbowJointAngle = self.bodyTracker.angleBetween3Joints(.right_hand_joint,
                                                                           .right_forearm_joint,
                                                                           .right_shoulder_1_joint) {
            self.rightElbowAngleLabel.text = String(format: "%.0f", Float(rightElbowJointAngle))
        }
        
        //Right Shoulder
        if let rightShoulderJointAngle = self.bodyTracker.angleBetween3Joints(.right_forearm_joint,
                                                                              .right_shoulder_1_joint,
                                                                              .neck_1_joint) {
            self.rightShoulderAngleLabel.text = String(format: "%.0f", Float(rightShoulderJointAngle))
        }
        
        //Right Leg
        if let rightLegJointAngle = self.bodyTracker.angleBetween3Joints(.right_leg_joint,
                                                                              .right_upLeg_joint,
                                                                              .root) {
            self.rightLegAngleLabel.text = String(format: "%.0f", Float(rightLegJointAngle))
        }
        
        //Right Knee
        if let rightKneeJointAngle = self.bodyTracker.angleBetween3Joints(.right_foot_joint,
                                                                              .right_leg_joint,
                                                                              .right_upLeg_joint) {
            self.rightKneeAngleLabel.text = String(format: "%.0f", Float(rightKneeJointAngle))
        }
        
        //draw line between 2 joints with the modified function fo angle between two joints
        
        squatBonesToShow.forEach{ bone in
            self.bodyTracker.removeBone(bone.key)
            let jointLine = self.bodyTracker.lineBetween2Joints(bone.value[0], bone.value[1])
            self.bodyTracker.attachLine(thisNewView: jointLine, ofThisBone: bone.key)
        
        }
        
       
    }
}
