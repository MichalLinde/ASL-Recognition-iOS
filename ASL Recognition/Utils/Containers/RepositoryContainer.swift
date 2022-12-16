//
//  RepositoryContainer.swift
//  ASL Recognition
//
//  Created by Michał on 15/12/2022.
//

import Foundation
import Swinject

class RepositoryContainer {
    static let sharedContainer = RepositoryContainer()
    let container = Container()
    
    private init() {
        self.setupContainer()
    }
    
    private func setupContainer() {
        container.register(RepositoryProtocol.self) { _ in
            return Repository()
        }.inObjectScope(.container)
    }
}
