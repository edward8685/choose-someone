//
//  TrackRecordsViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/30.
//

import UIKit

class TrackRecordsViewController: BaseViewController {
    
    @IBOutlet weak var gradientView: UIView! {
        didSet {
            gradientView.applyGradient(
                colors: [.B2, .C4],
                locations: [0.0, 1.0], direction: .leftSkewed)
            gradientView.alpha = 0.85
        }
    }
    
    var records = [Record]()
    
    private var tableView: UITableView! {
        
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchRecords()
        
        setUpTableView()
        
        setNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden = false
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setNavigationBar() {
        
        self.title = "我的紀錄"
        
        UINavigationBar.appearance().backgroundColor = .B1
        
        UINavigationBar.appearance().barTintColor = .B1
        
        UINavigationBar.appearance().isTranslucent = true
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                            NSAttributedString.Key.font: UIFont.medium(size: 22) ?? UIFont.systemFont(ofSize: 22)]
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let leftButton = PreviousPageButton()
        
        leftButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let image = UIImage(systemName: "chevron.left")
        
        leftButton.setImage(image, for: .normal)
        
        leftButton.addTarget(self, action: #selector(popToPreviousPage), for: .touchUpInside)
        
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: leftButton), animated: true)
    }
    
    func setUpTableView() {
        
        tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.registerCellWithNib(identifier: TrackRecordCell.identifier, bundle: nil)
        
        view.stickSubView(tableView)
        
        tableView.backgroundColor = .clear
        
        tableView.separatorStyle = .none
    }
    
    func fetchRecords() {
        RecordManager.shared.fetchRecords { [weak self] result in
            
            switch result {
                
            case .success(let records):
                
                self?.records = records
                
                self?.tableView.reloadData()
                
            case .failure(let error):
                
                print("fetchData.failure: \(error)")
            }
        }
    }
}

extension TrackRecordsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            RecordManager.shared.deleteStorageRecords(fileName: records[indexPath.row].recordName) { result in
                switch result {
                    
                case .success(_):
                    
                    self.records.remove(at: indexPath.row)
                    
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    
                case .failure(let error):
                    
                    print("delete failure \(error)")
                    
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "toUserRecord", sender: records[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserRecord" {
            if let recordVC = segue.destination as? UserRecordViewController {
                
                if let record = sender as? Record {
                    recordVC.record = record
                }
            }
        }
    }
}

extension TrackRecordsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackRecordCell.identifier, for: indexPath) as? TrackRecordCell else {
            fatalError("Cannot create new cell")
        }
        
        cell.setUpCell(model: self.records[indexPath.row])
        
        return cell
    }
}
