//
//  CameraToggle.swift
//  iOSCamera
//
//  Created by Jiwon_Hae on 2022/01/04.
//

import SwiftUI

struct CameraToggle: View {
    @EnvironmentObject var viewModel : ContentViewModel
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Button(action: {
                    viewModel.switchCamera()
                }, label: {
                    if(viewModel.currentLensFacing){
                        Text("BACK")
                    }else{
                        Text("FRONT")
                    }
                })
                .padding(.all, 10)
                .foregroundColor(viewModel.currentLensFacing ? .white : .black)
                .background(viewModel.currentLensFacing ? Color.blue : .white)
                .animation(.easeInOut, value: 0.25)
                .cornerRadius(10)
                
            }
            Spacer()
                
        }
    }
}

