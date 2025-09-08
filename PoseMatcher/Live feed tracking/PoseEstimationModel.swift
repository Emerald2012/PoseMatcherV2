import SwiftUI
import Vision
import AVFoundation
import Observation

// 1.
struct LiveBodyConnection: Identifiable {
    let id = UUID()
    let from: HumanBodyPoseObservation.JointName
    let to: HumanBodyPoseObservation.JointName
}

@Observable
class LivePoseEstimationViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    // 2.
    var detectedBodyParts: [HumanBodyPoseObservation.JointName: CGPoint] = [:]
    var bodyConnections: [LiveBodyConnection] = []
    
    override init() {
        super.init()
        setupBodyConnections()
    }
    
    // 3.
    private func setupBodyConnections() {
        bodyConnections = [
            LiveBodyConnection(from: .nose, to: .neck),
            LiveBodyConnection(from: .neck, to: .rightShoulder),
            LiveBodyConnection(from: .neck, to: .leftShoulder),
            LiveBodyConnection(from: .rightShoulder, to: .rightHip),
            LiveBodyConnection(from: .leftShoulder, to: .leftHip),
            LiveBodyConnection(from: .rightHip, to: .leftHip),
            LiveBodyConnection(from: .rightShoulder, to: .rightElbow),
            LiveBodyConnection(from: .rightElbow, to: .rightWrist),
            LiveBodyConnection(from: .leftShoulder, to: .leftElbow),
            LiveBodyConnection(from: .leftElbow, to: .leftWrist),
            LiveBodyConnection(from: .rightHip, to: .rightKnee),
            LiveBodyConnection(from: .rightKnee, to: .rightAnkle),
            LiveBodyConnection(from: .leftHip, to: .leftKnee),
            LiveBodyConnection(from: .leftKnee, to: .leftAnkle)
        ]
    }

    // 4.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        Task {
            if let detectedPoints = await processFrame(sampleBuffer) {
                DispatchQueue.main.async {
                    self.detectedBodyParts = detectedPoints
                }
            }
        }
    }

    // 5.
    func processFrame(_ sampleBuffer: CMSampleBuffer) async -> [HumanBodyPoseObservation.JointName: CGPoint]? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        
        let request = DetectHumanBodyPoseRequest()
        
        do {
            let results = try await request.perform(on: imageBuffer, orientation: .none)
            if let observation = results.first {
                return extractPoints(from: observation)
            }
        } catch {
            print("Error processing frame: \(error.localizedDescription)")
        }

        return nil
    }

    // 6.
    private func extractPoints(from observation: HumanBodyPoseObservation) -> [HumanBodyPoseObservation.JointName: CGPoint] {
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
