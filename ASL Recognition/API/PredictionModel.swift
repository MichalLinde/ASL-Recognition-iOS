//
//  PredictionModel.swift
//  ASL Recognition
//
//  Created by Michał on 15/12/2022.
//

import Foundation

struct PredictionModel: Codable {
    var message: String?
    
    init(message: String?) {
        self.message = message
    }
}
