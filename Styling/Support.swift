//
//  Support.swift
//  Styling
//
//  Created by Bernd Rabe on 06.02.16.
//  Copyright © 2016 Bernd Rabe. All rights reserved.
//

import Foundation

func delay (_ duration: TimeInterval, completion: @escaping ()->() ) {
    let triggerTime = Int64(Double(NSEC_PER_SEC) * duration)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
        completion()
    })
}
