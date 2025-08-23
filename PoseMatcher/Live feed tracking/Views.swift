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
struct Views: View {
    @State private var cameraViewModel = CameraViewModel()
    @State private var poseViewModel = PoseEstimationViewModel()
    
    var body: some View {
        // 2.
        ZStack {
            // 2a.
            CameraPreviewView(session: cameraViewModel.session)
                .edgesIgnoringSafeArea(.all)
            // 2b.
            PoseOverlayView(
                bodyParts: poseViewModel.detectedBodyParts,
                connections: poseViewModel.bodyConnections
            )
        }
        .task {
            await cameraViewModel.checkPermission()
            cameraViewModel.delegate = poseViewModel
        }
    }
}
