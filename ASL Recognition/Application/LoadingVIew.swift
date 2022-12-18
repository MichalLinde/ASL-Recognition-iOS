//
//  LoadingVIew.swift
//  ASL Recognition
//
//  Created by Michał on 16/12/2022.
//

import Foundation
import UIKit

class LoadingView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        self.backgroundColor = .black.withAlphaComponent(0.7)
        self.addSubview(spinner)
        spinner.center(inView: self)
    }
    
    lazy var spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.backgroundColor = .clear
        view.color = .white
        view.style = .large
        view.hidesWhenStopped = false
        return view
    }()
    
}
