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
}

class Repository: RepositoryProtocol {

    private var storage = Storage.storage()
    private var bag = Set<AnyCancellable>()
    
    func saveVideo(inputUrl: URL, filename: String) async throws -> URL {
        try await Deferred {
            Future<URL, Error> { promise in
                let storageRef = self.storage.reference()
                let fileRef = storageRef.child(filename)
                let uploadTask = fileRef.putFile(from: inputUrl, metadata: nil) { metadata, error in
                    
                    if error != nil {
                        print("\n\nFirst ERROR \n\(String(describing: error))\n\n")
                    }
                    
                    guard let metadata = metadata else { return }
                    
                    let size = metadata.size
                    fileRef.downloadURL{ (url, error) in
                        if error != nil {
                            print("\n\n Second ERROR \n\(String(describing: error))\n\n")
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
        
        let url = URL(string: "http://192.168.1.3:5050/\(inputURL)")
        guard let url = url else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let model = try JSONDecoder().decode(PredictionModel.self, from: data)
            return model
        } catch {
            print("\n\n Error fetching from API \n\n")
        }
        return nil
    }
}
