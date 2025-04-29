//
//  SGFeedListViewModel.swift
//  StarGaze
//
//  Created by Suraj Shetty on 18/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import Combine

class SGFeedListViewModel: NSObject {

    private var type:SGFeedType!
    private var cancellables = Set<AnyCancellable>()
    private var didEnd:Bool = false
    private(set) var currentRequest:SGFeedRequest?
    
    var feeds = [SGFeedViewModel]()
    
    var currentToken:String?
    var endOfPage:Bool {
        get { didEnd }
    }
    
    convenience init(type:SGFeedType) {
        self.init()
        self.type = type
    }
 
    func pauseAllVideos() {
        for feed in feeds {
            feed.canPlay.accept(false)
        }
    }
    
    
    func getFeeds(with request:SGFeedRequest, shouldRefresh:Bool = false,
                  completion:@escaping (Bool, [IndexPath]? ,SGAPIError?) -> Void) {
                
        if shouldRefresh == true {
            didEnd = false
//            feeds.removeAll()
            cancellables.forEach({ $0.cancel() })
            cancellables.removeAll()
        }
        else if didEnd { //Already reached the end, no more request required
            completion(false, nil, nil)
            return
        }
        else if currentRequest != nil {
            return
        }
        
        self.currentRequest = request
        SGFeedService.getFeeds(of: type, request: request)
            .sink {[weak self] result in
                self?.currentRequest = nil
                
                switch result {
                case .failure(let error): completion(false, nil, error)
                case .finished: break
                }
            } receiveValue: {[weak self] response in
                self?.currentRequest = nil
                
                let posts = response.result.posts.map({ SGFeedViewModel(with: $0) })
                
                if posts.isEmpty { //No post available
                    self?.didEnd = true
                    completion(true, nil, nil)
                }
                else {
                    if shouldRefresh {
                        self?.feeds = posts
                        self?.currentToken = response.result.recommId
                        completion(true, nil, nil)
                    }
                    else {
                        let startIndex = self?.feeds.count ?? 0
                        let endIndex = startIndex + posts.count
                        self?.feeds.append(contentsOf: posts)
                        self?.currentToken = response.result.recommId
                        
                        //Calulating the indexpath of newly added posts
                        let indexList = (startIndex..<endIndex).map({ return IndexPath(row: $0, section: 0) })
                        completion(true, indexList, nil)
                        }
                    }
                }
            .store(in: &cancellables)
    }
}
