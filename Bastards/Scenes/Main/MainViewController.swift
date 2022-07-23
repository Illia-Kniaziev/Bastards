//
//  MainViewController.swift
//  Bastards
//
//  Created by Illia Kniaziev on 22.07.2022.
//

import Combine
import UIKit

final class MainViewController: ViewController {

    //MARK: - outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyMessageLabel: UILabel!
    
    //MARK: - private properties
    private let viewModel: MainViewModel
    private var subscriptions = Set<AnyCancellable>()
    private lazy var dataSource = prepareDataSource()
    
    //MARK: - init
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("use init(viewModel:) instead")
    }
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchModels()
    }
    
    override func configureUI() {
        activityIndicator.isHidden = true
        emptyMessageLabel.isHidden = true
        
        tableView.dataSource = dataSource
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        title = "Bastards"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func bindViewModel() {
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case .ongoing:
                    self?.activityIndicator.isHidden = false
                    self?.activityIndicator.startAnimating()
                case .failed:
                    self?.emptyMessageLabel.isHidden = false
                    fallthrough
                default:
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.isHidden = true
                }
            }
            .store(in: &subscriptions)
            
        
        viewModel.$losses
            .receive(on: RunLoop.main)
            .sink { [weak self] losses in
                var snapshot = NSDiffableDataSourceSnapshot<Int, DayLosses>()
                snapshot.appendSections([0])
                snapshot.appendItems(losses, toSection: 0)
                self?.dataSource.apply(snapshot)
            }
            .store(in: &subscriptions)
        
    }
    
    private func prepareDataSource() -> UITableViewDiffableDataSource<Int, DayLosses> {
        return UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, losses in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            var config = UIListContentConfiguration.subtitleCell()
            config.text = "day #\(losses.day)"
            if let greatestLosses = losses.equipment.greatestLossesDirection {
                config.secondaryText = greatestLosses + "🔥"
            }
            cell?.contentConfiguration = config
            cell?.accessoryType = .disclosureIndicator
            return cell
        }
    }

}
