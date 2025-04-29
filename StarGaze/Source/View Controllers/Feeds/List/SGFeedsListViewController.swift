//
//  SGFeedsListViewController.swift
//  StarGaze
//
//  Created by Suraj Shetty on 17/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import SkeletonView
import RxSwift
import Combine
import SwiftUI
import Kingfisher

class SGFeedsListViewController: UIViewController {
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableView: SGTableView!

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var createPostView: SGRoundedView!
    @IBOutlet weak var segmentControl: SGSegmentedControl!
    
    private var viewModels = [SGFeedCategory:SGFeedListViewModel]()
    private var currentCategory = SGFeedCategory.generic
    private var viewModel:SGFeedListViewModel {
        get { viewModels[currentCategory]!}
    }
    
    private var filters = [SGFilter]()
    private var pickedFilters:[SGFilter]?
    
    private var showSkeleton:Bool = true
    private weak var playingViewModel:SGFeedViewModel?
    private let disposeBag = DisposeBag()
    
    private let navigationRouter = SGFeedsRouter()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupDataSource()
        setupTableHeader()
        setupTableView()
        setupBinding()
        setupRefreshControl()
        setupNotifications()
        DispatchQueue.main.async {[weak self] in
            self?.getFeeds(refresh: true)
            self?.getFilter()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.isSkeletonable = true
//        showLoadingIfNecessary()
        
        if viewModel.feeds.isEmpty == false {
            playVisibleVideoCell()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseVideoCells()
    }
    

    deinit {
        NotificationCenter.default.removeObserver(self)
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

private extension SGFeedsListViewController {
    func showLoadingIfNecessary() {
        if viewModel.feeds.isEmpty {
            let gradient = SkeletonGradient(baseColor: .white.withAlphaComponent(0.4))
            view.showAnimatedGradientSkeleton(usingGradient: gradient,
                                              transition: .crossDissolve(0.5))
            
        }
        else {
            view.hideSkeleton()
        }
    }
    
    @objc func triggerRefresh() {
        getFeeds(refresh: true)
    }
    
    func onNewFeeds() {
        if let refreshControl = tableView.refreshControl {
            refreshControl.beginRefreshing()
            
            let offsetPoint = CGPoint.init(x: 0, y: -refreshControl.frame.height)
            tableView.setContentOffset(offsetPoint, animated: true)
        }
        
        getFeeds(refresh: true)
    }
}

private extension SGFeedsListViewController {
    func setupDataSource() {
        viewModels[.generic] = SGFeedListViewModel(type: .allFeedsList)
        viewModels[.exclusive] = SGFeedListViewModel(type: .allFeedsList)
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: "SGFeedsTableViewCell", bundle: nil), forCellReuseIdentifier: feedListCellIdentifier)
        tableView.register(UINib(nibName: "SGFeedListFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: feedListFooterIdentifier)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: feedListHeaderIdentifier)
        
        tableView.sectionFooterHeight = 40
        tableView.sectionHeaderHeight = 1
        
        tableView.dataSource = self
        tableView.delegate = self
//        tableView.isPrefetchingEnabled = true
        tableView.prepareForPlaceholder()
    }

    func setupTableHeader() {
        let canCreatePost = (SGAppSession.shared.user.value?.role == .celebrity)
        createPostView.isHidden = !canCreatePost
//        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let headerHeight = headerView.frame.height
        tableView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        
        segmentControl.segments = [SGSegmentItemViewModel(title: "Generic Feeds"),
                                   SGSegmentItemViewModel(title: "Exclusive")]
        segmentControl.rx
            .controlEvent(.valueChanged)
            .subscribe {[weak self] _ in
                self?.changeList()
            }
            .disposed(by: disposeBag)
        
        if canCreatePost {
            createPostView.rx.tapGesture()
                .when(.recognized)
                .subscribe {[weak self] _ in
                    self?.createPost()
                }
                .disposed(by: disposeBag)
        }
    }
    
    func setupBinding() {
        filterButton.publisher(for: .touchUpInside)
            .sink {[weak self] _ in
                guard let ref = self else { return }
                
                let filters = ref.filters.map { filter -> SGFilterHeaderViewModel in
                    let subFilters = filter.subFilters?.map({ SGFilterRowViewModel(filter: $0, didSelect: false) })
                    return SGFilterHeaderViewModel(filter: filter, rows: subFilters ?? [])
                }
                                                
                ref.navigationRouter.route(to: SGFeedsRouter.Route.filter.rawValue,
                                           from: ref,
                                           parameters: filters)
            }
            .store(in: &cancellables)
    }
    
    func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action: #selector(triggerRefresh),
                                 for: .valueChanged)
        
        tableView.refreshControl = refreshControl
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .feedPosted,
                                               object: nil,
                                               queue: .main) {[weak self] _ in
            self?.onNewFeeds()
        }
    }
}

private extension SGFeedsListViewController {
    func playVisibleVideoCell() {
        var visibleFrame = tableView.bounds
        visibleFrame.size.height -= headerView.frame.height//(tableView.contentInset.top + tableView.contentInset.bottom)
        visibleFrame.origin.y = (tableView.contentOffset.y + tableView.contentInset.top) //- headerView.frame.height
        
        let visibleCells = tableView.visibleCells
        
        guard visibleCells.isEmpty == false
        else { return }
        
        var tuples = [(CGFloat, SGFeedViewModel)]()
        for i in (0..<visibleCells.count) {
            guard let cell = visibleCells[i] as? SGFeedsTableViewCell,
                  let indexPath = tableView.indexPath(for: cell)
            else { continue }

            guard viewModel.feeds.count > indexPath.row
            else { return }
            
            let feedViewModel = viewModel.feeds[indexPath.row]
            guard feedViewModel.hasVideos else { continue } //Consider only video cell
            
            let playerFrame = cell.convert(cell.mediaContentView.frame, to: tableView)
            var height = CGFloat(0.0)
                
            if visibleFrame.contains(playerFrame) {
                height = playerFrame.height
            }
            else {
                if playerFrame.minY < visibleFrame.minY {
                    height = playerFrame.maxY - visibleFrame.minY
                }
                else if playerFrame.maxY > visibleFrame.maxY {
                    height = visibleFrame.maxY - playerFrame.minY
                }
            }
            tuples.append((height, feedViewModel))
        }
        
        if tuples.isEmpty { return }
        tuples.sort { lhs, rhs in
            return lhs.0 > rhs.0
        }
        
        let largestTupleIndex = tuples.firstIndex(where: { $0.0 > 0 })
        defer {
            for tuple in tuples { //Pause remaining video
                tuple.1.canPlay.accept(false)
            }
            tuples.removeAll()//Largest visible player should be played at this moment, clear any unrequired collection
        }
        
        guard let index = largestTupleIndex else { return }
        let largestTuple = tuples.remove(at: index) //Since sorting was done in descending order, safe to assume the first item is the largest
        largestTuple.1.canPlay.accept(true)
        playingViewModel = largestTuple.1
    }
    
    func pauseVideoCells() {
        guard let indexPaths = tableView.indexPathsForVisibleRows, indexPaths.isEmpty == false
        else { return }
                        
        for indexPath in indexPaths {
            if indexPath.row < viewModel.feeds.count {
                let feedViewModel = viewModel.feeds[indexPath.row]
                feedViewModel.canPlay.accept(false)
            }
        }
    }
    
    func changeList() {
        guard let pickedSegment = segmentControl.current, let index = segmentControl.segments.firstIndex(of: pickedSegment)
        else { return }
        
        let lastCategory =  currentCategory
        switch index {
        case 1: currentCategory = .exclusive
        default: currentCategory = .generic
        }
        
        if lastCategory != currentCategory {
            let viewModel = viewModels[lastCategory]
            viewModel?.pauseAllVideos()
        }
        tableView.reloadData()
        
        let currentRecords = viewModel.feeds
        if currentRecords.isEmpty == true {
            getFeeds(refresh: true)
        }
    }
    
    func createPost() {
        let vc = UIHostingController(rootView: SGCreateFeedView())
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

private extension SGFeedsListViewController {
    func getFeeds(refresh:Bool, filter:String? = nil) {
        if refresh == false, viewModel.endOfPage == true { //Already at the end of the page & no refresh requested
            return
        }
                
        let request = SGFeedRequest(pageToken: refresh ? nil : viewModel.currentToken,
                                    pageStart: 0,
                                    limit: 30,
                                    filters: nil,
//                                    category: currentCategory,
                                    userID: nil)
        let hadRecords = !viewModel.feeds.isEmpty
        
        if !hadRecords {
            tableView.showFeedLoader()
        }
        
        viewModel.getFeeds(with: request,
                           shouldRefresh: refresh) {[weak self] (didFetch, insertedIndexPaths, error) in
            SGAlertUtility.hidHUD()
            
            self?.tableView.refreshControl?.endRefreshing()
            
            if let error = error {
                SGAlertUtility.showErrorAlert(message: error.errorDescription)
                
                if self?.viewModel.feeds.isEmpty == true {
                    self?.tableView.showNoFeedPlaceholder()
                }
            }
            else if didFetch {
                if refresh {
                    self?.tableView.hidePlaceholder()
                    self?.tableView.reloadData()
                }
                else {
                    if let indexPaths = insertedIndexPaths, indexPaths.isEmpty == false {
                        if hadRecords {
                            self?.tableView.hidePlaceholder()
                            self?.tableView.beginUpdates()
                            self?.tableView.insertRows(at: indexPaths, with: .automatic)
                            self?.tableView.endUpdates()
                        }
                        else {
                            self?.tableView.hidePlaceholder()
                            self?.tableView.reloadData()
                        }
                    }
                    else {
                        if hadRecords == false {
                            self?.tableView.showNoFeedPlaceholder()
                        }
                        else {
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
            else {
                if hadRecords == false {
                    self?.tableView.showNoFeedPlaceholder()
                }
            }
        }
    }
    
    func getFilter() {
        SGFeedService.getFilters()
            .sink { result in
                switch result {
                case .failure(let error):
                    debugPrint("Failed to fetch filters")
                    break
                    
                case .finished: break
                }
                
            } receiveValue: {[weak self] filters in
                guard let ref = self else { return }
                ref.filters.removeAll()
                
                let activeFilters = filters.filter({ $0.status == .active }).sorted { lhs, rhs in
                    return lhs.id < rhs.id
                }
                
                let parentFilters = activeFilters.filter({ $0.parentID == nil })
                
                for index in 0..<parentFilters.count {
                    var filter = parentFilters[index]
                    let subFilters = activeFilters.filter({ $0.parentID == filter.id })
                    
                    filter.subFilters = subFilters
                    ref.filters.append(filter)
                }
            }
            .store(in: &cancellables)
    }
}

extension SGFeedsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.feeds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feedViewModel = viewModel.feeds[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: feedListCellIdentifier, for: indexPath) as! SGFeedsTableViewCell
        cell.viewModel = feedViewModel
        cell.actionCallback = {[weak self] (feedCell, action, object) in
            guard let ref = self else { return }
            
            guard let cell = feedCell, let indexPath = ref.tableView.indexPath(for: cell)
            else { return }
            
            let feedViewModel = ref.viewModel.feeds[indexPath.row]
            ref.handleAction(type: action, viewModel: feedViewModel)
        }

        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row < viewModel.feeds.count { //To avoid crash when switching the list
            let model = viewModel.feeds[indexPath.row]
            model.canPlay.accept(false)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let bgView = UIView()
        bgView.backgroundColor = .brand1
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: feedListHeaderIdentifier)
        headerView?.backgroundView = bgView
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: feedListFooterIdentifier) as? SGFeedListFooterView
        
        if viewModel.endOfPage {
            footerView?.titleLabel.text = NSLocalizedString("feed.list.page.end", comment: "")
        }
        else {
            footerView?.titleLabel.text = NSLocalizedString("feed.list.fetching", comment: "")
        }
        return footerView
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if viewModel.endOfPage || viewModel.currentRequest != nil || viewModel.feeds.isEmpty {
            return
        }
        else {
            self.getFeeds(refresh: false)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: -  Prefetch operation
extension SGFeedsListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let feedViewModel = viewModel.feeds[indexPath.row]
            //Prefetcing only the first media, rest would be pre-fetched by the internal media collection view (if required)
            guard let firstMedia = feedViewModel.media.first,
                    let url = firstMedia.url
            else { return }
            
            switch firstMedia.type {
            case .image:
                if SGImageTaskCaching.shared.getTask(for: url) == nil {
                    if let task = KingfisherManager.shared
                        .retrieveImage(with: url, completionHandler: { _ in
                            SGImageTaskCaching.shared.removeTask(for: url)
                        }) {
                        SGImageTaskCaching.shared.addTask(task, for: url)
                    }
                }
 
            case .video:
                VideoPreloadManager.shared.set(waiting: [url])
                
            case .unknown: break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let feedViewModel = viewModel.feeds[indexPath.row]
            //Prefetcing only the first media, rest would be pre-fetched by the internal media collection view (if required)
            guard let firstMedia = feedViewModel.media.first,
                    let url = firstMedia.url
            else { return }
            
            switch firstMedia.type {
            case .image:
                if let task = SGImageTaskCaching.shared.getTask(for: url) {
                    task.cancel()
                    SGImageTaskCaching.shared.removeTask(for: url)
                }
                
            case .video: break //No option to cancel video download, supported by the framework
            case .unknown: break
            }
        }
    }
}

extension SGFeedsListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let scrollSpeed = scrollView.panGestureRecognizer.velocity(in: view)
//        if abs(scrollSpeed.y) > 0 { return } //Scrolling too fast
        
        playVisibleVideoCell()        
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        playVisibleVideoCell()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            playVisibleVideoCell()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        playVisibleVideoCell()
    }
}

private extension SGFeedsListViewController {
    func handleAction(type: SGFeedTableCellActionType, viewModel:SGFeedViewModel) {
        switch type {
        case .share: break
        case .comment:
            let vc = UIHostingController(rootView: SGCommentListView(viewModel:
                                                                        SGCommentListViewModel(viewModel: viewModel)))
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            
        case .viewMedia:
            let vc = UIHostingController(rootView: SGMediaPreviewView(viewModel: viewModel))
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            
        
        default: break
        }
    }
}

//MARK:- Expandable label delegate
extension SGFeedsListViewController: SGFeedTableCellDelegate {
    func willExpand(cell: SGFeedsTableViewCell) {
        tableView.beginUpdates()
    }
    
    func didExpand(cell: SGFeedsTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        if viewModel.feeds.count > indexPath.row {
            viewModel.feeds[indexPath.row].descExpand = true
        }
        
        tableView.endUpdates()
    }
    
    func willCollapse(cell: SGFeedsTableViewCell) {
        tableView.beginUpdates()
    }
    
    func didCollapse(cell: SGFeedsTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        if viewModel.feeds.count > indexPath.row {
            viewModel.feeds[indexPath.row].descExpand = false
        }
        
        tableView.endUpdates()
    }
    
    
}
