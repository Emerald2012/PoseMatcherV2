//
//  PoseRecogniserFunction.swift
//  PoseMatcher
//
//  Created by Carsten Anand on 16/8/25.
//

import Foundation
import Vision



func PoseRecogniser(inputImage: String) {
    let fileUrl = URL(fileURLWithPath: inputImage)
    let requestHandler = VNImageRequestHandler(url: fileUrl)
    let request = VNDetectHumanBodyPoseRequest { request, error in
        if let observations = request.results as? [VNHumanBodyPoseObservation] {
            for observation in observations {
                processObservation(observation)
                
            }
        }
    }
    
    do {
        try requestHandler.perform([request])
        
    } catch {
        print("unable to perform function: \(error)")
    }
}

func processObservation(_ observation: VNHumanBodyPoseObservation) {
    do {
        let points = try observation.recognizedPoints(forGroupKey: .all)
        
        if let leftWrist = points[VNHumanBodyPoseObservation.JointName.leftWrist.rawValue], leftWrist.confidence > 0.3 {
            print("left wrist at \(leftWrist.location)")
        }
    } catch {
        print("error reading joints\(error)")
    }
}
