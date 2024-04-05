//
//  LayoutModel.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 01/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

struct LayoutModel {

    private var _key:ControllerKeys?
    private var _image:String?
    
    var key:ControllerKeys? {
        return _key
    }
    
    var image:UIImage? {
        return UIImage(named: _image ?? "")
    }
    
    var imageString:String? {
        return _image
    }
    
    init(key:ControllerKeys,image:String?) {
        self._key = key
        self._image = image
    }
    
}

extension LayoutModel {
    
    static func defaultLayoutModels() -> [LayoutModel] {
        let layout1 = LayoutModel(key: .calendar, image: "")
        return [layout1]
    }
    
    static func layouts(with data:[[String]]) -> [LayoutModel] {
        var layouts = [LayoutModel]()
        for layout in data {
            guard let keyString = layout.first,let key = ControllerKeys(rawValue: keyString) ,let image = layout.last else {
                continue
            }
            let layout = LayoutModel(key: key, image: image)
            layouts.append(layout)
        }
        return layouts
    }
    
}
