//
//  PhotoPickerView.swift
//  PoseMatcher
//
//  Created by Carsten Anand on 23/8/25.
//


//  PhotosSelectorView.swift
//  PhotosSelector

import SwiftUI
import PhotosUI



@MainActor
final class ProfileImageViewModel: ObservableObject {
    
   
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
           
            if let imageSelection {
                Task {
                    try await loadImage(from: imageSelection)
                }
            } else {
                imageState = .empty
            }
        }
    }
    
  
    @Published private(set) var imageState: ImageState = .empty
    
    // An enum to represent the different states of the image.
    enum ImageState {
        case empty
        case success(Image)
        case loading(Progress)
        case failure(Error)
    }
    
    private func loadImage(from selection: PhotosPickerItem) async throws {
        imageState = .loading(selection.loadTransferable(type: ProfileImage.self))
        
        do {
            if let profileImage = try await selection.loadTransferable(type: ProfileImage.self) {
                imageState = .success(profileImage.image)
            } else {
                imageState = .empty
            }
        } catch {
            // If an error occurs, update the imageState with the failure.
            imageState = .failure(error)
        }
    }
}


struct ProfileImage: Transferable {
    let image: Image
    
    enum TransferError: Error {
        case importFailed
    }
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            #if canImport(AppKit)
            guard let nsImage = NSImage(data: data) else {
                throw TransferError.importFailed
            }
            let image = Image(nsImage: nsImage)
            return ProfileImage(image: image)
            #elseif canImport(UIKit)
            // For iOS/iPadOS, import as UIImage.
            guard let uiImage = UIImage(data: data) else {
                throw TransferError.importFailed
            }
            let image = Image(uiImage: uiImage)
            return ProfileImage(image: image)
            #else
            throw TransferError.importFailed
            #endif
        }
    }
}

// MARK: - CircularProfileImage

// A simple view to display the profile image based on the ViewModel's state.
struct CircularProfileImage: View {
    let imageState: ProfileImageViewModel.ImageState
    
    var body: some View {
        switch imageState {
        case .empty:
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)
                .background(.gray)
                .clipShape(Circle())
        case .success(let image):
            image
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
        case .loading(let progress):
            ProgressView(value: progress.fractionCompleted)
                .progressViewStyle(.circular)
                .frame(width: 100, height: 100)
                .background(.gray)
                .clipShape(Circle())
        case .failure(_):
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)
                .background(.gray)
                .clipShape(Circle())
        }
    }
}


struct PhotosSelector: View {
    
    // The ViewModel instance for this view.
    @StateObject private var viewModel = ProfileImageViewModel()
    
    var body: some View {
        VStack {
            CircularProfileImage(imageState: viewModel.imageState)
                .overlay(alignment: .bottomTrailing) {
                    PhotosPicker(selection: $viewModel.imageSelection, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "pencil.circle.fill")
                            .symbolRenderingMode(.multicolor)
                            .font(.system(size: 30))
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.borderless)
                }
        }
        .padding()
    }
}


