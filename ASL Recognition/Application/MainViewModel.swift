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
    func getTextToDisplay(currentText: String?, newText: String) -> String
}

protocol MainViewModelDelegate: AnyObject {
    func showPrediction(model: PredictionModel)
    func hideLoadingScreen()
    func showErrorAlert(error: String)
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
                    return
                }
                guard let inputUrl = prepareStringURL(inputUrl: videoUrl) else { return }
                let model = try await repository?.getPrediction(inputURL: inputUrl)
                guard let model = model else { return }
                self.delegate?.showPrediction(model: model)
                self.delegate?.hideLoadingScreen()
                self.repository?.deleteFileFromUrl(stringUrl: videoUrl.absoluteString)
                self.removeFileAtUrl(fileUrl: url)
            } catch (let error){
                guard let error = error as? ApiError else {
                    self.delegate?.showErrorAlert(error: "Sorry, something went wrong. Please try again.")
                    return
                }
                self.delegate?.showErrorAlert(error: error.localizedDescription)
            }
        }
    }
    
    private func generateFilename(url: URL) -> String {
        let stringURL = url.absoluteString
        return String(stringURL.suffix(26))
    }
    
    private func prepareStringURL(inputUrl: URL) -> String? {
        let stringUrl = inputUrl.absoluteString
        return stringUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
    
    func getTextToDisplay(currentText: String?, newText: String) -> String {
        if let text = currentText, !text.isEmpty {
            let components = text.components(separatedBy: .whitespacesAndNewlines)
            var words = components.filter{ !$0.isEmpty }
            if words.count >= 5 {
                words.remove(at: 0)
                words.append(newText)
                return words.joined(separator: " ")
            } else {
                return text + " \(newText)"
            }
        } else {
            return newText
        }
    }
    
    private func removeFileAtUrl(fileUrl: URL) {
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            do {
                try FileManager.default.removeItem(atPath: fileUrl.path)
            } catch {
                print("\nError occured during file deletion\n")
            }
        }
    }
}
