//
//  BrowseView.swift
//  BodyTracking-Example
//
//  Created by Caius Sabau on 23/03/2022.
//



import SwiftUI
import UIKit
import CoreMotion


private var bodyTracker: BodyTracker2D!

struct DeviceSetupView: View {
    @Binding var showDeviceSetup: Bool

    var body: some View {

        NavigationView {
//            ScrollView(showsIndicators: false) {
                
                BubbleLevelWrapper()
//                //Gridviews with thumbnails
//                RecentsGrid(showBrowse: $showBrowse)
//
//                ModelsByCategory(showBrowse: $showBrowse)
                //ViewController()

//                Text ("title")
//                                .font(.title2).bold()
//                                .padding(.leading, 22)
//                                .padding(.top, 10)
//
//            }
            .navigationBarTitle(Text("Device Setup"), displayMode: .large)
            .navigationBarItems(trailing:
                Button(action: {
                    self.showDeviceSetup.toggle()
            }) {
                Text("Done").bold()
            })
        }
    }
} // END of the VIEW




//-----wrapping UIViewController inside UIVIewRepresentable to use it in the View of the sheet

struct BubbleLevelWrapper: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = BubbleLevel
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<BubbleLevelWrapper>) -> BubbleLevelWrapper.UIViewControllerType {
        return BubbleLevel()
    }
    
    func updateUIViewController(_ uiViewController: BubbleLevelWrapper.UIViewControllerType, context: UIViewControllerRepresentableContext<BubbleLevelWrapper>) {
        
        
    }
    
}

//-------------------------------------------------------------------------------------



//code for horizontal and tilt leveling

class BubbleLevel: UIViewController {
    lazy var bubble1View: UIView = {
        let bubbleWidth = view.bounds.width - 300
        let bubbleView = UIView(frame: CGRect(x: view.frame.midX - bubbleWidth / 2 + 300,
                                              y: view.frame.midY - bubbleWidth / 2 + 200,
                                              width: bubbleWidth,
                                              height: bubbleWidth))
        bubbleView.layer.cornerRadius = bubbleWidth / 2
        bubbleView.backgroundColor = .red
        self.view.addSubview(bubbleView)
        return bubbleView
    }()
    
    lazy var bubble2View: UIView = {
        let bubbleWidth = view.bounds.width - 300
        let bubbleView = UIView(frame: CGRect(x: view.frame.midX - bubbleWidth / 2,
                                              y: view.frame.midY - bubbleWidth / 2 + 200,
                                              width: bubbleWidth,
                                              height: bubbleWidth))
        bubbleView.layer.cornerRadius = bubbleWidth / 2
        bubbleView.backgroundColor = .red
        self.view.addSubview(bubbleView)
        return bubbleView
    }()

    private var motionManager: CMMotionManager!
    private var bubble1Center: CGPoint!
    private var newBubble1Center: CGPoint!
    
    private var newBubble1CenterExtra: CGPoint = CGPoint(x:0, y:0)
    private var newBubble2CenterExtra: CGPoint = CGPoint(x:0, y:0)
    
    private var bubble2Center: CGPoint!
    private var newBubble2Center: CGPoint!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        motionManager.gyroUpdateInterval = 0.01
        if let currentOperationQueue = OperationQueue.current {
            motionManager.startGyroUpdates(to: currentOperationQueue) { data, _ in
                if let data = data
                {
                   // print(data)

                    self.newBubble1Center.y = (CGFloat(data.rotationRate.x)  * 10)
                    
                    self.newBubble2Center.x = (CGFloat(data.rotationRate.z)  * 5)
                   // self.newBubbleCenter.y = (CGFloat(data.rotationRate.y)  * -10)

                    if abs(self.newBubble1Center.y) /* + abs(self.newBubbleCenter.y) */ < 0.04 {
                        self.newBubble1Center = .zero
                    }
                    
                    if abs(self.newBubble2Center.x) /* + abs(self.newBubbleCenter.y) */ < 0.04 {
                        self.newBubble2Center = .zero
                    }
                    
                    
                    if self.newBubble1CenterExtra.y <= 0.0 && self.bubble1Center.y <= 37.5 {
                        self.newBubble1CenterExtra.y -= self.newBubble1Center.y
                        //self.bubble1Center.y = (self.bubble1Center.y  + self.newBubble1Center.y) - self.newBubble1CenterExtra.y
                    } else {
                        if self.newBubble1CenterExtra.y <= 0.0 && self.bubble1Center.y >= 774.5 {
                            self.newBubble1CenterExtra.y += self.newBubble1Center.y
                            } else {
                                if self.bubble1Center.y < 200 {
                                    self.bubble1Center.y = (self.bubble1Center.y  - self.newBubble1Center.y) + self.newBubble1CenterExtra.y
                                    self.newBubble1CenterExtra.y = 0.0
                                } else {
                                    self.bubble1Center.y = (self.bubble1Center.y  - self.newBubble1Center.y) - self.newBubble1CenterExtra.y
                                    self.newBubble1CenterExtra.y = 0.0
                                }
                            }
                    }
                    
                    
                    if self.newBubble2CenterExtra.x <= 0.0 && self.bubble2Center.x <= 37.5 {
                        self.newBubble2CenterExtra.x += self.newBubble2Center.x
                    } else {
                        if self.newBubble2CenterExtra.x <= 0.0 && self.bubble2Center.x >= 337.5 {
                            self.newBubble2CenterExtra.x -= self.newBubble2Center.x
                            } else {
                                if self.bubble2Center.x < 40 {
                                    self.bubble2Center.x = (self.bubble2Center.x  + self.newBubble2Center.x) - self.newBubble2CenterExtra.x
                                    self.newBubble2CenterExtra.x = 0.0
                                } else {
                                    self.bubble2Center.x = (self.bubble2Center.x  + self.newBubble2Center.x) + self.newBubble2CenterExtra.x
                                    self.newBubble2CenterExtra.x = 0.0
                                }
                            }
                    }
                    

                    

                    self.bubble1Center.x = max(self.bubble1View.frame.size.width * 0.5, min(self.bubble1Center.x, self.view.bounds.width - self.bubble1View.frame.size.width * 0.5))
                    self.bubble1Center.y = max(self.bubble1View.frame.size.height * 0.5, min(self.bubble1Center.y, self.view.bounds.height - self.bubble1View.frame.size.height * 0.5))
                    
                    
                    
                    
                   
                    self.bubble2Center.x = max(self.bubble2View.frame.size.width * 0.5, min(self.bubble2Center.x, self.view.bounds.width - self.bubble2View.frame.size.width * 0.5))
                    self.bubble2Center.y = max(self.bubble2View.frame.size.height * 0.5, min(self.bubble2Center.y, self.view.bounds.height - self.bubble2View.frame.size.height * 0.5))
                    
                    

                    self.bubble1View.center = self.bubble1Center
                    
                    print("Bubble 1: \(self.bubble2Center.x)")
                    print("NewBubble 1: \(self.newBubble2Center.x)")
                    print("Extra: \(self.newBubble2CenterExtra.x)")
                    
                    if self.bubble1Center.y < 300 /*,
                       (self.bubbleCenter.y - self.view.center.y) <= 5 */{
                        self.bubble1View.backgroundColor = .green
                    } else {
                        self.bubble1View.backgroundColor = .red
                    }
                    
                    self.bubble2View.center = self.bubble2Center
                    if (self.bubble2Center.x - self.view.center.x) <= 5 /*,
                       (self.bubbleCenter.y - self.view.center.y) <= 5 */{
                        self.bubble2View.backgroundColor = .green
                    } else {
                        self.bubble2View.backgroundColor = .red
                    }

                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        motionManager = CMMotionManager()
        bubble1Center = bubble1View.center
        newBubble1Center = bubble1View.center
        
        bubble2Center = bubble2View.center
        newBubble2Center = bubble2View.center
        
        let mainCircleWidth = view.bounds.width - 190
        let mainCircleView = UIView(frame: CGRect(x: view.frame.midX - mainCircleWidth / 2,
                                              y: view.frame.midY - mainCircleWidth / 2,
                                              width: mainCircleWidth,
                                              height: mainCircleWidth))
        mainCircleView.backgroundColor = .clear
        mainCircleView.layer.cornerRadius = mainCircleWidth / 2
        mainCircleView.layer.borderWidth = 5
        mainCircleView.layer.borderColor = UIColor.white.cgColor
        mainCircleView.layer.zPosition = -1
        view.addSubview(mainCircleView)
    }
}



















////CREATING RECENTS GRID
//struct RecentsGrid: View {
//    @EnvironmentObject var placementSettings: PlacementSettings
//    @Binding var showBrowse: Bool
//    var body: some View {
//        if !self.placementSettings.recentlyPlaced.isEmpty {
//            HorizontalGrid(showBrowse: $showBrowse, title: "Recents", items: getRecentsUniqueOrdered())
//        }
//    }
//
//    func getRecentsUniqueOrdered() -> [Model] {
//        var recentsUniqueOrderedArray: [Model] = []
//        var modelNameSet: Set<String> = []
//
//        for model in self.placementSettings.recentlyPlaced.reversed(){
//
//            if !modelNameSet.contains(model.name) {
//                recentsUniqueOrderedArray.append(model)
//                modelNameSet.insert(model.name)
//            }
//        }
//
//        return recentsUniqueOrderedArray
//    }
//}
//
////Access the Models from the Model file. These are loaded and grouped / filtered
//struct ModelsByCategory: View {
//    @Binding var showBrowse: Bool
//    let models = Models()
//
//    var body: some View {
//        VStack {
//            ForEach(ModelCategory.allCases, id: \.self) { category in
//
//                //Only display grid if category contains items
//                if let modelsByCategory = models.get(category: category) {
//                    HorizontalGrid(showBrowse: $showBrowse, title: category.label, items: modelsByCategory)
//                }
//            }
//        }
//
//    }
//}
//
//
//struct HorizontalGrid: View {
//    @EnvironmentObject var placementSettings: PlacementSettings
//    @Binding var showBrowse: Bool
//    var title: String
//    var items: [Model]
//
//
//    private let gridItemLayout = [GridItem(.fixed(150))]
//
//    var body: some View {
//        VStack(alignment: .leading) {
//
//            Separator()
//
//            Text (title)
//                .font(.title2).bold()
//                .padding(.leading, 22)
//                .padding(.top, 10)
//
//            ScrollView(.horizontal, showsIndicators: false){
//                LazyHGrid(rows: gridItemLayout, spacing: 30){
//                    ForEach(0..<items.count) { index in
//                        let model = items[index]
//                        ItemButton(model: model) {
//
//                            //Tall model method to async load modelEnity DONE
//                            model.asyncLoadModelEntity() //we are now calling the new function created in the Model file
//
//                            //select model for placement DONE
//                            self.placementSettings.selectedModel = model
//                            print("BrowseView: selected \(model.name) for placement")
//                            self.showBrowse = false
//                        }
//                     }
//                }
//                .padding(.horizontal, 22)
//                .padding(.vertical, 10)
//            }
//        }
//    }
//}
//
//struct ItemButton: View {
//    let model: Model
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: {
//            self.action()
//        }) {
//            Image(uiImage: self.model.thumbnail)
//                .resizable()
//                .frame(height: 150)
//                .aspectRatio(1/1, contentMode: .fit)
//                .background(Color(UIColor.secondarySystemFill))
//                .cornerRadius(8.0)
//        }
//    }
//}


struct Separator: View {
    var body: some View {
        Divider ()
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
    }
}
