//
//  PoseRecognitionView.swift
//  PoseMatcher
//
//  Created by Carsten Anand on 16/8/25.
//

import SwiftUI
import Vision


struct PoseRecognitionView: View {
    
    @State var inputImage: String
    
    var body: some View {
        Text("Text")
            .onAppear{
                PoseRecogniser(inputImage: inputImage)
            }
        
    }
}

#Preview {
    PoseRecognitionView(inputImage: "tristan")
}
