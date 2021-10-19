//
//  JoinRequestViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/19.
//

import UIKit

class JoinRequestViewController: UIViewController {
    
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
        
        view.stickSubView(tableView)
        
        tableView.backgroundColor = .clear
        
    }
}

extension JoinRequestViewController: UITableViewDelegate {
    
}

extension JoinRequestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: JoinRequestCell.identifier, for: indexPath) as? JoinRequestCell
                
        else {fatalError("Could not create Cell")}
        
        return cell
    }
}

