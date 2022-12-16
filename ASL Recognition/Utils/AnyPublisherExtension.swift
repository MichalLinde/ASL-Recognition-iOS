//
//  AnyPublisherExtension.swift
//  ASL Recognition
//
//  Created by Michał on 15/12/2022.
//

import Foundation
import Combine

extension AnyPublisher {
    func accomplishToAsync() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            
            cancellable = first()
                .sink { result in
                    switch result {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    continuation.resume(with: .success(value))
                }
        }
    }
}
