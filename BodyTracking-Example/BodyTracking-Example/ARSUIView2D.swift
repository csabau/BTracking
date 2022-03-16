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




class ARSUIView2D: BodyARView {
    

    private var bodyTracker: BodyTracker2D!
    
    ///Use this to display the angle formed at this joint.
    ///See the call to "angleBetween3Joints" below.
    private var angleLabel: UILabel!
    
    private var startJoint1 = CGPoint(x: 0, y: 0)
    private var endJoint1 = CGPoint(x: 40, y: 300)
    private var startJoint2 = CGPoint(x: 500, y: 600)
    private var endJoint2 = CGPoint(x: 200, y: 660)
    
    

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
        
        makeOtherJointsVisible()
        
//        //print("all cases should be \(TwoDBodyJoint.allCases)")
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
       // rightElbowCircle.addSubview(newLine)
        
        //new
        //let firstLine = Line().stroke(.blue, lineWidth: 5)
       // rightElbowCircle.addSubview(firstLine as! UIView)
    }
    
    
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
        
        
        
        let bone1 = DrawLine(frame: CGRect(x: 0, y: 0, width: self.windowWidth, height: self.windowHeight), start: startJoint1, end: endJoint1)
        self.bodyTracker.attachLine(thisNewView: bone1)
        let bone2 = DrawLine(frame: CGRect(x: 0, y: 0, width: self.windowWidth, height: self.windowHeight), start: startJoint2, end: endJoint2)
        self.bodyTracker.attachLine(thisNewView: bone2)
        //self.bodyTracker.attach(thisView: bone, toThisJoint: .right_hand_joint)
        
        //Another way to attach views to the skeletion, but iteratively this time:
        //CHANGE THE WAY THE CIRCLES LOOK
        jointsToShow.forEach { joint in
            ////let circle = makeCircle(circleRadius: 40)
            //let line = makeLine()
            ////self.bodyTracker.attach(thisView: circle, toThisJoint: joint)
            //self.bodyTracker.attachLine(thisNewView: line)
            
            //let bone = DrawLine(frame: CGRect(x: 150, y: 300, width: 40.0, height: 40.0))
            //self.bodyTracker.attachLine(thisNewView: rectangle)
            //self.bodyTracker.attach(thisView: bone, toThisJoint: joint)
            
            
            //new code
           // print("\(joint) \n")
            
            
            
            
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
    

        
//-------------------------------------------------------------------------------------------------
    
    class DrawLine: UIView {
        
        var path: UIBezierPath!
        var strokeColour: CGColor = #colorLiteral(red: 0.670588235294118, green: 0.898039215686275, blue: 0.12156862745098, alpha: 1)
        var fillColour: CGColor = #colorLiteral(red: 0.250980392156863, green: 0.250980392156863, blue: 0.250980392156863, alpha: 0.0)
        var startPoint: CGPoint?
        var endPoint: CGPoint?
        
        
        
//        init(startPoint: CGPoint, endPoint: CGPoint, frame: CGRect) {
//            self.startPoint = startPoint
//            self.endPoint = endPoint
//        }
        
      init(frame: CGRect, start: CGPoint, end: CGPoint){
          
          self.startPoint = start
          self.endPoint = end
          super.init(frame: frame)
          
            
            //self.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255, alpha: 0)
            
            //calling the CAShapeLayer Object
            simpleShapeLayer()
        }
        
        required init?(coder aDecoder: NSCoder) {
            
            
           super.init(coder: aDecoder)
        }
        
        func createLine(start: CGPoint, end: CGPoint) {
            path = UIBezierPath()
            
            path.move(to: start)
            path.addLine(to: end)  //self.frame.size.height
//            path.addLine(to: CGPoint(x:self.frame.size.width, y:frame.size.height))
//            path.addLine(to: CGPoint(x:self.frame.size.width, y:0.0))
//            path.close()
        }
            
        
//        override func draw(_ rect: CGRect) {
//            self.createLine()
//            //UIColor.orange.setFill()
//            //path.fill()
//
//            //UIColor.purple.setStroke()
//            UIColor.init(cgColor: strokeColour).setStroke()
//
//            path.stroke()
//            path.lineWidth = 3.0
//        }
        
        //create the CAShapeLayer Object because it's more versatile and can define stroke width. We assign the path of the BezierPath from above
        func simpleShapeLayer() {
            self.createLine(start: startPoint!, end: endPoint!)
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = self.path.cgPath
            
            shapeLayer.fillColor = fillColour
            shapeLayer.strokeColor = strokeColour
            shapeLayer.lineWidth = 4.0
            
            self.layer.addSublayer(shapeLayer)
            
            
        }
        
        
    }
    
    //-------------------------------------------------------------------------------------------------
    //-------------------------------------------------------------------------------------------------
    
    
    
    
    
    
    
    
    
    
    
    
    //---------------------------------------------------
    
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























   
//    private func createJointsPaths(){
//
//        let firstLine = Line().stroke(.blue, lineWidth: 5)
//        // ** HERE is the useful code: **
//        //How to attach views to the skeleton:
//        self.bodyTracker.attach(thisView: firstLine as! UIView, toThisJoint: .left_forearm_joint)
//
//        //Use this to display the angle formed at this joint.
//        //See the call to "angleBetween3Joints" below.
//        angleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 50)))
//        rightElbowCircle.addSubview(angleLabel)
//    }
//
