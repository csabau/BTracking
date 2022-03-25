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
///import BodyTracking
import AVFoundation




class ARSUIViewSquat: BodyARView {
    

    private var bodyTracker: BodyTracker2D!
    
    ///Use this to display the angle formed at this joint.
    ///See the call to "angleBetween3Joints" below.
    //private var rightLegAngleLabel: UILabel!
    //private var rightKneeAngleLabel: UILabel!
    private var headAngleLabel: UILabel!
    private var forceLineLabel: UILabel!
    private var shoulderForceLabel: UILabel!
    private var torsoLengthLabelNeckToHip: UILabel!
    private var torsoLengthLabelShoulderToHip: UILabel!
    private var torsoAngleLabelShoulderToHip: UILabel!
    
    
    private var shoulderLabel: UILabel!
    private var hipLabel: UILabel!
    private var spine_1Label: UILabel!
    private var spineAngleLabel: UILabel!
    
    //creating labels for reading the distances to the egdes
    private var topConsoleLabel: UILabel!
    private var bottomConsoleLabel: UILabel!
    private var leftConsoleLabel: UILabel!
    private var middleConsoleLabel: UILabel!
    
    
   // private var forcePath: UIView!
    
    //defining bones of the skeleton

    let squatBonesToShow : [String : [TwoDBodyJoint]] = [

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
        ]
        

    ]
    
    
    //defining variables for angles
    //angle for head tilt
    private var headTiltAngle: Float = 0.0
    
    //storing the angle of the sheer force to be used in checkForm
    private var sheerForceAngle: Float = 0.0
    
    //storing the distances between body and screen edges / middle (from the Delegate) to be used in bodySetup()
    private var distTop: Float = 0.0
    private var distBottom: Float = 0.0
    private var distMiddle: Float = 0.0
    
    
    
    private var headInView: Bool = false
    private var middleCheck: Bool = false
    private var bodyInMiddle: Bool = false
    private var readyToSquat: Bool = false
    
    
    
    //spine joints
    var spine_1_joint: CGPoint = CGPoint(x:0, y:0)

    
  
    
    
    //variables for error tracking in Neck angles
    
    private var neckAngleErrorDetected: Bool = false
   // private var hipAngleErrorDetected: Bool = false
   // private var kneeAngleErrorDetected: Bool = false
    private var frameCount: Int = 0
    
    

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
        
//        //run calibrating function of scanBody() before checkForm() can be performed
//        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
//            AudioServicesPlaySystemSound(1025)
//            self.bodySetup()
//        }
        
        makeJointAngleVisible()
        

        
       // makeOtherJointsVisible()
        
//       DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
//           AudioServicesPlaySystemSound(1025)
//           self.errorMarginCalibrated = true
//       }
        

    }
    
    
    //Scanning the body to determine limb RATIOS (to calibrate the angle error based on the body type)
    private func bodySetup(){
        
//        //set up camera tilt based on foot level?
//        if distBottom > 60 {
//            headInView = true
//            AudioServicesPlaySystemSound(1111) //your body is in frame
//        }
        
        if !readyToSquat {
            //Check if head is in screen enough
            if !headInView {       //walk to your left, away from the device so that your body gets in the frame
                if distTop > 100 {
                    headInView = true
                    AudioServicesPlaySystemSound(1111) //your body is in frame
                }
            } else if !bodyInMiddle {    //the headInView is now True, so we check that the body is in the middle
                
                if !middleCheck { //body is too far from the middle
                    AudioServicesPlaySystemSound(1024) //slowly step forwards or backwards to get in line with your device
                    middleCheck = true
                }
                
                if distMiddle < 30 {
                    AudioServicesPlaySystemSound(1111) //your body is now in the middle
                    bodyInMiddle = true
                    
                    readyToSquat = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                       AudioServicesPlaySystemSound(1025) // you are now ready to squat
                   }
                    
                }
            }
        }
        
        
        
        


        
        
        
       
        
        
        
/*
        //Check if foot is in screen enough
        if self.distBottom < 60 {
            self.footInView = false
            AudioServicesPlaySystemSound(1112)
        } else {
            self.footInView = true
        }
        
        //Check if body is middle aligned to the camera
        if self.distMiddle < 30 {
            self.bodyInMiddle = false
            AudioServicesPlaySystemSound(1005)
        } else {
            self.bodyInMiddle = true
        }
 */


//        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
//            AudioServicesPlaySystemSound(1025)
//            self.errorMarginCalibrated = true
            
//        }
        
    }
    
    private func checkForm(){
        
        
        //print("\n\n neck angle: \(neckAngle)\n\n")
        
        //This makes a BUZZ sound when the neck is not straight
//        if /*neckAngle > 179.00 || neckAngle < 175.00*/ neckAngle < 110.00 || neckAngle > 140.00 {
//            //timer()
//            //AudioServicesPlaySystemSound(1111)
//        }
//
        
        //Check NECK form
        //Add a timer that counts the frames so that if an error sound is played, it doesn't get played for another 120 frames
        if self.frameCount < 120 {
            self.frameCount += 1
            
            //Checking Neck angles
            if(!self.neckAngleErrorDetected) {
                if headTiltAngle > 155.00 {
                    AudioServicesPlaySystemSound(1111)
                } else if headTiltAngle < 130.00 {
                    AudioServicesPlaySystemSound(1112)
                }
                self.neckAngleErrorDetected = true
            }
            self.neckAngleErrorDetected = true
            
            

            
//            //Checking Hip and Knee angles
//            if(!self.hipAngleErrorDetected) {
//                //If the absolute value of the difference between the angles is outside the margin of error determined by the limbs ratio
//                if sheerForceAngle > 4 && sheerForceAngle < 90  {
//                    AudioServicesPlaySystemSound(1024)
//                }
//
//                if sheerForceAngle < 357 && sheerForceAngle > 270  {
//                    AudioServicesPlaySystemSound(1021)
//                }
//
//
//                self.hipAngleErrorDetected = true
//            }

            self.frameCount += 1
            
        } else {
            self.frameCount = 0
            self.neckAngleErrorDetected = false
        }
        
        
        

        
        
        
        
        
        
    }
    
    
   
    
    
    ///This is an example for how to show one joint.
    private func makeJointAngleVisible(){
        
//        //Torso Length
//        torsoLengthLabelNeckToHip = UILabel(frame: CGRect(origin: CGPoint(x: 10, y: 400), size: CGSize(width: 100, height: 50))) //neck to hip
//        self.bodyTracker.attachLine(thisNewView: torsoLengthLabelNeckToHip, ofThisBone: "torso")
//        torsoLengthLabelShoulderToHip = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 15), size: CGSize(width: 100, height: 50))) // shoulder to hip
//        torsoLengthLabelNeckToHip.addSubview(torsoLengthLabelShoulderToHip)
//        torsoAngleLabelShoulderToHip = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 40), size: CGSize(width: 100, height: 50))) // angle shoulder to hip
//        torsoLengthLabelNeckToHip.addSubview(torsoAngleLabelShoulderToHip)
//        // spine 1 joint coordinates
//        hipLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 70), size: CGSize(width: 700, height: 50)))
//        shoulderLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 85), size: CGSize(width: 700, height: 50)))
//
//        spine_1Label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 110), size: CGSize(width: 700, height: 50)))
//        spineAngleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 140), size: CGSize(width: 700, height: 50)))
//        torsoLengthLabelNeckToHip.addSubview(shoulderLabel)
//        torsoLengthLabelNeckToHip.addSubview(hipLabel)
//        torsoLengthLabelNeckToHip.addSubview(spine_1Label)
//        torsoLengthLabelNeckToHip.addSubview(spineAngleLabel)
 
 
        
        //Shoulder joint
        //Neck / head
        let shoulderCircle = makeCircle(circleRadius: 20)
        self.bodyTracker.attach(thisView: shoulderCircle, toThisJoint: .right_shoulder_1_joint)
        
        headAngleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 50)))
        shoulderCircle.addSubview(headAngleLabel)
        
        //attach the Sheer Force Angle to the shoulder joint so that it is displayed on the grey Sheer Force Path
        forceLineLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: -35), size: CGSize(width: 100, height: 50)))
        forceLineLabel.textColor = #colorLiteral(red: 0.670588235294118, green: 0.898039215686275, blue: 0.12156862745098, alpha: 1)
        shoulderCircle.addSubview(forceLineLabel)
        
//        //attach the Sheer Force Angle to the shoulder joint so that it is displayed on the grey Sheer Force Path
//        forceLineLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 50)))
//        forceLineLabel.textColor = UIColor.red
        
        
//        //Neck / head
//        let neckCircle = makeCircle(circleRadius: 20)
//        self.bodyTracker.attach(thisView: neckCircle, toThisJoint: .neck_1_joint)
//
//        neckAngleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 50)))
//        neckCircle.addSubview(neckAngleLabel)
        
        //Right Leg
        let rightLegCircle = makeCircle(circleRadius: 20)
        self.bodyTracker.attach(thisView: rightLegCircle, toThisJoint: .right_upLeg_joint)
        
//        rightLegAngleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 50)))
//        rightLegCircle.addSubview(rightLegAngleLabel)
        
        //Right Knee
        let rightKneeCircle = makeCircle(circleRadius: 20)
        self.bodyTracker.attach(thisView: rightKneeCircle, toThisJoint: .right_leg_joint)
        
//        rightKneeAngleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 50)))
//        rightKneeCircle.addSubview(rightKneeAngleLabel)
        
        
        //Righ Foot
        let footCircle = makeCircle(circleRadius: 20)
        self.bodyTracker.attach(thisView: footCircle, toThisJoint: .right_foot_joint)
        
       
        
        
        //Sheer Force angle (shoulder perpendicular to the ground)
        let forceCircle = makeCircle(circleRadius: 20)
        self.bodyTracker.attach(thisView: forceCircle, toThisJoint: .head_joint)
        
       
        
        
        
        //Console UILabel for distances between edges
        topConsoleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 50, y: 120), size: CGSize(width: 100, height: 50)))
        self.bodyTracker.attachLine(thisNewView: topConsoleLabel, ofThisBone: "console")
        bottomConsoleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 15), size: CGSize(width: 100, height: 50)))
        topConsoleLabel.addSubview(bottomConsoleLabel)
        middleConsoleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 30), size: CGSize(width: 100, height: 50)))
        topConsoleLabel.addSubview(middleConsoleLabel)
//        leftConsoleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 30), size: CGSize(width: 100, height: 50)))
//        topConsoleLabel.addSubview(leftConsoleLabel)
        
//        shoulderForceLabel = UILabel(frame: CGRect(origin: CGPoint(x: -200, y: -100), size: CGSize(width: 100, height: 50)))
//        forceCircle.addSubview(shoulderForceLabel)
        
    }
    

//    ///This is an example for how to show multiple joints, iteratively.
//    private func makeOtherJointsVisible(){
//        //There are more joints you could attach views to, I'm just using these.
//        let jointsToShow : [TwoDBodyJoint] = [/*.head_joint,*/ .right_foot_joint]
//
//
//        //Another way to attach views to the skeletion, but iteratively this time:
//        //CHANGE THE WAY THE CIRCLES LOOK
//        jointsToShow.forEach { joint in
//            let circle = makeCircle(circleRadius: 40)
//            self.bodyTracker.attach(thisView: circle, toThisJoint: joint)
//
//        }
//
//    }
 
    

    
    override func stopSession(){
        super.stopSession()
        self.bodyTracker.destroy()
        self.bodyTracker = nil
        self.headAngleLabel.removeFromSuperview()
        //self.rightLegAngleLabel.removeFromSuperview()
        //self.rightKneeAngleLabel.removeFromSuperview()
  
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





extension ARSUIViewSquat: ARSessionDelegate {
    
    //For RealityKit 2 we should use a RealityKit System instead of this update function but that would be limited to devices running iOS 15.0+
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        //Add labels for neck, hip and knee joint angles

        //Neck / head
        if let headJointAngle = self.bodyTracker.angleBetween3Joints(.root,
                                                                     .neck_1_joint,
                                                                     .head_joint) {
            self.headAngleLabel.text = String(format: "%.0f", Float(headJointAngle))
            headTiltAngle = Float(headJointAngle)
        }
        
      
        
//        //torso distance to test back overextension
//        let neckToHipLegth = self.bodyTracker.distanceBetween2Joints(.neck_1_joint, .right_upLeg_joint)
//        self.torsoLengthLabelNeckToHip.text = String(format: "%.0f", Float(neckToHipLegth))
//
//        let shoulderToHipLegth = self.bodyTracker.distanceBetween2Joints(.right_shoulder_1_joint, .right_upLeg_joint)
//        self.torsoLengthLabelShoulderToHip.text = String(format: "%.0f", Float(shoulderToHipLegth))
//
//        let hipToShoulderAngle = self.bodyTracker.angleFrom2Joints(.right_upLeg_joint, .right_shoulder_1_joint)
//        self.torsoAngleLabelShoulderToHip.text = String(format: "%.0f", Float(hipToShoulderAngle!))
        
        
        //calculating the Sheer force angle
        var forceLineAngle = self.bodyTracker.angleFromShoulderToGround()!
        if forceLineAngle > 90 {
            forceLineAngle -= 360
        }
        self.forceLineLabel.text = String(format: "%.0f", Float(forceLineAngle))
        
        //storing the sheer force angle value in a variable that can be used
        sheerForceAngle = Float(forceLineAngle)
        
        
        
        //drawing Sheer force PATH
        self.bodyTracker.removeBone("forcePath")
        let forcePath = self.bodyTracker.sheerForcePath()
        self.bodyTracker.attachLine(thisNewView: forcePath, ofThisBone: "forcePath")
       //forcePath.addSubview(forceLineLabel)
        

        
        //draw BONES = line between 2 joints with the modified function fo angle between two joints
        
        squatBonesToShow.forEach{ bone in
            self.bodyTracker.removeBone(bone.key)
            let jointLine = self.bodyTracker.lineBetween2Joints(bone.value[0], bone.value[1])
            self.bodyTracker.attachLine(thisNewView: jointLine, ofThisBone: bone.key)
        
        }
        
        
        
        
        //drawing Sheer force Angle line
        self.bodyTracker.removeBone("sheerForce")
        let sheerForceLine = self.bodyTracker.sheerForceAngleLine()
        self.bodyTracker.attachLine(thisNewView: sheerForceLine, ofThisBone: "sheerForce")
        
        
//        //--------------------------------------------------------------------------------------
//        //read the spine 1 joint
//        self.spine_1_joint = self.bodyTracker.spine_joint(.right_upLeg_joint, .right_shoulder_1_joint, dist: 2, segment: 600)
//        self.spine_1Label.text = NSCoder.string(for: spine_1_joint)
//        
//       
//        let spineAngle = self.bodyTracker.angleBetween3Joints(.root,
//                                                              .neck_1_joint,
//                                                              .right_upLeg_joint)
//        self.spineAngleLabel.text = String(format: "%.0f", Float(spineAngle ?? 0))
//        
//        //read TwoDBodyJoint coords
//        self.shoulderLabel.text = NSCoder.string(for: self.bodyTracker.joint_coord(coordForJoint: .right_shoulder_1_joint))
//        self.hipLabel.text = NSCoder.string(for: self.bodyTracker.joint_coord(coordForJoint: .right_upLeg_joint))
//        
//        
//        
//        
//        
//        //drawing spine 1 line
//        self.bodyTracker.removeBone("spine1")
//        let spine1Line = self.bodyTracker.spine_1_Line(.right_upLeg_joint, self.spine_1_joint)
//        self.bodyTracker.attachLine(thisNewView: spine1Line, ofThisBone: "spine1")
        
        
        
        
        
        
        //add uilabel for console reads - distances between stuff
        //Calculate and display the space between the body and
        //the TOP
        let topSpace = self.bodyTracker.distanceBetweenJointAndScreenEdge(.head_joint, "top")
        self.topConsoleLabel.text = String(format: "%.0f", Float(topSpace))
        distTop = Float(topSpace)
        
        //the BOTTOM
        let bottomSpace = self.bodyTracker.distanceBetweenJointAndScreenEdge(.right_foot_joint, "bottom")
        self.bottomConsoleLabel.text = String(format: "%.0f", Float(bottomSpace))
        distBottom = Float(bottomSpace)
        
        //the MIDDLE
        let middleSpace = self.bodyTracker.distanceBetweenJointAndScreenEdge(.right_foot_joint, "middle")
        self.middleConsoleLabel.text = String(format: "%.0f", Float(middleSpace))
        distMiddle = Float(middleSpace)
 
        
        //run calibrating function from init, and then check form once that's happened
//        if self.errorMarginCalibrated == true {
//            checkForm()
//        }
        
       // timer()
        //print("timer: \(self.frameCount)")
        bodySetup()
       
    }
}





















///Calibration for body ratios from scanBody function
/*
// Read the body to determine limb RATIOS (to calibrate the angle error based on the body type
let upperLegLegth = self.bodyTracker.distanceBetween2Joints(.right_leg_joint, .right_upLeg_joint)


let lowerLegLegth = self.bodyTracker.distanceBetween2Joints(.right_foot_joint, .right_leg_joint)


let torsoLegth = self.bodyTracker.distanceBetween2Joints(.root, .neck_1_joint)


//Calculating the ratio between the limbs
let totalLength = upperLegLegth + lowerLegLegth + torsoLegth

let upLegRatio = (upperLegLegth * 100) / totalLength
let downLegRatio = (lowerLegLegth * 100) / totalLength
let torsoRatio = (torsoLegth * 100) / totalLength

print("Up leg legth: \(upperLegLegth) and ratio : \(upLegRatio)")
print("Down leg legth: \(lowerLegLegth) and ratio : \(downLegRatio)")
print("Torso legth: \(torsoLegth) and ratio : \(torsoRatio)")


//Ratios for EVEN proportions
if upLegRatio > 25 && upLegRatio < 40 && downLegRatio > 20 && downLegRatio < 35 && torsoRatio > 30 && torsoRatio < 45 {
//            print("\n--------------------------------------------------\n")
//            print("\n\nupLegRatio : \(upLegRatio)\n")
//            print("downLegRatio : \(downLegRatio)\n")
//            print("torsoRatio : \(torsoRatio)\n\n")
//            print("Set the Hip and Knee angles to be equal")
    
    //set the angle margin of error
    self.hipToKneeAngleMarginOfError = 10
}
//        else {
//            print("\n--------------------------------------------------\n")
//            print("\n\n Something went wrong\n\n")
//            print("\n\nupLegRatio : \(upLegRatio)\n")
//            print("downLegRatio : \(downLegRatio)\n")
//            print("torsoRatio : \(torsoRatio)\n\n")
//        }

*/








        ///Getting the angles at the KNEE and HIP every frame
/*
        //Right Leg / Hip
        if let rightLegJointAngle = self.bodyTracker.angleBetween3Joints(.right_leg_joint,
                                                                         .root,
                                                                         .neck_1_joint) {
            self.rightLegAngleLabel.text = String(format: "%.0f", Float(rightLegJointAngle))
            hipAngle = Float(rightLegJointAngle)
        }
        
        //Right Knee
        if let rightKneeJointAngle = self.bodyTracker.angleBetween3Joints(.right_foot_joint,
                                                                              .right_leg_joint,
                                                                              .right_upLeg_joint) {
            self.rightKneeAngleLabel.text = String(format: "%.0f", Float(rightKneeJointAngle))
            kneeAngle = Float(rightKneeJointAngle)
        }
        
    */








///Distance between neck and hip
/*
//        let torsoLegth = self.bodyTracker.distanceBetween2Joints(.neck_1_joint, .right_upLeg_joint)
//        self.torsoLengthLabel.text = String(format: "%.0f", Float(torsoLegth))
        
       
        
//        let shoulderForceAngle = self.bodyTracker.angleBetweenForceNeckHip()!
//        self.shoulderForceLabel.text = String(format: "%.0f", Float(shoulderForceAngle))
//
//        //trying to check neck form once
//        if (!self.neckIsInFrame)
//        {
//            if(self.neckWasPreviouslyInFrame)
//           {
//                checkForm()
//                self.neckWasPreviouslyInFrame = false;
//           }
//        }
//        else
//        {
//            if(!self.neckWasPreviouslyInFrame)
//           {
//                checkForm()
//                self.neckWasPreviouslyInFrame = true;
//           }
//        }
 */
