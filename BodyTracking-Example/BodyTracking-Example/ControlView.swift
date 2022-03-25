//
//  ControlView.swift
//  BodyTracking-Example
//
//  Created by Caius Sabau on 23/03/2022.
//

import SwiftUI
//import RealityKit

struct ControlView: View {
  //  @Binding var isControlsVisible: Bool
    @Binding var showDeviceSetup: Bool
  //  @Binding var showSettings: Bool
    
    var body: some View {
       
       // VStack {
            
            //This already exists in my code, maybe import it here? the reverse chevron
          //  ControlVisibilityToggleButton(/*isControlsVisible: $isControlsVisible*/)
            
          //  Spacer()
            
            
           // if isControlsVisible {
        ControlButtonBar(/*showBrowse: $showBrowse, showSettings: $showSettings*/showDeviceSetup: $showDeviceSetup) //after we added showSettings in the control view, we get an error because it needs to be part of the Control Button Bar struct as well (line 69)
          //  }
            
            
        //}
    }
}




struct ControlButtonBar: View {
//    @EnvironmentObject var placementSettings: PlacementSettings
    @Binding var showDeviceSetup: Bool //binding to the showBrowse state from ContentView
 //   @Binding var showSettings: Bool //Binding showSettings for Control View so that it works in ContentView
    
    var body: some View {
        HStack { /*
            
            //MostRecentlyPlaced Button
//            MostRecentlyPlacedButton().hidden(self.placementSettings.recentlyPlaced.isEmpty) //the recently placed btn will now be hidden if there's no item placed
                  */
            ControlButton(systemIconName: "clock.fill") {
              print("Recent button pressed")
              //self.showBrowse.toggle() //toggle between TRUE and FALSE of the STATE
            }
                  
                  
            Spacer ()

            //Record
            ControlButton(systemIconName: "square.grid.2x2") {
                print("Browse button pressed")
                 //toggle between TRUE and FALSE of the STATE
            }
            
            
            Spacer ()
            
            //Setup Button / Browse
            ControlButton(systemIconName: "slider.horizontal.3") {
                print("Settings button pressed")
                self.showDeviceSetup.toggle() 
            }.sheet(isPresented: $showDeviceSetup, content: {
                DeviceSetupView(showDeviceSetup: $showDeviceSetup)
            })
            
            
            /*.sheet(isPresented: $showSettings) {
                SettingsView(showSettings: $showSettings)
            }*/
            
        }
        .frame(maxWidth: 800)
        .padding(50)
        .background(Color.black.opacity(0.5)) //styling the button placeholder
            
    }
}


//creating a Modular struct for button creation instead of hardcoding them
struct ControlButton: View{
   
    let systemIconName: String
    let action: () -> Void
    
    var body: some View {
   
        Button(action: {
            self.action()
        }) {
            Image(systemName: systemIconName)
                .font(.system(size: 35))
                .foregroundColor(.white)
                .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 50, height: 50)
    }
}

//struct MostRecentlyPlacedButton: View {
////    @EnvironmentObject var placementSettings: PlacementSettings
//
//    var body: some View {
//        Button(action :{
//            print("Most recently placed btn pressed")
//            self.placementSettings.selectedModel = self.placementSettings.recentlyPlaced.last
//        }) {
//            if let mostRecentlyPlacedModel = self.placementSettings.recentlyPlaced.last {
//                Image(uiImage: mostRecentlyPlacedModel.thumbnail)
//                    .resizable()
//                    .frame(width: 46)
//                    .aspectRatio(1/1, contentMode: .fit)
//            } else {
//                Image(systemName: "clock.fill")
//                    .font(.system(size: 35))
//                    .foregroundColor(.white)
//                    .buttonStyle(PlainButtonStyle())
//            }
//        }
//        .frame(width: 50, height: 50)
//        .background(Color.white)
//        .cornerRadius(8.0)
//
//
//    }
//}

