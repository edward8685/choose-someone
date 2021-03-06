//
//  TrackRecordsViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/30.
//

import UIKit

class TrackRecordsViewController: BaseViewController {
    
    // MARK: - Class Properties -
    
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
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRecords()
        
        setUpTableView()
        
        setNavigationBar(title: "我的紀錄")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Methods -
    
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
    
    // MARK: - UI Settings -
    
    func setUpTableView() {
        
        tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.registerCellWithNib(identifier: TrackRecordCell.identifier, bundle: nil)
        
        view.stickSubView(tableView)
        
        tableView.backgroundColor = .clear
        
        tableView.separatorStyle = .none
    }
}

// MARK: - TableView Delegate -

extension TrackRecordsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
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
        
        performSegue(withIdentifier: SegueIdentifier.userRecord.rawValue, sender: records[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.userRecord.rawValue {
            if let recordVC = segue.destination as? UserRecordViewController {
                
                if let record = sender as? Record {
                    recordVC.record = record
                }
            }
        }
    }
}

// MARK: - TableView DataSource -

extension TrackRecordsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: TrackRecordCell = tableView.dequeueCell(for: indexPath)
        
        cell.setUpCell(model: self.records[indexPath.row])
        
        return cell
    }
}
