//
//  NoLandmarksPopupView.swift
//  ASL Recognition
//
//  Created by Michał on 19/12/2022.
//

import Foundation
import UIKit

protocol NoLandmarksPopupViewDelegate: AnyObject {
    func closePopup()
}

class NoLandmarksPopupView: UIView {
    
    weak var delegate: NoLandmarksPopupViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.setupLayout()
    }
    
    private func setupLayout() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        whitePopup.addSubviews(titleTextView, line)
        
        titleTextView.anchor(
            top: whitePopup.safeTopAnchor,
            right: whitePopup.safeRightAnchor,
            paddingTop: 14,
            paddingRight: 10)
        titleText.centerX(inView: whitePopup)
        line.centerX(inView: whitePopup)
        line.anchor(
            bottom: whitePopup.bottomAnchor)
        line.topGreaterThanOrEqualTo(top: titleTextView.safeBottomAnchor, padding: 14)

        contentView.addSubviews(whitePopup, container)
        whitePopup.anchor(
            top: contentView.safeTopAnchor,
            left: contentView.safeLeftAnchor,
            right: contentView.safeRightAnchor)
        container.anchor(
            top: whitePopup.safeBottomAnchor,
            left: contentView.safeLeftAnchor,
            bottom: contentView.safeBottomAnchor,
            right: contentView.safeRightAnchor)
        
        self.addSubviews(contentView)
        contentView.anchor(
            left: self.safeLeftAnchor,
            right: self.safeRightAnchor,
            paddingLeft: 16,
            paddingRight: 16)
        contentView.centerY(inView: self)
        
        self.isHidden = true
    }
    
    private lazy var whitePopup: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()
    
    func animateUp(){
        self.contentView.transform = CGAffineTransform(translationX: .zero, y: self.bounds.size.height)
        self.isHidden = false
        self.alpha = .infinity
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = .infinity
        }) { completed in
            if completed {
                UIView.animate(withDuration: 0.5) {
                    self.contentView.transform = CGAffineTransform(translationX: .zero, y: .zero)
                }
            }
        }
    }
    
    func animateDown(onCompleted: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5, animations: {
            self.contentView.transform = CGAffineTransform(translationX: .zero, y: self.bounds.size.height)
        }) { _ in
            self.alpha = .zero
            self.isHidden = true
            onCompleted()
        }
    }
    
    private lazy var blurEffect: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.6
        blurEffectView.autoresizingMask = [ .flexibleWidth, .flexibleBottomMargin ]
        return blurEffectView
    }()
    
    private lazy var line: UIView = {
        let line = UIView()
        let width = UIScreen.main.bounds.width - (24 * 2)
        line.setDimensions(height: 1, width: width)
        line.backgroundColor = .darkGray
        return line
    }()
    
    lazy var titleText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.numberOfLines = .zero
        label.textColor = .black
        label.text = "Something went wrong!"
        return label
    }()
    
    private lazy var titleTextView: UIView = {
        let view = UIView()
        view.addSubview(titleText)
        titleText.fillSuperView()
        return view
    }()
    
    private lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.addSubviews(contentLabel, understandButton, spacer)
        contentLabel.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 16,
            paddingLeft: 10,
            paddingRight: 10
        )
        
        understandButton.anchor(
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor,
            paddingLeft: 10,
            paddingBottom: 16,
            paddingRight: 10
        )
        
        spacer.anchor(
            top: contentLabel.bottomAnchor,
            left: view.leftAnchor,
            bottom: understandButton.topAnchor,
            right: view.rightAnchor,
            paddingTop: 24
        )
        return view
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .darkGray
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = .zero
        label.text = "Our serrvice failed to detect gesture due to quality of the video. Make sure to record both hands, arms and face. Keep in mind that lighting also affects our processing."
        return label
    }()
    
    private lazy var understandButton: UIButton = {
        let button = UIButton()
        button.setHeight(50)
        button.setTitle("Understood", for: .normal)
        button.backgroundColor = .red
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(understandButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var spacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    @objc func understandButtonTapped() {
        self.delegate?.closePopup()
    }
}
