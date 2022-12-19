//
//  Repository.swift
//  ASL Recognition
//
//  Created by Michał on 15/12/2022.
//

import Foundation
import FirebaseStorage
import Combine
import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseAuth

protocol RepositoryProtocol: AnyObject {
    func saveVideo(inputUrl: URL, filename: String) async throws -> URL
    func getPrediction(inputURL: String) async throws -> PredictionModel?
    func deleteFileFromUrl(stringUrl: String)
}

class Repository: RepositoryProtocol {
    
    enum Constants {
        static let ipAdrress = "192.168.1.3"
//        static let ipAdrress = "172.20.10.7"
    }

    private var storage = Storage.storage()
    private var bag = Set<AnyCancellable>()
    
    func saveVideo(inputUrl: URL, filename: String) async throws -> URL {
        try await Deferred {
            Future<URL, ApiError> { promise in
                let storageRef = self.storage.reference()
                let fileRef = storageRef.child(filename)
                _ = fileRef.putFile(from: inputUrl, metadata: nil) { metadata, error in
                    
                    if error != nil {
                        promise(.failure(ApiError.firebaseError))
                        return
                    }
                    
                    fileRef.downloadURL{ (url, error) in
                        if error != nil {
                            promise(.failure(ApiError.firebaseError))
                            return
                        }
                        guard let outputUrl = url else { return }
                        promise(.success(outputUrl))
                    }
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
        .accomplishToAsync()
    }
    
    func getPrediction(inputURL: String) async throws -> PredictionModel? {
        
        let url = URL(string: "http://\(Constants.ipAdrress):5050/\(inputURL)")
        guard let url = url else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let model = try JSONDecoder().decode(PredictionModel.self, from: data)
            return model
        } catch {
            throw ApiError.apiError
        }
    }
    
    func deleteFileFromUrl(stringUrl: String) {
        let ref = storage.reference(forURL: stringUrl)
        ref.delete { error in
            if error != nil {
                print("\nError occured during deletion\n\(String(describing: error))\n")
            }
        }
    }
}
