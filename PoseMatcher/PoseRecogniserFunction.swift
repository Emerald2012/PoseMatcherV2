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
    let request = VNDetectHumanBodyPoseRequest()
    
    do {
        try requestHandler.perform([request])
        
        let observation = request.results?.first
        
    
        
    } catch {
        print("unable to perform function: \(error)")
    }
}

