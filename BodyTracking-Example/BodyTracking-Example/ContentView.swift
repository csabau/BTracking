//
//  ContentView.swift
//  Body Tracking
//
//  Created by Grant Jarvis on 2/8/21.
//

import SwiftUI
import RealityKit
import ReplayKit

struct ContentView : View {
    @EnvironmentObject var data: DataModel
    
   // var backBtnIsVisible: Bool

    var body: some View {

//        ScrollView() {
//            ARButton(arChoice: .face, name: "Face Tracking")
//                .padding()
//            ARButton(arChoice: .handTracking, name: "Hand Tracking")
//                .padding()
        ARButton(arChoice: .twoD, name: "2D")
                .padding()
//            ARButton(arChoice: .squat, name: "Squat")
//                .padding()
//            ARButton(arChoice: .bodyTrackedEntity, name: "Character Animation")
//                .padding()
//            ARButton(arChoice: .peopleOcclusion, name: "People Occlusion")
//                .padding()
//        }
        
    }
    
}


struct ARButton: View {
    @EnvironmentObject var model : DataModel

    @State private var isHidden = true
    //code for the SHEET
    @State private var showDeviceSetup: Bool = false
    @State var isPresented = false

    
        var arChoice: ARChoice
        var name : String
        
        var body: some View {
        Button(action: {
            DataModel.shared.selection = arChoice.rawValue
            isPresented.toggle()
        }, label: {
            Text("Show \(name)")
                .frame(width: 200, height: 100, alignment: .center)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(20)
        })
        .fullScreenCover(isPresented: $isPresented) {
            ZStack {
            ARViewContainer.shared.edgesIgnoringSafeArea(.all).onDisappear(){
                print("on Dissapear")
                DataModel.shared.arView = nil
            }
            
           // VStack{
                HStack{
                    ///This is the retrun button provided by the package
                    Button(action: {
                     isPresented.toggle()
                    }, label: {
                     Image(systemName: "chevron.backward")
                         .resizable()
                         .scaledToFit()
                         .frame(width: 20, height: isHidden ? 20 : 0)
                         .padding()
                    })
                    //.position(x: 20, y: 10)
                    ///
                    Spacer()
                    ///
                    //Close UI btn - to be hidden when pressed itself, and showed when the Begin is pressed
                    Button(action: {
                    print("Close Record window: ")
                    self.isHidden = true
                    print("vaue is \(isHidden)")
                    recordUI(isHidden: isHidden)

                    } , label: {
                        Text(" ") //empty transparent button
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                        .buttonStyle(PlainButtonStyle())
                        .padding()
                        
                })
                        .frame(width: 70, height: !isHidden ? 70 : 0)
                        
                }
                .position(x: UIScreen.main.bounds.width / 2 , y: 10)//end of top HStack
                
                ///
//                Spacer()
                ///
                HStack{
                    Spacer()
                    //RECENTS btn
                    Button(action: {
//                        backBtnIsVisible.toggle()
                        //RecordBtn()
                        self.isHidden = false
                        print("vaue is \(isHidden)")
                        recordUI(isHidden: isHidden)
                    }) {
                        Text("Tap me to begin")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .frame(width: 200, height: isHidden ? 100 : 0)
                    }
                    ///
                    Spacer()
                    ///
                }
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)

                //end of HStack
                

                
            //}
            
            
            }
        }
    }
    

}



struct ARViewContainer: UIViewRepresentable {
    static var shared = ARViewContainer()
    func makeUIView(context: Context) -> ARView {
        return DataModel.shared.arView
    }
    func updateUIView(_ uiView: ARView, context: Context) {}
}





#if DEBUG
struct ContentView_Previews : PreviewProvider {
     
    static var previews: some View {
        ContentView().environmentObject(DataModel.shared)
        
    }
}
#endif





//--------- Screen Recording UI overlay window logic -------------


func recordUI(isHidden: Bool) {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var uiWindow: UIWindow!

    uiWindow = delegate.uiWindow!
    uiWindow.isHidden = isHidden
    print("Window Created")

}








