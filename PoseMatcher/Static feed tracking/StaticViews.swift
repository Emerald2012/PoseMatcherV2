//
//  Views.swift
//  PoseMatcher
//
//  Created by Carsten Anand on 23/8/25.
//

import SwiftUI
import AVFoundation
import Vision

// 1.
struct StaticViews: View {
    @State private var poseViewModel = StaticPoseEstimationViewModel()
    @State var image: CGImage
    var body: some View {
        // 2.
        ZStack {
            // 2a.
            Image(image, scale: 1.0, label: Text("Text"))
                .edgesIgnoringSafeArea(.all)
            // 2b.
            StaticPoseOverlayView(
                bodyParts: poseViewModel.detectedBodyParts,
                connections: poseViewModel.bodyConnections
            )
        }
    
    }
}
