//
//  ControlView.swift
//  BodyTracking-Example
//
//  Created by Caius Sabau on 23/03/2022.
//

import SwiftUI
import ReplayKit

struct ControlView: View {
    
    //screen record variables
    private let recorder = RPScreenRecorder.shared()
    @State private var isBool = false
    @State var rp: RPPreviewView!
    @State private var isRecording = false
    @State private var isShowPreviewVideo = false
    
    //variable to toggle to show / hide record uiWindow
    @State private var isHidden = false

    @State private var showDeviceSetup: Bool = false
    
    
    var body: some View {
        
        VStack{
            HStack{
                ///
                Spacer()
                ///
                ///
                Spacer()
                ///
                ///
                Image(systemName: "xmark")
//                Text("><")
                .font(.system(size: 25))
                .foregroundColor(.white)

                .position(x: UIScreen.main.bounds.width - 50 , y: -60)

            }
            ///
            Spacer()
            ///
            HStack{
                ///
                Spacer()
                ///
                //RECENTS btn
                Button(action: {
            
                    VideoView() // trying to call the view from PlayViewoViewController that contains the PlayViewoViewController UIViewController Wrapper but it doesn't work
                    print("backBTN: ")

                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 35))
                        .foregroundColor(.white)
                        .buttonStyle(PlainButtonStyle())
                }
                .frame(width: 50, height: 50)
                ///
                Spacer()
                ///
                //RECORD btn
                Button(action: {
                    if !self.isRecording {
                        self.startRecord()
                    } else {
                        self.stopRecord()
                    }
                }) {
                    Image(systemName: isRecording ? "stop.circle" : "video.circle")
                        .resizable()
                        .frame(width: 70, height: 70)
                }
                ///
                Spacer()
                ///
                //CALIBRATE btn
                Button(action: {
                    //self.backBtnIsVisible.toggle()
                    print("backBTN: ")
                    DataModel.shared.arView = nil
                    self.showDeviceSetup.toggle()
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 35))
                        .foregroundColor(.white)
                        .buttonStyle(PlainButtonStyle())
                }
                .frame(width: 50, height: 50)
                .sheet(isPresented: $showDeviceSetup, content: {
                    
                    DeviceSetupView(showDeviceSetup: $showDeviceSetup)
                })
                ///
                Spacer()
                ///
                ///
            }
            .padding() //end of HStack
        }
        //end of VStack
        
        if isShowPreviewVideo {
            rp
            .position(CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 - 70/*y:55*/))
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 30)
            .transition(.move(edge: .bottom))
            
            .edgesIgnoringSafeArea(.all)
            //.padding()
        }
        
    } // end of BODY
    
    
   //--- functions ---
    
    // Start of the ORIGINAL RECORD function
    private func startRecord() {
        guard recorder.isAvailable else {
            print("Recording is not available at this time.")
            return
        }
        if !recorder.isRecording {
            recorder.startRecording { (error) in
                guard error == nil else {
                    print("There was an error starting the recording.")
                    return
                }
                print("Started Recording Successfully")
                self.isRecording = true
                //self.backBtnIsVisible = false
            }
        }
    }

    private func stopRecord() {
        recorder.stopRecording { (preview, error) in
            print("Stopped recording")
            self.isRecording = false
            //self.backBtnIsVisible = true

            guard let preview = preview else {
                print("Preview controller is not available.")
                return
            }
            self.rp = RPPreviewView(rpPreviewViewController: preview, isShow: self.$isShowPreviewVideo)
            withAnimation {
                self.isShowPreviewVideo = true
            }
        }
    }
    //END of the record function
    
} // end of CONTROL view
        
        
        
        
        
        
        
        
        
        
        
        







//--------- Screen Recording -------------

struct RPPreviewView: UIViewControllerRepresentable {
let rpPreviewViewController: RPPreviewViewController
@Binding var isShow: Bool

func makeCoordinator() -> Coordinator {
    Coordinator(self)
}

func makeUIViewController(context: Context) -> RPPreviewViewController {
    rpPreviewViewController.previewControllerDelegate = context.coordinator
    rpPreviewViewController.modalPresentationStyle = .fullScreen
    
    return rpPreviewViewController
}

func updateUIViewController(_ uiViewController: RPPreviewViewController, context: Context) { }

class Coordinator: NSObject, RPPreviewViewControllerDelegate {
    var parent: RPPreviewView
       
    init(_ parent: RPPreviewView) {
        self.parent = parent
    }
       
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        withAnimation {
            parent.isShow = false
        }
    }
}
}


