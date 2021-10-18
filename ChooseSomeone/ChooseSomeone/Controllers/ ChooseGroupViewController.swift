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
        
        view.stickSubView(tableView)
        
        tableView.lk_registerCellWithNib(identifier: GroupInfoCell.identifier, bundle: nil)
        tableView.lk_registerCellWithNib(identifier: GroupHeaderCell.identifier, bundle: nil)
    }
}


extension ChooseGroupViewController: UITableViewDelegate {
    
    //HeaderView
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = Bundle.main.loadNibNamed(GroupHeaderCell.identifier, owner: self, options: nil)?.first as? GroupHeaderCell
        else {fatalError("Could not create HeaderView")}
        
        return headerView
    }
    
    //Cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
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
