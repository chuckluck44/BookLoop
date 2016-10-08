//
//  RACUtil.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/19/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Rex
import enum Result.NoError

extension UITableViewCell {
    var racutil_prepareForReuseProducer: SignalProducer<(), NoError>  {
        return self.rac_prepareForReuseSignal
            .toSignalProducer()
            .ignoreError()
            .map { _ in }
    }
}

extension NSObject {
    var racutil_willDeallocProducer: SignalProducer<(), NoError>  {
        return self.rac_willDeallocSignal()
            .toSignalProducer()
            .ignoreError()
            .map { _ in }
    }
}
