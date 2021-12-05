//
//  ChatHeaderCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit
import FirebaseFirestore
import RSKPlaceholderTextView

class GroupChatHeaderCell: UITableViewCell {
    
    var groupInfo: Group?
    
    @IBOutlet weak var hostBadgeButton: UIButton!
    
    @IBOutlet weak var trailName: UITextField! {
        didSet {
            trailName.delegate = self
        }
    }
    
    @IBOutlet weak var numOfPeople: UITextField! {
        didSet {
            numOfPeople.delegate = self
        }
    }
    
    @IBOutlet weak var note: RSKPlaceholderTextView!{
        didSet {
            note.isScrollEnabled = false
            note.delegate = self
        }
    }
    
    @IBOutlet weak var travelDate: UILabel!
    
    @IBOutlet weak var travelTime: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var travelTimePicker: UIDatePicker!
    
    @IBOutlet weak var hostName: UILabel!
    
    @IBOutlet weak var requestButton: UIButton!
    
    var isEditting: Bool = false {
        
        didSet {
            
            trailName.isEnabled = isEditting ? true : false
            
            trailName.textColor = isEditting ? .black : .B1
            
            numOfPeople.isEnabled = isEditting ? true : false
            
            numOfPeople.textColor = isEditting ? .black : .B1
            
            note.isEditable = isEditting ? true : false
            
            note.textColor = isEditting ? .black : .B1
            
            travelDate.isHidden = isEditting ? true : false
            
            travelTime.isHidden = isEditting ? true : false
            
            timeLabel.isHidden = isEditting ? true : false
            
            travelTimePicker.isHidden = isEditting ? false : true
            
            trailName.backgroundColor = isEditting ? UIColor.systemGray6 : UIColor.clear
            
            numOfPeople.backgroundColor = isEditting ? UIColor.systemGray6 : UIColor.clear
            
            note.backgroundColor = isEditting ? UIColor.systemGray6 : UIColor.clear
            
            if isEditting {
                
                numOfPeople.text = groupInfo?.upperLimit.description
                
                travelTimePicker.date = groupInfo?.date.dateValue() ?? Date()
                
            } else {

                let pickTime = Timestamp(date: travelTimePicker.date)

                groupInfo?.date = pickTime
                
                guard let groupInfo = groupInfo else {
                    return
                }

                travelDate.text = TimeFormater.dateStyle.timestampToString(time: groupInfo.date)
                
                travelTime.text = TimeFormater.timeStyle.timestampToString(time: groupInfo.date)
                
                note.text =  groupInfo.note
                
                let upperLimit = groupInfo.upperLimit
                
                let counts = groupInfo.userIds.count
                
                numOfPeople.text = "\(counts) / \(upperLimit)"
                
            }
        }
    }
    
    func setUpCell(group: Group, cache: UserInfo, userStatus: GroupStatus) {
        
        self.groupInfo = group
        
        guard let groupInfo = groupInfo else { return }
        
        travelDate.text = TimeFormater.dateStyle.timestampToString(time: groupInfo.date)
        
        travelTime.text = TimeFormater.timeStyle.timestampToString(time: groupInfo.date)
        
        trailName.text = group.trailName
        
        let upperLimit = group.upperLimit
        
        let counts = group.userIds.count
        
        numOfPeople.text = "\(counts) / \(upperLimit)"
        
        hostName.text = cache.userName
        
        note.text = group.note
        
        if group.isExpired == true {
            
            requestButton.isHidden = true
        }
        
        switch userStatus {
            
        case .ishost:
            
            requestButton.setTitle("編輯資訊", for: .normal)
            
            hostBadgeButton.isHidden = false
            
        case .notInGroup:
            
            requestButton.setTitle("送出申請", for: .normal)
            
            guard counts != upperLimit else {
                
                requestButton.setTitle("人數已滿", for: .normal)
                
                requestButton.isEnabled = false
                
                return
            }
            
        case .isInGroup:
            
            requestButton.setTitle("退出隊伍", for: .normal)
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        selectionStyle = .none
        
        requestButton.titleLabel?.font = UIFont.regular(size: 14)
        
        setUpTextView()
        
        setUpTextField()
        
        trailName.isEnabled = false
        
        numOfPeople.isEnabled =  false
        
        note.isEditable = false
        
        travelDate.isHidden =  false
        
        travelTime.isHidden = false
        
        timeLabel.isHidden =  false
        
        travelTimePicker.isHidden = true
        
        hostBadgeButton.isHidden = true
    }
    
    func setUpTextView() {
        
        note.backgroundColor = .white
        
        note.textAlignment = .left
        
        note.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        note.font = UIFont.regular(size: 14)
        
        note.clipsToBounds = true
        
        note.layer.cornerRadius = 10
        
        note.textContainer.maximumNumberOfLines = 3
        
        note.textContainer.lineBreakMode = .byWordWrapping
    }
    
    func setUpTextField() {
        
        trailName.setLeftPaddingPoints(8)
        
        trailName.layer.cornerRadius = 10
        
        trailName.clipsToBounds = true
        
        numOfPeople.setLeftPaddingPoints(8)
        
        numOfPeople.layer.cornerRadius = 10
        
        numOfPeople.clipsToBounds = true
    }
}

extension GroupChatHeaderCell: UITextFieldDelegate, UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        guard let text = textView.text,
              !text.isEmpty else {
                  return
              }
        
        note.text = text
        
        groupInfo?.note = text
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let text = textField.text,
              !text.isEmpty else {
                  return
              }
        
        switch textField {
            
        case trailName:
            
            trailName.text = text
            
            groupInfo?.trailName = text
            
        case numOfPeople:
            
            numOfPeople.text = text
            
            groupInfo?.upperLimit = Int(text) ?? 1
            
        default:
            
            return
        }
    }
}
