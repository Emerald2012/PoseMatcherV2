
//
//  PoseEstimationModel.swift
//  PoseMatcher
//
//  Created by Carsten Anand on 23/8/25.
//

import SwiftUI
import Vision
import AVFoundation
import Observation

// 1.
struct StaticBodyConnection: Identifiable {
    let id = UUID()
    let from: HumanBodyPoseObservation.JointName
    let to: HumanBodyPoseObservation.JointName
}

@Observable
class StaticPoseEstimationViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // 2.
    var detectedBodyParts: [HumanBodyPoseObservation.JointName: CGPoint] = [:]
    var bodyConnections: [StaticBodyConnection] = []
    
    override init() {
        super.init()
        setupBodyConnections()
        //    }
        
        // 3.
        func setupBodyConnections() {
            bodyConnections = [
                StaticBodyConnection(from: .nose, to: .neck),
                StaticBodyConnection(from: .neck, to: .rightShoulder),
                StaticBodyConnection(from: .neck, to: .leftShoulder),
                StaticBodyConnection(from: .rightShoulder, to: .rightHip),
                StaticBodyConnection(from: .leftShoulder, to: .leftHip),
                StaticBodyConnection(from: .rightHip, to: .leftHip),
                StaticBodyConnection(from: .rightShoulder, to: .rightElbow),
                StaticBodyConnection(from: .rightElbow, to: .rightWrist),
                StaticBodyConnection(from: .leftShoulder, to: .leftElbow),
                StaticBodyConnection(from: .leftElbow, to: .leftWrist),
                StaticBodyConnection(from: .rightHip, to: .rightKnee),
                StaticBodyConnection(from: .rightKnee, to: .rightAnkle),
                StaticBodyConnection(from: .leftHip, to: .leftKnee),
                StaticBodyConnection(from: .leftKnee, to: .leftAnkle)
            ]
        }
        
      
        // 5.
        func processFrame(_ image: CGImage) async -> [HumanBodyPoseObservation.JointName: CGPoint]? {
        
            let request = DetectHumanBodyPoseRequest()
            
            do {
                let results = try await request.perform(on: image)
                if let observation = results.first {
                    return extractPoints(from: observation)
                }
            } catch {
                print("Error processing frame: \(error.localizedDescription)")
            }
            
            return nil
        }
        
        // 6.
        func extractPoints(from observation: HumanBodyPoseObservation) -> [HumanBodyPoseObservation.JointName: CGPoint] {
            var detectedPoints: [HumanBodyPoseObservation.JointName: CGPoint] = [:]
            let humanJoints: [HumanBodyPoseObservation.PoseJointsGroupName] = [.face, .torso, .leftArm, .rightArm, .leftLeg, .rightLeg]
            
            for groupName in humanJoints {
                let jointsInGroup = observation.allJoints(in: groupName)
                for (jointName, joint) in jointsInGroup {
                    if joint.confidence > 0.5 { // Ensuring only high-confidence joints are added
                        let point = joint.location.verticallyFlipped().cgPoint
                        detectedPoints[jointName] = point
                    }
                }
            }
            return detectedPoints
        }
    }
}
