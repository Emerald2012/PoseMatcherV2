import SwiftUI
import Vision

/// A view that displays an image and overlays a human pose skeleton detected by the Vision framework.
struct PoseRecognitionView: View {
    
    /// The state that holds the image with the drawn skeleton.
    /// Updating this state will trigger a view redraw.
    @State private var poseImage: UIImage?
    
    /// The original image to be processed.
    private let originalUIImage = UIImage(resource: .image1)
    
    var body: some View {
        VStack {
            if let poseImage = poseImage {
                // Display the processed image using SwiftUI's Image view.
                Image(uiImage: poseImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Show a placeholder while the image is being processed.
                ProgressView("Detecting Pose...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            // Start the pose detection when the view first appears.
            detectHumanBodyPose(in: originalUIImage)
        }
    }
    
    /// Performs a human body pose detection request using the Vision framework.
    private func detectHumanBodyPose(in image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        // Create the Vision request.
        let request = VNDetectHumanBodyPoseRequest { request, error in
            // Handle the completion on the main thread.
            DispatchQueue.main.async {
                guard let results = request.results as? [VNHumanBodyPoseObservation] else {
                    print("No human detected.")
                    return
                }
                
                // Draw the skeleton and update the state.
                self.poseImage = self.drawBodyJoints(from: results, on: image)
            }
        }
        
        // Perform the request on a background thread to avoid blocking the UI.
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform Vision request: \(error.localizedDescription)")
            }
        }
    }
    
    /// Draws the detected body joints and connections onto a new UIImage.
    private func drawBodyJoints(from observations: [VNHumanBodyPoseObservation], on originalImage: UIImage) -> UIImage {
        // Define the connections between body joints.
        let jointConnections: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
            (.leftShoulder, .rightShoulder), (.leftShoulder, .leftElbow), (.leftElbow, .leftWrist),
            (.rightShoulder, .rightElbow), (.rightShoulder, .rightWrist),
            (.leftHip, .rightHip), (.leftShoulder, .leftHip), (.rightShoulder, .rightHip),
            (.leftHip, .leftKnee), (.rightHip, .rightKnee),
            (.leftKnee, .leftAnkle), (.rightKnee, .rightAnkle)
        ]
        
        // Use UIGraphicsImageRenderer to create a new image.
        let renderer = UIGraphicsImageRenderer(size: originalImage.size)
        
        return renderer.image { context in
            // Draw the original image first.
            originalImage.draw(at: .zero)
            
            // Set up the drawing context for the lines.
            context.cgContext.setStrokeColor(UIColor.red.cgColor)
            context.cgContext.setLineWidth(5.0)
            
            for observation in observations {
                for (startJoint, endJoint) in jointConnections {
                    if let startPoint = try? observation.recognizedPoint(startJoint),
                       let endPoint = try? observation.recognizedPoint(endJoint),
                       startPoint.confidence > 0.5, endPoint.confidence > 0.5 {
                        
                        // Convert normalized coordinates from Vision to pixel coordinates.
                        let startLocation = VNImagePointForNormalizedPoint(startPoint.location, Int(originalImage.size.width), Int(originalImage.size.height))
                        let endLocation = VNImagePointForNormalizedPoint(endPoint.location, Int(originalImage.size.width), Int(originalImage.size.height))
                        
                        // Draw the line segment.
                        context.cgContext.move(to: startLocation)
                        context.cgContext.addLine(to: endLocation)
                        context.cgContext.strokePath()
                    }
                }
            }
        }
    }
}

#Preview {
    PoseRecognitionView()
}
