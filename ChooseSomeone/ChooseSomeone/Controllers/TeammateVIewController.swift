//
//  TeammateController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/9.
//

import UIKit

class TeammateViewController: UIViewController {
    
    var groupInfo: Group?
    
    private var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        
        tableView.registerCellWithNib(identifier: JoinRequestCell.identifier, bundle: nil)
        
        setNavigationBar()
        
        view.stickSubView(tableView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden = false
        
    }
    
    // MARK: - Action
    
    func setNavigationBar() {
        
        self.title = "\(groupInfo?.groupName ?? "揪團成員") - 成員"
        
        UINavigationBar.appearance().backgroundColor = .B1
        
        UINavigationBar.appearance().barTintColor = .B1
        
        UINavigationBar.appearance().isTranslucent = true
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                            NSAttributedString.Key.font: UIFont.medium(size: 22) ?? UIFont.systemFont(ofSize: 22)]
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let button = UIButton()
        
        button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
     
        let image = UIImage(systemName: "chevron.left")
        
        button.setImage(image, for: .normal)
        
        button.layer.cornerRadius = button.frame.height / 2
        
        button.layer.masksToBounds = true
        
        button.tintColor = .B1
        
        button.backgroundColor = .white
        
        button.addTarget(self, action: #selector(backToPreviousVC), for: .touchUpInside)
        
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: button), animated: true)
        
    }
    
    @objc func backToPreviousVC() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension TeammateViewController: UITableViewDelegate {
    
}

extension TeammateViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let num =  groupInfo?.userIds.count else { fatalError() }
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: JoinRequestCell.identifier, for: indexPath) as? JoinRequestCell
                
        else {fatalError("Could not create Cell")}
        
        if let group = groupInfo {
        cell.setUpCell(group: group, indexPath: indexPath)
        
        cell.acceptButton.tag = indexPath.row
        
        cell.rejectButton.addTarget(self, action: #selector(blockUser), for: .touchUpInside)
        
        cell.rejectButton.tag = indexPath.row
        }
        
        return cell
    }
    
    @objc func blockUser (_ sender: UIButton) {
        
        if let blockUserId = groupInfo?.userIds[sender.tag]  {
  
        UserManager.shared.blockUser(blockUserId: blockUserId )
            
        }
    }
    
}

