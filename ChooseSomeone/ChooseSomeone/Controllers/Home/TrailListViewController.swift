//
//  TrailListViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/24.
//

import UIKit

class TrailListViewController: BaseViewController {
    
    // MARK: - DataSource & DataSourceSnapshot typelias -
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Trail>
    
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Trail>
    
    // MARK: - Class Properties -
    
    enum Section {
        
        case section
    }

    private var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.delegate = self
        }
    }
    
    private var themeLabel = ""
    
    private var dataSource: DataSource!
    
    private var snapshot = DataSourceSnapshot()

    var trails = [Trail]() {
        
        didSet {
            
            setUpLabel()
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupCollectionView()
        
        configureDataSource()
        
        configureSnapshot()
        
        setUpButton()
        
        setUpThemeTag()
        
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - UI Settings -
    
    private func setupCollectionView() {
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        
        collectionView.registerCellWithNib(reuseIdentifier: TrailCell.reuseIdentifier, bundle: nil)
        
        view.stickSubView(collectionView)
        
        collectionView.backgroundColor = .clear
    }
    
    func setUpButton() {
        
        let radius = UIScreen.width * 13 / 107
        
        let button = PreviousPageButton(frame: CGRect(x: 40, y: 40, width: radius, height: radius))
        
        button.addTarget(self, action: #selector(popToPreviousPage), for: .touchUpInside)
        
        view.addSubview(button)
    }
    
    func setUpLabel() {
        
        if let label = trails.first?.trailLevel {
            
            switch label {
                
            case 1:
                
                themeLabel = TrailThemes.easy.rawValue
                
            case 2...3:
                
                themeLabel = TrailThemes.medium.rawValue
                
            case 4...5:
                
                themeLabel = TrailThemes.hard.rawValue
                
            default:
                return
            }
        }
    }
    
    func setUpThemeTag() {
        
        let view = UIView(frame: CGRect(x: -20, y: 80, width: UIScreen.width / 2 + 10, height: 40))
        
        let label = UILabel(frame: CGRect(x: 20, y: 83, width: 120, height: 35))
        
        view.backgroundColor = .U2
        
        view.layer.cornerRadius = 20
        
        view.layer.masksToBounds = true
        
        label.text = themeLabel
        
        label.textColor = .black
        
        label.textAlignment = .center
        
        label.font = UIFont.regular(size: 18)
        
        collectionView.addSubview(view)
        
        collectionView.addSubview(label)
    }
}

// MARK: - CollectionView Delegate -

extension TrailListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "toTrailInfo", sender: trails[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toTrailInfo" {
            
            if let trailInfoVC = segue.destination as? TrailInfoViewController {
                
                if let trail = sender as? Trail {
                    
                    trailInfoVC.trail = trail
                }
            }
        }
    }
}

// MARK: - CollectionView CompositionalLayout -

func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    
    return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
        
        let inset = 5
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //        item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        //        
        let height: CGFloat = 300
        
        let groupLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(450))
        
        let group = NSCollectionLayoutGroup.custom(layoutSize: groupLayoutSize) { (env) -> [NSCollectionLayoutGroupCustomItem] in
            
            let size = env.container.contentSize
            
            let spacing: CGFloat = 10.0
            
            let itemWidth = (size.width-spacing * 3) / 2
            
            return [
                
                NSCollectionLayoutGroupCustomItem(frame: CGRect(x: (itemWidth+spacing * 2), y: 0, width: itemWidth, height: height * 0.9)),
                
                NSCollectionLayoutGroupCustomItem(frame: CGRect(x: spacing, y: height / 2, width: itemWidth, height: height * 0.9))
            ]
        }
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = -150
        
        return section
    }
    
}

// MARK: - CollectionView Diffable Data Source -

extension TrailListViewController {
    
    func configureDataSource() {
        
        dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, model) -> UICollectionViewCell? in
            
            let cell: TrailCell = collectionView.dequeueCell(for: indexPath)
            
            cell.setUpCell(model: model)
            
            cell.checkGroupButton.tag = indexPath.row
            
            cell.checkGroupButton.addTarget(self, action: #selector(self.toGroupPage), for: .touchUpInside)
            
            return cell
        })
    }
    
    @objc func toGroupPage(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 1
        
        NotificationCenter.default.post(
            name: NSNotification.checkGroupDidTaped,
            object: nil,
            userInfo: ["trailName": self.trails[sender.tag].trailName] )
    }
    
    func configureSnapshot() {
        
        snapshot.appendSections([.section])
        
        snapshot.appendItems(trails, toSection: .section)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
