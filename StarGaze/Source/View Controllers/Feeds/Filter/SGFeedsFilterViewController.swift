//
//  SGFeedsFilterViewController.swift
//  StarGaze
//
//  Created by Suraj Shetty on 27/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import Combine

class SGFeedsFilterViewController: UIViewController {

    @IBOutlet weak var contentView: SGRoundedView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var tableView: SGTableView!
    
    @IBOutlet weak var filterTabView: UIStackView!
    
    var datasource = [SGFilterHeaderViewModel]()
    
    var callback:(([SGFilterHeaderViewModel])-> ())?
    var dismiss:(()->())?
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        for cancellable in cancellables {
            cancellable.cancel()
        }
        cancellables.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupTableView()
        setupDatasource()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func reset(_ sender: Any) {
        for header in datasource {
            let hasRows = !header.rows.isEmpty
            if hasRows {
                for row in header.rows {
                    row.didSelect = false
                }
            }
            else {
                header.showDetails = false
            }
        }
        
        tableView.reloadData()
    }
    
    @IBAction func applyfilter(_ sender: Any) {
        callback?(datasource)
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss?()
    }
}

private extension SGFeedsFilterViewController {
    func setupDatasource() {
//        datasource = SGFilterHeaderViewModel.mockData()
        
        for section in datasource {
            section.$showDetails
                .sink {[unowned self] showDetail in
                    guard let sectionIndex = self.datasource.firstIndex(of: section)
                    else { return }
                    
                    let section = self.datasource[sectionIndex]
                    let indexPaths = (0..<section.rows.count).map({ return IndexPath(row: $0, section: sectionIndex)})
                    
                    if indexPaths.isEmpty == false {
                        self.tableView.beginUpdates()
                        
                        if showDetail {
                            self.tableView.insertRows(at: indexPaths, with: .automatic)
                        }
                        else {
                            self.tableView.deleteRows(at: indexPaths, with: .automatic)
                        }
                        
                        self.tableView.endUpdates()
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    func setupTableView() {
        tableView.rowHeight = 58
        tableView.sectionHeaderHeight = 34
        tableView.sectionFooterHeight = 26
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.contentInset = UIEdgeInsets(top: tableHeaderView.frame.height,
                                              left: 0, bottom: 0, right: 0)
        
        tableView.register(UINib(nibName: "SGFilterTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "Row")
        tableView.register(UINib(nibName: "SGFilterSectionHeaderView", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "Header")
    }
}

extension SGFeedsFilterViewController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = datasource[section]
        return section.showDetails ? section.rows.count : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header") as! SGFilterSectionHeaderView
        headerView.viewModel = datasource[section]
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Row", for: indexPath) as! SGFilterTableViewCell
        cell.viewModel = (datasource[indexPath.section]).rows[indexPath.row]
        return cell
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderPostion()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateHeaderPostion()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            updateHeaderPostion()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateHeaderPostion()
    }
}

private extension SGFeedsFilterViewController {
    func updateHeaderPostion() {
        let offset = tableView.contentOffset.y + tableHeaderView.frame.height
        tableHeaderView.transform = .init(translationX: 0, y: -offset)
    }
}
