//
//  MBLineChartView.swift
//  Charts
//
//  Created by Thanaprus on 10/31/18.
//

import Foundation

open class MBLineChartView: LineChartView {
    internal override func initialize()
    {
        super.initialize()
        
        renderer = MBLineChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
        setupView()
    }
    
    private func setupView() {
        _legend.enabled = false
        drawGridBackgroundEnabled = false
        chartDescription?.enabled = false
        dragEnabled = false
        setScaleEnabled(true)
        pinchZoomEnabled = true
        
        xAxis.drawLabelsEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        leftAxis.drawAxisLineEnabled = false
        rightAxis.drawAxisLineEnabled = false
        leftAxis.drawGridLinesEnabled = false
        rightAxis.drawGridLinesEnabled = false
        leftAxis.drawLabelsEnabled = false
        rightAxis.drawLabelsEnabled = false
    }
}
