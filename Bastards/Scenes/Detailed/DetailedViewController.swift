//
//  DetailedViewController.swift
//  Bastards
//
//  Created by Illia Kniaziev on 23.07.2022.
//

import Combine
import UIKit

final class DetailedViewController: ViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel: DetailedViewModel
    private var subscriptions = Set<AnyCancellable>()
    private lazy var dataSource = prepareDataSource()
    
    //MARK: - init
    init(viewModel: DetailedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("use init(viewModel:) instead")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.createLossModels()
    }
    
    override func configureUI() {
        title = viewModel.dayInfo.dateString
        tableView.dataSource = dataSource
        tableView.register(UINib(nibName: "LossCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    override func bindViewModel() {
        viewModel.$lossModels
            .receive(on: RunLoop.main)
            .sink { [weak self] lossModels in
                var snapshot = NSDiffableDataSourceSnapshot<Int, LossModel>()
                snapshot.appendSections([0])
                snapshot.appendItems(lossModels, toSection: 0)
                self?.dataSource.apply(snapshot)
            }
            .store(in: &subscriptions)
    }
    
    private func prepareDataSource() -> UITableViewDiffableDataSource<Int, LossModel> {
        return UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, loss in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LossCell
            cell.configureWith(icon: loss.emoji, title: loss.title, amount: loss.amount)
            return cell
        }
    }

}
