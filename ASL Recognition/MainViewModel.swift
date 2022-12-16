//
//  MainViewModel.swift
//  ASL Recognition
//
//  Created by Michał on 15/12/2022.
//

import Foundation

protocol MainViewModelProtocol: AnyObject {
    var delegate: MainViewModelDelegate? { get set }
    func getPrediction(url: URL)
}

protocol MainViewModelDelegate: AnyObject {
    func showPrediction(model: PredictionModel)
}

class MainViewModel: MainViewModelProtocol {
    
    private var repository: RepositoryProtocol?
    weak var delegate: MainViewModelDelegate?
    
    init(repository: RepositoryProtocol) {
        self.repository = repository
    }
    
    func getPrediction(url: URL) {
        Task.init {
            let filename = generateFilename(url: url)
            do {
                let videoUrl = try await repository?.saveVideo(inputUrl: url, filename: filename)
                guard let videoUrl = videoUrl else {
                    print("\n Something went wrong \n")
                    return
                }
                print(videoUrl.absoluteString)
                guard let inputUrl = prepareStringURL(inputUrl: videoUrl) else { return }
                let model = try await repository?.getPrediction(inputURL: inputUrl)
                guard let model = model else { return }
                self.delegate?.showPrediction(model: model)
            } catch {
                print("\n\nError in ViewModel\n\n")
            }
        }
    }
    
    private func generateFilename(url: URL) -> String {
        let stringURL = url.absoluteString
        return String(stringURL.suffix(26))
    }
    
    private func prepareStringURL(inputUrl: URL) -> String? {
        var stringUrl = inputUrl.absoluteString
//        stringUrl = stringUrl.replacingOccurrences(of: ":", with: "%3A")
//        stringUrl = stringUrl.replacingOccurrences(of: "/", with: "%2F")
//        stringUrl = stringUrl.replacingOccurrences(of: "=", with: "%3D")
//        stringUrl = stringUrl.replacingOccurrences(of: "?", with: "%3F")
//        return stringUrl
        return stringUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
}
