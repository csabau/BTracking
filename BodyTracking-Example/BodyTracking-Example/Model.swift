//
//  Model.swift
//  Drawing Test
//
//  Created by Grant Jarvis on 1/30/21.
//

import Combine
import RealityKit
import SwiftUI


public enum ARChoice: Int {
//    case handTracking
//    case face
    case twoD
//    case threeD
//    case bodyTrackedEntity
//    case peopleOcclusion
}



final class DataModel: ObservableObject {
    static var shared = DataModel()
    
    ///This is the ARView corresponding to the visualization that was selected.
    @Published var arView : ARView!
    
    @Published var selection: Int? {
        willSet {
            if let nv = newValue {
                print("selected:", nv)
                self.arChoice = ARChoice(rawValue: nv)!
            }
        }
    }

    
    var arChoice : ARChoice = .twoD {
        didSet {
            print("arChoice is:", arChoice.rawValue)
            switch arChoice {
//
            case .twoD:
                self.arView = ARSUIView2D(frame: .zero)
//            
            }
        }
    }
    
}
