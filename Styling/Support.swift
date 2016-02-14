//
//  Support.swift
//  Styling
//
//  Created by Bernd Rabe on 06.02.16.
//  Copyright © 2016 Bernd Rabe. All rights reserved.
//

import Foundation

func delay (duration: NSTimeInterval, completion: ()->() ) {
    let triggerTime = Int64(Double(NSEC_PER_SEC) * duration)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
        completion()
    })
}