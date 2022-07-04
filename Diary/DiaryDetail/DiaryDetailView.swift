//
//  DiaryDetailView.swift
//  Diary
//
//  Created by safari, Eddy on 2022/06/14.
//

import UIKit

final class DiaryDetailView: UIView {
    private var bottomConstraint: NSLayoutConstraint?
    
    private let diaryTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }()
    
    var isTextViewFirstResponder: Bool {
        diaryTextView.isFirstResponder
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(diary: Diary?) {
        if let diary = diary {
            diaryTextView.text = "\(diary.title ?? "")\n\(diary.body ?? "")"
        } else {
            diaryTextView.text = ""
        }
        
        diaryTextView.contentOffset = .zero
    }
    
    private func configureView() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureLayout() {
        self.addSubview(diaryTextView)
          
        let leadingConstraint = diaryTextView.leadingAnchor
            .constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor)
        let topConstraint = diaryTextView.topAnchor
            .constraint(equalTo: self.safeAreaLayoutGuide.topAnchor)
        let trailingConstraint = diaryTextView.trailingAnchor
            .constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor)
        let bottomConstraint = diaryTextView.bottomAnchor
            .constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
          
        NSLayoutConstraint.activate([
            leadingConstraint,
            topConstraint,
            trailingConstraint,
            bottomConstraint
          ])
        
        self.bottomConstraint = bottomConstraint
    }
    
    func changeBottomConstraint(value: CGFloat) {
        bottomConstraint?.constant = -value
        self.layoutIfNeeded()
    }
    
    func setFirstResponder() {
        self.diaryTextView.becomeFirstResponder()
    }
    
    func relinquishFirstResponder() {
        self.diaryTextView.resignFirstResponder()
    }
    
    func readText() -> String {
        return diaryTextView.text
    }
    
    func setTextViewAccessory(button: UIToolbar) {
        self.diaryTextView.inputAccessoryView = button
    }
}
