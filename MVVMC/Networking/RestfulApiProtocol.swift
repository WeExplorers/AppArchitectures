//
//  RestfulApiProtocol.swift
//  MVVMC
//
//  Created by Evan Xie on 2020/1/22.
//  Copyright © 2020 Evan Xie. All rights reserved.
//

import Foundation
import RxSwift

protocol RestfulApiProtocol {
    // Just for simple
    func login(username: String, password: String)
    func flowers() -> Single<Flower>
}
