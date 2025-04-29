//
//  SGFeedsTableViewCell.swift
//  StarGaze
//
//  Created by Suraj Shetty on 18/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import RxSwift
import RxGesture
import Combine
import Kingfisher
import KMBFormatter

enum SGFeedTableCellActionType {
    case viewMedia
    case like
    case comment
    case share
    case profile
    case menu
}

protocol SGFeedTableCellDelegate: NSObjectProtocol {
    func willExpand(cell:SGFeedsTableViewCell)
    func didExpand(cell:SGFeedsTableViewCell)
    func willCollapse(cell:SGFeedsTableViewCell)
    func didCollapse(cell:SGFeedsTableViewCell)
}


class SGFeedsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var userInfoStackView: UIStackView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileIconContentView: SGRoundedView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var titleLabel: SGExpandableLabel!
    
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var likeView: UIStackView!
    @IBOutlet weak var likeLogo: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    @IBOutlet weak var commentView: UIStackView!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    @IBOutlet weak var shareView: UIStackView!
    @IBOutlet weak var shareCountLabel: UILabel!
    
    @IBOutlet weak var mediaContentView: SGRoundedView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var mediaHeightConstraint: NSLayoutConstraint!
    
    private(set) var mediaCollectionView:UICollectionView!
    
    unowned var viewModel:SGFeedViewModel! {
        didSet { updateContent() }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    var actionCallback: ((SGFeedsTableViewCell?, SGFeedTableCellActionType, Any?) -> ())?
    weak var delegate:SGFeedTableCellDelegate?
        
    private let disposeBag = DisposeBag()
    private var disposable:Disposable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        setupTagCollection()
        setupMediaCollectionView()
        setupBinding()
        setupLabel()
        
        profileIconContentView.cornerRadius = 11.5
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        mediaContentView.isHidden = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.kf.cancelDownloadTask()
        
        titleLabel.collapsed = true
        titleLabel.setText("")
    }
}

private extension SGFeedsTableViewCell {
    func setupMediaCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        mediaCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        mediaCollectionView.pin(to: mediaContentView)
        mediaContentView.sendSubviewToBack(mediaCollectionView)
        mediaContentView.translatesAutoresizingMaskIntoConstraints = false
        
        mediaCollectionView.register(UINib(nibName: "SGFeedImageCollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: feedImageCellIdentifier)
        mediaCollectionView.register(UINib(nibName: "SGFeedVideoCollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: feedVideoCellIdentifier)
        mediaCollectionView.dataSource = self
        mediaCollectionView.delegate = self
        mediaCollectionView.isPagingEnabled = true
        mediaCollectionView.isPrefetchingEnabled = true
        
//        mediaCollectionView.backgroundColor = .placeholder
    }
    
    func setupBinding() {
        profileImageView.rx.tapGesture()
            .when(.recognized)
            .subscribe {[weak self] _ in
                self?.actionCallback?(self, .profile, nil)
            }
            .disposed(by: disposeBag)
        
        userInfoStackView.rx.tapGesture()
            .when(.recognized)
            .subscribe {[weak self] _ in
                self?.actionCallback?(self, .profile, nil)
            }
            .disposed(by: disposeBag)
        
        mediaContentView.rx.tapGesture()
            .when(.recognized)
            .subscribe {[weak self] _ in
                self?.actionCallback?(self, .viewMedia, nil)
            }
            .disposed(by: disposeBag)
        
        
        menuButton.rx.tap
            .subscribe {[weak self] _ in
                self?.actionCallback?(self, .menu, nil)
            }
            .disposed(by: disposeBag)
        
        likeView.rx
            .tapGesture()
            .when(.ended)
            .subscribe {[weak self] _ in
                self?.actionCallback?(self, .like, nil)
                self?.viewModel.toggleLike()
            }
            .disposed(by: disposeBag)
        
        commentView.rx
            .tapGesture()
            .when(.ended)
            .subscribe {[weak self] _ in
                self?.actionCallback?(self, .comment, nil)
            }
            .disposed(by: disposeBag)
        
        shareView.rx
            .tapGesture()
            .when(.ended)
            .subscribe {[weak self] _ in
                self?.actionCallback?(self, .share, nil)
            }
            .disposed(by: disposeBag)
    }
    
    func setupLabel() {
        //Active Label
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        
        titleLabel.customize { label in

            let seeMoreText = NSLocalizedString("feed.list.description.read-more",
                                                comment: "")
            let seeLessText = NSLocalizedString("feed.list.description.read-less",
                                                comment: "")

            let seeMoreType = ActiveType.custom(pattern: "...\(seeMoreText)$")
            let seeLessType = ActiveType.custom(pattern: "\(seeLessText)$")

            label.enabledTypes = [.url, .email, .hashtag, .mention, seeMoreType, seeLessType]
            label.textColor = .text1
            label.hashtagColor = .brand2
            label.mentionColor = .brand2
            label.URLColor = .brand2
            label.customColor = [.email : .brand2]
            label.customColor[seeMoreType] = .brand2
            label.customColor[seeLessType] = .brand2
            label.lineSpacing   = 4

            label.handleHashtagTap { debugPrint("Hashtag \($0)") }
            label.handleMentionTap { debugPrint("Mention \($0)") }
            label.handleURLTap { debugPrint("URL \($0)") }
            label.handleEmailTap { debugPrint("Email \($0)") }
            
            label.handleCustomTap(for: seeMoreType) {[weak self] _ in
                guard let ref = self else { return }
                
                ref.delegate?.willExpand(cell: ref)
                ref.titleLabel.collapsed = false
                ref.titleLabel.layoutIfNeeded()
                ref.delegate?.didExpand(cell: ref)
            }
            
            label.handleCustomTap(for: seeLessType) {[weak self] _ in
                guard let ref = self else { return }
                
                ref.delegate?.willCollapse(cell: ref)
                ref.titleLabel.collapsed = true
                ref.titleLabel.layoutIfNeeded()
                ref.delegate?.didCollapse(cell: ref)
            }
            
        }
        
        //Expandable Label
        titleLabel.numberOfLines = 4
        titleLabel.textReplacementType = .word
        
        titleLabel.collapsedAttributedLink = NSAttributedString(string: NSLocalizedString("feed.list.description.read-more",
                                                                                          comment: ""),
                                                                attributes: [NSAttributedString.Key.foregroundColor : UIColor.seeMore])
        titleLabel.setLessLinkWith(lessLink: NSLocalizedString("feed.list.description.read-less",
                                                               comment: ""),
                                   attributes: [NSAttributedString.Key.foregroundColor : UIColor.seeMore],
                                   position: NSTextAlignment.natural)
                
        titleLabel.ellipsis = NSAttributedString(string: "…")
    }
    
    func updateContent() {
        
        if viewModel.hasMedia {
            mediaContentView.isHidden = false
            mediaHeightConstraint.constant = (UIScreen.main.bounds.width / viewModel.mediaApectRatio.ratio).rounded(.down)
            pageControl.numberOfPages = viewModel.media.count
            pageControl.hidesForSinglePage = true
        }
        else {
            mediaContentView.isHidden = true
        }
                     
        
        if let url = viewModel.profileImageURL {
            let processor = DownsamplingImageProcessor(size: profileImageView.bounds.size)
            profileImageView.kf.indicatorType = .activity
            profileImageView.kf.setImage(with: url,
                                         placeholder: nil,
                                         options: [
                                            .processor(processor),
                                            .scaleFactor(UIScreen.main.scale),
                                            .transition(ImageTransition.fade(1)),
                                            .cacheOriginalImage
                                         ]) { _ in
                                         }
        }
        
        nameLabel.text          = viewModel.name
        locationLabel.text      = viewModel.relativeDate
        titleLabel.collapsed    = !viewModel.descExpand
        titleLabel.setText(viewModel.title)
        
        if disposable != nil { //Previous observable present
            disposable?.dispose()
            disposable = nil
        }
        
        disposable = viewModel.canPlay.asObservable()
            .subscribe(onNext: {[weak self] value in
                self?.updatePlayStatus(value)
            })
        disposable?.disposed(by: disposeBag)
                
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
        
        cancellables = [
            viewModel.$isLiked
                .sink(receiveValue: {[weak self] didLike in
                    switch didLike {
                    case false:
                        self?.likeLogo.image = UIImage(named: "likeHollow")
                        self?.likeCountLabel.textColor = .text1
                        
                    case true:
                        self?.likeLogo.image = UIImage(named: "likeFill")
                        self?.likeCountLabel.textColor = .likeHighlight
                    }
                }),
            viewModel.$likeCount.map { KMBFormatter.shared.string(fromNumber: $0) }
                .sink(receiveValue: {[weak self] countText in
                    self?.likeCountLabel.text = countText
                }),
            viewModel.$commentCount.map { KMBFormatter.shared.string(fromNumber: $0) }
                .sink(receiveValue: {[weak self] countText in
                    self?.commentCountLabel.text = countText
                }),
            viewModel.$shareCount.map { KMBFormatter.shared.string(fromNumber: $0) }
                .sink(receiveValue: {[weak self] countText in
                    self?.shareCountLabel.text = countText
                })
        ]
                   
        DispatchQueue.main.async {[weak self] in
            self?.mediaCollectionView.reloadData()
        }
    }
    
    func setPage(_ page:Int) {
        
    }
    
    func updatePlayStatus(_ canPlay:Bool) {
        guard let visibleCells = mediaCollectionView.visibleCells.filter({ $0 is SGFeedVideoCollectionViewCell }) as? [SGFeedVideoCollectionViewCell],
              visibleCells.isEmpty == false
        else { return }
        
        visibleCells.forEach { cell in
            if canPlay {
                cell.play()
            }
            else {
                cell.pause()
            }
        }
    }
}

extension SGFeedsTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.media.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let media = viewModel.media[indexPath.item]
        switch media.type {
        case .image:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: feedImageCellIdentifier, for: indexPath) as! SGFeedImageCollectionViewCell
            cell.viewModel = media
            return cell
            
        case .video:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: feedVideoCellIdentifier, for: indexPath) as! SGFeedVideoCollectionViewCell
            cell.viewModel = media
            return cell
            
        default:
            let cell = UICollectionViewCell()
            return cell
        }
    }
}

extension SGFeedsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        switch cell {
//        case let videoCell as SGFeedVideoCollectionViewCell:
//            videoCell.play()
//            
//        default: break
//        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch cell {
        case let videoCell as SGFeedVideoCollectionViewCell:
            videoCell.pause()
         
        case let imageCell as SGFeedImageCollectionViewCell:
            imageCell.cancelImageLoad()
            
        default: break
        }
    }
}


extension SGFeedsTableViewCell: UICollectionViewDataSourcePrefetching {
    //Prefetching media content
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let media = viewModel.media[indexPath.item]
            guard let url = media.url else { return }
            
            switch media.type {
            case .image:
                
                if SGImageTaskCaching.shared.getTask(for: url) == nil {
                    if let task = KingfisherManager.shared
                        .retrieveImage(with: url,
                                       completionHandler: { _ in
                            SGImageTaskCaching.shared
                                .removeTask(for: url)
                            
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
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let media = viewModel.media[indexPath.item]
            guard let url = media.url else { return }
            
            switch media.type {
            case .image:
                if let task = SGImageTaskCaching.shared.getTask(for: url) {
                    task.cancel()
                    SGImageTaskCaching.shared.removeTask(for: url)
                }
                
            case .video: break  //No option to cancel preload
            case .unknown: break
            }
        }
    }
}

extension SGFeedsTableViewCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x/scrollView.frame.width)
        pageControl.currentPage = page
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let page = Int(scrollView.contentOffset.x/scrollView.frame.width)
            pageControl.currentPage = page
        }
    }
}
