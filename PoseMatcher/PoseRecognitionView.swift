//
//  PoseRecognitionView.swift
//  PoseMatcher
//
//  Created by Carsten Anand on 16/8/25.
//

import SwiftUI
import Vision


struct ViewController: UIViewRepresentable {
    
    var imageView: UIImageView!
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(resource: .image1)
        return imageView
        
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: uiView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: uiView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: uiView.widthAnchor, multiplier: 0.9),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
        detectHumanBodyPose(in: imageView.image!)
        
    }
    
    func detectHumanBodyPose(in image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNDetectHumanBodyPoseRequest(completionHandler: { (request, error) in
            guard let results = request.results as? [VNHumanBodyPoseObservation] else {
                print("no human detected")
                return
            }
            DispatchQueue.main.async {
                self.drawBodyJoints(from: results)
                
            }
        })
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("failed to perform request: \(error)")
            }
        }
    }
    
    func drawBodyJoints(from observations: [VNHumanBodyPoseObservation]) {
        imageView.subviews.forEach { $0.removeFromSuperview() }
        
        guard let image = imageView.image else {
            print("No image found in imageView")
            return
        }
        let imageViewSize = imageView.bounds.size
        let imageSize = image.size
        let scale = min(imageViewSize.width, imageViewSize.height / imageSize.height)
        
        let scaledImageSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let imageOrigin = CGPoint(x: (imageViewSize.width - scaledImageSize.width) / 2, y: (imageViewSize.height - scaledImageSize.height) / 2 )
        
        for observation in observations {
            var jointPoints: [CGPoint] = []
            
            for jointName in observation.availableJointNames {
                if let recognizedPoint = try? observation.recognizedPoint(jointName) {
                    let xPosition = imageOrigin.x + recognizedPoint.location.x * scaledImageSize.width
                    let yPosition = imageOrigin.y + (1 - recognizedPoint.location.y) * scaledImageSize.height
                    let jointPoint = CGPoint(x: xPosition, y: yPosition)
                    jointPoints.append(jointPoint)
                }
            }
            let jointConnections: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
                (.leftShoulder, .rightShoulder),
                (.leftShoulder, .leftElbow),
                (.leftElbow, .leftWrist),
                (.rightShoulder, .rightElbow),
                (.rightShoulder, .rightWrist),
                (.leftHip, .rightHip),
                (.leftShoulder, .leftHip),
                (.rightShoulder, .rightHip),
                (.leftHip, .leftKnee),
                (.rightHip, .rightKnee),
                (.rightKnee, .rightAnkle)
            ]
            
            for (startJoint, endJoint) in jointConnections {
                if let startPoint = try? observation.recognizedPoint(startJoint),
                   let endPoint = try? observation.recognizedPoint(endJoint),
                   startPoint.confidence > 0.5, endPoint.confidence > 0.5 {
                    
                    let startX = imageOrigin.x + startPoint.location.x * scaledImageSize.width
                    let startY = imageOrigin.y + (1 - startPoint.location.x) * scaledImageSize.height
                    let endX = imageOrigin.x + endPoint.location.x * scaledImageSize.width
                    let endY = imageOrigin.y + (1 - endPoint.location.y) * scaledImageSize.height
                    
                    let linePath = UIBezierPath()
                    linePath.move(to: CGPoint(x: startX, y: startY))
                    linePath.addLine(to: CGPoint(x: endX, y: endY))
                    
                    let shapeLayer = CAShapeLayer()
                    shapeLayer.path = linePath.cgPath
                    shapeLayer.strokeColor = UIColor.red.cgColor
                    shapeLayer.lineWidth = 2.0
                    
                    imageView.layer.addSublayer(shapeLayer)
                    
                }
            }
        }
    }
}

struct PoseRecognitionView: View {
    
    
    
    var body: some View {
               ViewController()
    }
}

#Preview {
    PoseRecognitionView()
}
