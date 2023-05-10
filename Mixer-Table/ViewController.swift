//
//  ViewController.swift
//  Mixer-Table
//
//  Created by Sergei Semko on 5/10/23.
//

import Foundation
import UIKit

enum Section: Hashable {
    case numbers
}

struct SectionData {
    var key: Section
    var values: [Int]
}

struct CellData: Hashable {
    let title: Int
    var isMarked: Bool = false
}

typealias Data = [CellData]

class ViewController: UIViewController {
    
    private let cellIdentifier = "cell"
    
    private var data = Data()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGray6
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        return tableView
    }()
    
    private lazy var dataSource: UITableViewDiffableDataSource<Section, CellData> = {
        UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
            var configuration = cell.defaultContentConfiguration()
            configuration.text = String(itemIdentifier.title)
            cell.accessoryType = self.data[indexPath.row].isMarked ? .checkmark : .none
            cell.contentConfiguration = configuration
            return cell
        }
    }()
    
    private lazy var shuffleButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "Shuffle"
        button.style = .plain
        button.target = self
        button.action = #selector(shuffleButtonTapped)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createData()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadTable(animated: true)
    }
    
    private func createData() {
        for i in 1...50 {
            data.append(CellData(title: i))
        }
    }
    
    private func setupView() {
        view.backgroundColor = .systemGray6
        title = "Mixer-Table"
        navigationItem.rightBarButtonItem = shuffleButton
        setConstraints()
    }
    
    private func reloadTable(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellData>()
        snapshot.appendSections([.numbers])
        snapshot.appendItems(data, toSection: .numbers)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    @objc private func shuffleButtonTapped() {
        data.shuffle()
        reloadTable(animated: true)
    }
    
}

private extension ViewController {
    func setConstraints() {
        view.addSubview(tableView)
        
        let constraints: [NSLayoutConstraint] = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}


extension ViewController: UITableViewDelegate {
    private func moveRow(index: IndexPath) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellData>()
        snapshot.appendSections([.numbers])
        snapshot.appendItems(data, toSection: .numbers)
        let itemFirst = snapshot.itemIdentifiers[0]
        let indexCurrent = snapshot.itemIdentifiers[index.row]
        if index.row != 0 {
            snapshot.moveItem(indexCurrent, beforeItem: itemFirst)
            let item = data[index.row]
            data.remove(at: index.row)
            data.insert(item, at: 0)
        }
        UIView.animate(withDuration: 0.5) {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let sectionIndex = dataSource.sectionIdentifier(for: indexPath.section) else {
            return
        }
        
        dataSource.defaultRowAnimation = .fade
        if sectionIndex == .numbers {
            data[indexPath.row].isMarked.toggle()
            if data[indexPath.row].isMarked {
                moveRow(index: indexPath)
            } else {
                reloadTable(animated: false)
            }

        }
    }
}
