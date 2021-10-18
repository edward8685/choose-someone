//
//  ViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit

class ChooseGroupViewController: UIViewController {
    
    private var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        
        tableView.lk_registerCellWithNib(identifier: GroupInfoCell.identifier, bundle: nil)
        
        tableView.lk_registerCellWithNib(identifier: GroupHeaderCell.identifier, bundle: nil)
        
        setUpHeaderView()
        
        setUpTableView()
        
        setUpButton()
        
        navigationController?.isNavigationBarHidden = true
        
    }
    
    func setUpTableView() {
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 120),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setUpHeaderView() {
        
        guard let headerView = Bundle.main.loadNibNamed(GroupHeaderCell.identifier, owner: self, options: nil)?.first as? GroupHeaderCell
        else {fatalError("Could not create HeaderView")}
        
        view.addSubview(headerView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            headerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            
            headerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            headerView.heightAnchor.constraint(equalToConstant: 120)
            
//            headerView.bottomAnchor.constraint(equal)
        ])
    }
    
    
}

extension ChooseGroupViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toGroupChatVC", sender: nil)
    }
}

extension ChooseGroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupInfoCell.identifier, for: indexPath) as? GroupInfoCell
                
        else {fatalError("Could not create Cell")}
        
        return cell
    }
}
