//
//  InputOutputTransformable.swift
//  MVVMC
//
//  Created by Evan Xie on 2020/1/22.
//  Copyright © 2020 Evan Xie. All rights reserved.
//

import Foundation

protocol InputOutputTransformable {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
