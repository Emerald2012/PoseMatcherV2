//
//import SwiftUI
//import PhotosUI
//import UIKit
//import Vision
//
//// MARK: - ProfileImageViewModel
//
//@MainActor
//final class ProfileImageViewModel: ObservableObject {
//
//    @Published var imageSelection: PhotosPickerItem? = nil {
//        didSet {
//            if let imageSelection {
//                Task {
//                    // Call the new load and process function
//                    try await loadAndProcessImage(from: imageSelection)
//                }
//            } else {
//                imageState = .empty
//                staticPosePath = nil // Clear the path when no image is selected
//            }
//        }
//    }
//
//    @Published private(set) var imageState: ImageState = .empty
//    // A new published property to store the CGPath
//    @Published private(set) var staticPosePath: CGPath? = nil
//
//    // An enum to represent the different states of the image.
//    enum ImageState {
//        case empty
//        case success(Image)
//        case loading(Progress)
//        case failure(Error)
//    }
//
//    // Corrected function to handle both loading and processing
//    private func loadAndProcessImage(from selection: PhotosPickerItem) async throws {
//        imageState = .loading(.init(totalUnitCount: 0))
//        do {
//            // Load the UIImage directly from the selection
//            if let data = try await selection.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
//                // Set the SwiftUI Image state
//                imageState = .success(Image(uiImage: uiImage))
//
//                // Perform pose detection and create the static path
//                //                let path = await createSkeletonPath(from: uiImage)
//                //                self.staticPosePath = path
//
//            } else {
//                imageState = .empty
//            }
//        } catch {
//            imageState = .failure(error)
//        }
//    }
//
//    //    private func createSkeletonPath(from image: UIImage) async -> CGPath? {
//    //        guard let cgImage = image.cgImage else { return nil }
//    //
//    //        return await withCheckedContinuation { continuation in
//    //            let request = VNDetectHumanBodyPoseRequest { request, error in
//    //                guard let observation = request.results?.first as? VNHumanBodyPoseObservation else {
//    //                    continuation.resume(returning: nil)
//    //                    return
//    //                }
//    //                do {
//    //                    let recognizedPoints = try observation.recognizedPoints(.all)
//    //                    let path = self.buildPath(from: recognizedPoints, imageSize: image.size)
//    //                    continuation.resume(returning: path)
//    //                } catch {
//    //                    continuation.resume(returning: nil)
//    //                }
//    //            }
//    //            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//    //            try? handler.perform([request])
//    //        }
//    //    }
//    //
//    //    private func buildPath(from recognizedPoints: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint], imageSize: CGSize) -> CGPath {
//    //        let path = CGMutablePath()
//    //        let connections: [(from: VNHumanBodyPoseObservation.JointName, to: VNHumanBodyPoseObservation.JointName)] = [
//    //            (.rightAnkle, .rightKnee), (.rightKnee, .rightHip),
//    //            (.leftAnkle, .leftKnee), (.leftKnee, .leftHip),
//    //            (.rightHip, .leftHip), (.rightHip, .rightShoulder), (.leftHip, .leftShoulder),
//    //            (.rightShoulder, .leftShoulder), (.rightShoulder, .rightElbow), (.rightElbow, .rightWrist),
//    //            (.leftShoulder, .leftElbow), (.leftElbow, .leftWrist),
//    //            (.rightShoulder, .neck), (.leftShoulder, .neck),
//    //            (.neck, .nose)
//    //        ]
//    //
//    //        for connection in connections {
//    //            if let from = recognizedPoints[connection.from], let to = recognizedPoints[connection.to] {
//    //                // Only draw if confidence is high for both points
//    //                if from.confidence > 0.3 && to.confidence > 0.3 {
//    //                    let fromPoint = VNImagePointForNormalizedPoint(from.location, Int(imageSize.width), Int(imageSize.height))
//    //                    let toPoint = VNImagePointForNormalizedPoint(to.location, Int(imageSize.width), Int(imageSize.height))
//    //
//    //                    path.move(to: fromPoint)
//    //                    path.addLine(to: toPoint)
//    //                }
//    //            }
//    //        }
//    //        return path
//    //    }
//    //}
//
//    // MARK: - ProfileImage (optional, but corrected for Transferable)
//
//    // This struct is no longer necessary if you use UIImage.self, but is kept for completeness.
//    // The transfer representation is corrected to ensure it returns a valid UIImage.
//    struct ProfileImage: Transferable {
//        let image: UIImage
//
//        enum TransferError: Error {
//            case importFailed
//        }
//
//        static var transferRepresentation: some TransferRepresentation {
//            DataRepresentation(importedContentType: .image) { data in
//#if canImport(UIKit)
//                guard let uiImage = UIImage(data: data) else {
//                    throw TransferError.importFailed
//                }
//                return ProfileImage(image: uiImage)
//#else
//                throw TransferError.importFailed
//#endif
//            }
//        }
//    }
//
//    // MARK: - CircularProfileImage
//
//    // A simple view to display the profile image based on the ViewModel's state.
//    struct CircularProfileImage: View {
//        let imageState: ProfileImageViewModel.ImageState
//
//        var body: some View {
//            switch imageState {
//            case .empty:
//                Image(systemName: "person.circle.fill")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 100, height: 100)
//                    .foregroundColor(.accentColor)
//                    .background(.gray)
//                    .clipShape(Circle())
//            case .success(let image):
//                image
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 100, height: 100)
//                    .clipShape(Circle())
//            case .loading(let progress):
//                ProgressView(value: progress.fractionCompleted)
//                    .progressViewStyle(.circular)
//                    .frame(width: 100, height: 100)
//                    .background(.gray)
//                    .clipShape(Circle())
//            case .failure(_):
//                Image(systemName: "exclamationmark.triangle.fill")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 100, height: 100)
//                    .foregroundColor(.red)
//                    .background(.gray)
//                    .clipShape(Circle())
//            }
//        }
//    }
//
//    // MARK: - PhotosSelector
//
//    struct PhotosSelector: View {
//
//        // The ViewModel instance for this view.
//        @StateObject private var viewModel = ProfileImageViewModel()
//
//        var body: some View {
//            VStack {
//                CircularProfileImage(imageState: viewModel.imageState)
//                    .overlay(alignment: .bottomTrailing) {
//                        PhotosPicker(selection: $viewModel.imageSelection, matching: .images, photoLibrary: .shared()) {
//                            Image(systemName: "pencil.circle.fill")
//                                .symbolRenderingMode(.multicolor)
//                                .font(.system(size: 30))
//                                .foregroundColor(.accentColor)
//                        }
//                        .buttonStyle(.borderless)
//                    }
//            }
//            .padding()
//        }
//    }
//}

import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @State private var selectedItems = [PhotosPickerItem]()
    @Binding var selectedImages: [Image]
    @State private var selectedCGImages: [CGImage]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(0..<selectedImages.count, id: \.self) { i in
                        selectedImages[i]
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                    }
                }
            }
            .toolbar {
                PhotosPicker("Select images", selection: $selectedItems, matching: .images)
            }
            .onChange(of: selectedItems) {
                Task {
                    selectedImages.removeAll()
                    
                    for item in selectedItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data),
                           let cgImage = uiImage.cgImage {
                            selectedCGImages.append(cgImage)
                        }
                    }
                }
            }
        }
    }
}
