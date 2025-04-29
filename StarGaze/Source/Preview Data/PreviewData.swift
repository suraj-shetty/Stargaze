//
//  PreviewData.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 08/10/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

extension SGCommentViewModel {
    static var preview: SGCommentViewModel {
        return SGCommentViewModel(with: Comments(id: 0,
                                                 comment: "Burgers is small and  beautiful city, you can enjoy",
                                                 status: "",
                                                 like_count: 1,
                                                 created_at: "2022-05-08T06:14:52.126Z",
                                                 updated_at: "2022-05-08T06:14:52.126Z",
                                                 post_id: 200,
                                                 user_id: 10,
                                                 parentPostCommentId: nil,
                                                 is_liked: "0",
                                                 commentUser: CommentUser(name: "Alfred Barker",
                                                                          pictureLink: nil,
                                                                          userName: "alfred.barker")))
    }
}

extension SGFeedViewModel {
    static var preview:SGFeedViewModel {
        return SGFeedViewModel(with: Post.preview)
    }
}

extension Post {
    static var preview: Post {
        return Post(id: 1,
                    desc: "Effective Forms Advertising Internet Web Site Fashion fades",
                    is_comment_on: false,
                    created_at: "2022-05-08T06:14:52.126Z",
                    like_count: 2,
                    share_count: 4,
                    comment_count: 5,
                    is_exclusive: false,
                    post_category: [],
                    post_hash_tag: [],
                    media: [],
                    celeb: Celeb(id: 1, name: "Ariana Grande", picture: ""),
                    is_liked: false)
    }
}

extension SGCelebrity {
    static var preview: SGCelebrity {
        return SGCelebrity(id: 14,
                           name: "Adarsh balakrishna",
                           status: .active,
                           picture: "https://cdn-user-qa.stargaze.ai/post/16279912324541h57ozimagepicker8742251980566678693.jpg",
                           about: "Aadarsh Balakrishna is an Indian film actor born on 10 February 1984 in Bangalore. He is primarily known for his negative roles in Telugu films. He is also the runner up of Telugu reality TV show Bigg Boss 1.",
                           isFollowed: false,
                           followersCount: 378000)
    }
}


extension SGCelebrityViewModel {
    static var preview: SGCelebrityViewModel {
        return SGCelebrityViewModel(celebrity: .preview)
    }
}


extension SegmentItemViewModel {
    static var preview: SegmentItemViewModel {
        return SegmentItemViewModel(title: "Feeds", iconName: "feedsSegment")
    }
    
    static var listPreview:[SegmentItemViewModel] {
        return [
            SegmentItemViewModel(title: "Feeds", iconName: "feedsSegment"),
            SegmentItemViewModel(title: "Media", iconName: "mediaSegment"),
            SegmentItemViewModel(title: "Brands", iconName: "brandSegment")
        ]
    }
}

extension SGEventViewModel {
    static var preview: SGEventViewModel {
        return SGEventViewModel(event:
                                    Event(id: 1,
                                          title: "“Shaver Sun Community” added to fun!",
                                          description: "",
                                          status: .ended,
                                          eventType: .show,
                                          mediaPath: "",
                                          mediaType: .png,
                                          likeCount: 10,
                                          shareCount: 1,
                                          commentCount: 1,
                                          participatesCount: 47001,
                                          createdAt: "2022-05-08T06:14:52.126Z",
                                          startAt: "2022-05-09T06:14:52.126Z",
                                          postCount: 0,
                                          coins: 0,
                                          isCommentOn: true,
                                          isJoined: false,
                                          isLiked: false,
                                          isWinnersDeclared: false,
                                          probability: 1,
                                          celeb: Celeb(id: 14,
                                                       name: "Adarsh balakrishna",
                                                       picture: "https://cdn-user-qa.stargaze.ai/post/16279912324541h57ozimagepicker8742251980566678693.jpg"),
                                          celebId: 14,
                                          winners: [])
        )
    }
}


extension LeaderboardUser {
    static var preview: LeaderboardUser {
        return LeaderboardUser(id: 0,
                               name: "Herman Barton",
                               me: "false",
                               picture: "",
                               rankString: "5",
                               coinsString: "234456")
    }
    
    static var list: [LeaderboardUser] {
        return [
            LeaderboardUser(id: 0,
                               name: "Aliah Pitts",
                               me: "false",
                               picture: "",
                               rankString: "1",
                               coinsString: "235466"),
            LeaderboardUser(id: 1,
                               name: "Alison Brie",
                               me: "false",
                               picture: "",
                               rankString: "2",
                               coinsString: "220154"),
            LeaderboardUser(id: 2,
                               name: "Adrian Chiran",
                               me: "false",
                               picture: "",
                               rankString: "3",
                               coinsString: "211879"),
            LeaderboardUser(id: 3,
                               name: "Thiago Barroncas",
                               me: "true",
                               picture: "",
                               rankString: "4",
                               coinsString: "235446"),
            ]
    }
}

extension LeaderboardCategory {
    static var preview: LeaderboardCategory {
        return LeaderboardCategory(id: 0,
                                   name: "Bollywood",
                                   users: LeaderboardUser.list)
    }
    
    static var listPreview: [LeaderboardCategory] {
        return [.preview, .preview]
    }
}

extension LeaderboardViewModel {
    static var preview: LeaderboardViewModel {
        return LeaderboardViewModel(category: .preview, filter: .allTime)
    }
    
    static var listPreview: [LeaderboardViewModel] {
        return [
            LeaderboardViewModel(category: .preview, filter: .allTime),
            LeaderboardViewModel(category: .preview, filter: .allTime)
        ]
    }
}
