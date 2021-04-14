//
//  CircleView.swift
//  Map_task
//
//  Created by moh on 4/12/21.
//  Copyright © 2021 moh. All rights reserved.
//

import UIKit

class CircleView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        let radius = frame.width / 2
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        makecircle()
    }
    
    func makecircle() {
        let radius = frame.width / 2
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }

}
