//
//  ApiError.swift
//  ASL Recognition
//
//  Created by Michał on 18/12/2022.
//

import Foundation

enum ApiError: Error {
    case firebaseError
    case apiError
    
    var localizedDescription: String {
        switch self {
        case .firebaseError:
            return "Sorry, an error occured during file uplaod to server. Please try again later."
        case .apiError:
            return "Sorry, an error occured while reaching the server. Please check your Internet connection and try again later. "
        }
    }
}
