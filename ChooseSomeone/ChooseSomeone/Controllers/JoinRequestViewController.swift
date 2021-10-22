//
//  JoinRequestViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/19.
//

import UIKit

class JoinRequestViewController: UIViewController {
    
    private var requests = [Request]() {
        didSet{
            tableView.reloadData()
        }
    }
    
    private var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        
        tableView.lk_registerCellWithNib(identifier: JoinRequestCell.identifier, bundle: nil)
        
        setUpTableView()
        
        tableView.backgroundColor = .clear
        
        addRequestListener()
        
        setUpButton()
        
    }
    
    func addRequestListener() {
        GroupRoomManager.shared.fetchRequest { [weak self] result in
            
            switch result {
                
            case .success(let requests):
                self?.requests = requests
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
    
    func setUpTableView() {
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setUpButton() {
        
        let dismissButton = UIButton()
        
        dismissButton.frame = CGRect(x: UIScreen.width - 40, y: 40 , width: 20, height: 20)
        dismissButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        dismissButton.backgroundColor = UIColor.hexStringToUIColor(hex: "64696F")
        let image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .light))
        dismissButton.setImage(image, for: .normal)
        dismissButton.tintColor = .white
        dismissButton.layer.cornerRadius = 10
        dismissButton.layer.masksToBounds = true
        
        dismissButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        view.addSubview(dismissButton)
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
}

extension JoinRequestViewController: UITableViewDelegate {
    
}

extension JoinRequestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: JoinRequestCell.identifier, for: indexPath) as? JoinRequestCell
                
        else {fatalError("Could not create Cell")}
        
        cell.setUpCell(requests: requests, indexPath: indexPath)
        
        cell.acceptButton.addTarget(self, action: #selector(acceptRequest), for: .touchUpInside)
        
        cell.acceptButton.tag = indexPath.row
        
        cell.rejectButton.addTarget(self, action: #selector(rejectRequest), for: .touchUpInside)
        
        cell.rejectButton.tag = indexPath.row
        
        return cell
    }
    
    @objc func acceptRequest(_ sender: UIButton) {
        print(requests[sender.tag].groupId)
        
        GroupRoomManager.shared.addUserToGroup(
            groupId: requests[sender.tag].groupId,
            userId: requests[sender.tag].requestId
        ) { result in
            switch result {
                
            case .success:
                
                print("add user to group succesfully")
                
            case .failure(let error):
                
                print("add user to group failure: \(error)")
            }
        }
        
        GroupRoomManager.shared.removeRequest(
            groupId: requests[sender.tag].groupId,
            userId: requests[sender.tag].requestId
        ) { result in
            switch result {
                
            case .success:
                
                print("accept succesfully")
                
            case .failure(let error):
                
                print("accept failure: \(error)")
                
            }
        }
    }
    
    @objc func rejectRequest(_ sender: UIButton) {
        print(requests[sender.tag].groupId)
        GroupRoomManager.shared.removeRequest(
            groupId: requests[sender.tag].groupId,
            userId: requests[sender.tag].requestId
        ) { result in
            switch result {
                
            case .success:
                
                print("accept succesfully")
                
            case .failure(let error):
                
                print("accept failure: \(error)")
            }
        }
    }
    
}

