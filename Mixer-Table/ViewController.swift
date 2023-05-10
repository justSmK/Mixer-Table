//
//  ViewController.swift
//  Mixer-Table
//
//  Created by Sergei Semko on 5/10/23.
//

import Foundation
import UIKit

enum Section: Hashable {
    case first
}

struct Detail: Hashable {
    var title: Int
    var checkMark: Bool
    var index: Int
}

typealias Details = [Detail]

class ViewController: UIViewController {
    
    var details = Details()
    var dataSource: UITableViewDiffableDataSource<Section, Detail>?
    
    private lazy var shuffleButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "Shuffle"
        button.target = self
        button.action = #selector(buttonDidTapped)
        return button
    }()
    
    private lazy var table: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemGray6
        table.translatesAutoresizingMaskIntoConstraints = false
        table.layer.cornerRadius = 10
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        title = "Mixer-Table"
        navigationItem.rightBarButtonItem = shuffleButton
        view.addSubview(table)
        setConstraints()
        
        for i in 0...32 {
            details.append(Detail(title: i, checkMark: false, index: 1))
        }
        details.sort { $0.index < $1.index }
        table.delegate = self
        createDataSource()
        reloadData()
    }

    @objc private func buttonDidTapped() {
        self.details.shuffle()
        dataSource?.defaultRowAnimation = .automatic
        reloadData()
    }

    
    private func createDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Detail>(
            tableView: table,
            cellProvider: { tableView, indexPath, itemIdentifier in
                var cell: UITableViewCell
                
                if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "cell") {
                    cell = reuseCell
                } else {
                    cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
                }
                
                var configuration = cell.defaultContentConfiguration()
                configuration.text = String(itemIdentifier.title)
                cell.contentConfiguration = configuration
                if itemIdentifier.checkMark == true {
                    cell.accessoryView = UIImageView(image: UIImage(systemName: "checkmark"))
                } else {
                    cell.accessoryView = nil
                }
                
                return cell
        })
    }
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Detail>()
        snapshot.appendSections([.first])
        snapshot.appendItems(details, toSection: .first)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func moveRowUp(index: IndexPath) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Detail>()
        snapshot.appendSections([.first])
        snapshot.appendItems(details, toSection: .first)
        
        let itemFirst = snapshot.itemIdentifiers[0]
        let indexCurrent = snapshot.itemIdentifiers[index.row]
        if index.row != 0 {
            snapshot.moveItem(indexCurrent, beforeItem: itemFirst)
            
            if index.row != 0 {
                let item = details[index.row]
                details.remove(at: index.row)
                details.insert(item, at: 0)
            }
            
            UIView.animate(withDuration: 0.5) {
                self.dataSource?.apply(snapshot, animatingDifferences: true)
            }
            
        }
    }
    
    
    private func addCheckMark(index: IndexPath) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Detail>()
        snapshot.appendSections([.first])
        if self.details[index.row].checkMark == false {
            self.details[index.row].checkMark = true
        } else {
            self.details[index.row].checkMark = false
        }
        
        snapshot.appendItems(details, toSection: .first)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
}


extension ViewController {
    private func setConstraints() {
        let constraints: [NSLayoutConstraint] = [
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        addCheckMark(index: indexPath)
        if let item = dataSource?.itemIdentifier(for: indexPath) {
            if item.checkMark == true {
                moveRowUp(index: indexPath)
            } else {
                reloadData()
            }
        }
    }
}
