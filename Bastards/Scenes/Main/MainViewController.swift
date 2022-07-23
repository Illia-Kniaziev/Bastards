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
    
    private lazy var milestoneHeaderView: MilestoneView = {
        return Bundle.main.loadNibNamed("MilestoneView", owner: nil)?.first as! MilestoneView
    }()
    
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
        
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.register(UINib(nibName: DayInfoCell.identifier, bundle: nil), forCellReuseIdentifier: DayInfoCell.identifier)
        
        title = "The war"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        configureMenu(withSelectedStrategy: .descending)
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
            
        
        viewModel.$lossesInfo
            .receive(on: RunLoop.main)
            .sink { [weak self] lossesInfo in
                var snapshot = NSDiffableDataSourceSnapshot<Int, DayInfo>()
                snapshot.appendSections([0])
                snapshot.appendItems(lossesInfo, toSection: 0)
                self?.dataSource.apply(snapshot)
            }
            .store(in: &subscriptions)
        
        viewModel.$currentLoss
            .receive(on: RunLoop.main)
            .sink { [weak self] amount in
                guard let self = self else { return }
                self.milestoneHeaderView.currentAmountLabel.text = "There are \(amount) good russians"
            }
            .store(in: &subscriptions)
        
        viewModel.$lossBounds
            .receive(on: RunLoop.main)
            .sink { [weak self] bounds in
                guard let self = self, let bounds = bounds else { return }
                self.milestoneHeaderView.lowerBoundLabel.text = "\(bounds.0)"
                self.milestoneHeaderView.upperBoundLabel.text = "\(bounds.1)"
            }
            .store(in: &subscriptions)
        
        viewModel.$progress
            .receive(on: RunLoop.main)
            .sink { [weak self] progress in
                guard let self = self else { return }
                self.milestoneHeaderView.progressBar.progress = progress
            }
            .store(in: &subscriptions)
        
    }
    
    //MARK: - data source configuration
    private func prepareDataSource() -> UITableViewDiffableDataSource<Int, DayInfo> {
        return UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, lossesInfo in
            let cell = tableView.dequeueReusableCell(withIdentifier: DayInfoCell.identifier, for: indexPath) as! DayInfoCell
            cell.configure(withModel: lossesInfo)
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }

    //MARK: - menu
    private func configureMenu(withSelectedStrategy strategy: MainViewModel.SortingStrategy) {
        let actions = generateMenu(withSelectedStrategy: strategy)
        let menu = UIMenu(title: "Order", image: nil, identifier: nil, options: [], children: actions)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Order", image: nil, primaryAction: nil, menu: menu)
    }
    
    private func generateMenu(withSelectedStrategy strategy: MainViewModel.SortingStrategy) -> [UIAction] {
        return [
            UIAction(title: "Ascending", image: nil, state: strategy == .ascending ? .on : .off) { [weak self] _ in
                self?.viewModel.sort(usingStrategy: .ascending)
                self?.configureMenu(withSelectedStrategy: .ascending)
            },
            UIAction(title: "Descending", image: nil, state: strategy == .descending ? .on : .off) { [weak self] _ in
                self?.viewModel.sort(usingStrategy: .descending)
                self?.configureMenu(withSelectedStrategy: .descending)
            },
            UIAction(title: "Top eliminations", image: nil, state: strategy == .topEliminated ? .on : .off) { [weak self] _ in
                self?.viewModel.sort(usingStrategy: .topEliminated)
                self?.configureMenu(withSelectedStrategy: .topEliminated)
            }
        ]
    }
}

//MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        milestoneHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.openDetails(forIndex: indexPath.row)
    }
    
}
