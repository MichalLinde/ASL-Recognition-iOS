//
//  UserInfoViewController.swift
//  ASL Recognition
//
//  Created by Michał on 16/12/2022.
//

import Foundation
import UIKit

class UserInfoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
    }
    
    private func setupLayout() {
        self.view.backgroundColor = .white
        self.view.addSubviews(titleLabel, recordInfoLabel, recordIcon, stopRecordInfoLabel, stopIcon, noteInfoLabel)
        
        titleLabel.anchor(
            top: self.view.topAnchor,
            left: self.view.leftAnchor,
            right: self.view.rightAnchor,
            paddingTop: 15,
            paddingLeft: 15,
            paddingRight: 15
        )
        
        recordInfoLabel.anchor(
            top: titleLabel.bottomAnchor,
            left: self.view.leftAnchor,
            right: self.view.rightAnchor,
            paddingTop: 24,
            paddingLeft: 15,
            paddingRight: 15
        )
        
        recordIcon.anchor(
            top: recordInfoLabel.bottomAnchor,
            paddingTop: 15
        )
        recordIcon.centerX(inView: self.view)
        
        stopRecordInfoLabel.anchor(
            top: recordIcon.bottomAnchor,
            left: self.view.leftAnchor,
            right: self.view.rightAnchor,
            paddingTop: 24,
            paddingLeft: 15,
            paddingRight: 15
        )
        
        stopIcon.anchor(
            top: stopRecordInfoLabel.bottomAnchor,
            paddingTop: 15
        )
        stopIcon.centerX(inView: self.view)
        
        noteInfoLabel.anchor(
            left: self.view.leftAnchor,
            bottom: self.view.safeBottomAnchor,
            right: self.view.rightAnchor,
            paddingLeft: 15,
            paddingBottom: 25,
            paddingRight: 15
        )
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to te American Sign Language recognition application"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = .zero
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var recordInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "To translate gesture point camera at the target and press record button"
        label.font = .systemFont(ofSize: 18)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = .zero
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var recordIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "record.circle")?.withTintColor(.red)
        view.tintColor = .red
        view.setDimensions(height: 100, width: 100)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var stopRecordInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "To stop recording press stop button"
        label.font = .systemFont(ofSize: 18)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = .zero
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var stopIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "stop")?.withTintColor(.red)
        view.tintColor = .red
        view.setDimensions(height: 100, width: 100)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var noteInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Note: Best results appear when both arms and hands are clearly visible"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .red
        label.textAlignment = .center
        label.numberOfLines = .zero
        label.lineBreakMode = .byWordWrapping
        return label
    }()

}
