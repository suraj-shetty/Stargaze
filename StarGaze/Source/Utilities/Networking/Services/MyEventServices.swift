//
//  MyEventServices.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 27/10/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

class MyEventServices: HTTPClient {
    
    func getEvents(for request: MyEventRequest) async -> Result<Events, SGAPIError> {
        return await sendRequest(endpoint: SGEventEndPoint.myEventHistory(request: request),
                                 responseModel: Events.self)
    }
}
