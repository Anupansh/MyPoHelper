//
//  StyleGenerator.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 30/06/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import CalendarKit

struct StyleGenerator {
    static func defaultStyle() -> CalendarStyle {
        return CalendarStyle()
    }
    
    static func darkStyle() -> CalendarStyle {
        let black = UIColor.black
        let darkGray = UIColor(white: 0.15, alpha: 1)
        let lightGray = UIColor.lightGray
        let white = UIColor.white
        
        var selector = DaySelectorStyle()
        selector.activeTextColor = black
        selector.inactiveTextColor = white
        selector.selectedBackgroundColor = white
        
        var daySymbols = DaySymbolsStyle()
        daySymbols.weekDayColor = white
        daySymbols.weekendColor = lightGray
        
        var swipeLabel = SwipeLabelStyle()
        swipeLabel.textColor = white
        
        var header = DayHeaderStyle()
        header.daySelector = selector
        header.daySymbols = daySymbols
        header.swipeLabel = swipeLabel
        header.backgroundColor = black
        
        var timeline = TimelineStyle()
//        timeline.lineColor = lightGray
        timeline.timeColor = lightGray
        timeline.backgroundColor = black
        timeline.allDayStyle.backgroundColor = darkGray
        timeline.allDayStyle.allDayColor = white
        
        var style = CalendarStyle()
        style.header = header
        style.timeline = timeline
        
        return style
    }
}
