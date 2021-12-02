//
//  ChatTextView.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/29.
//

import UIKit
import RSKPlaceholderTextView

class ChatTextView: UIView {
    
    let sendButton = UIButton()
    
    let textView = RSKPlaceholderTextView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupView() {
        
        textView.placeholder = "輸入訊息..."
        
        self.backgroundColor = .B1
        
        self.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            textView.heightAnchor.constraint(equalToConstant: 30),
            
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            
            textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            
            textView.widthAnchor.constraint(equalToConstant: UIScreen.width - 10 * 2 - 10 - 30)
        ])
        
        textView.textAlignment = .left
        
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 5, right: 5)
        
        textView.backgroundColor = .white
        
        textView.layer.cornerRadius = 15
        
        textView.layer.masksToBounds = true
        
        self.addSubview(sendButton)
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            sendButton.heightAnchor.constraint(equalToConstant: 30),
            
            sendButton.widthAnchor.constraint(equalToConstant: 30),
            
            sendButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            sendButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ])
        
        let image = UIImage(systemName: "paperplane")
        
        sendButton.setBackgroundImage(image, for: .normal)
        
        sendButton.tintColor = .white
    }
}
