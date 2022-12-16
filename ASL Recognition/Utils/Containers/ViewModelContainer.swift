//
//  ViewModelContainer.swift
//  ASL Recognition
//
//  Created by Michał on 15/12/2022.
//

import Foundation
import Swinject

class ViewModelContainer {
    static let sharedContainer = ViewModelContainer()
    let container = Container()
    
    private init() {
        self.setupContainer()
    }
    
    private func setupContainer() {
        let repositoryContainer = RepositoryContainer.sharedContainer.container
        
        container.register(MainViewModelProtocol.self) { _ in
            return MainViewModel(repository: repositoryContainer.resolve(RepositoryProtocol.self)!)
        }
    }
}
