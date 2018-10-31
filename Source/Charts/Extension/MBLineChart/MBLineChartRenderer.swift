//
//  MBLineChartRenderer.swift
//  Charts
//
//  Created by Thanaprus on 10/31/18.
//

import CoreGraphics

open class MBLineChartRenderer: LineChartRenderer {
    @objc public override init(dataProvider: LineChartDataProvider, animator: Animator, viewPortHandler: ViewPortHandler) {
        super.init(dataProvider: dataProvider, animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    open override func drawExtras(context: CGContext) {
        drawCircles(context: context)
    }
    
    private func drawCircles(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let lineData = dataProvider.lineData
            else { return }
        
        let phaseY = animator.phaseY
        
        let dataSets = lineData.dataSets
        
        var pt = CGPoint()
        var rect = CGRect()
        
        // If we redraw the data, remove and repopulate accessible elements to update label values and frames
        accessibleChartElements.removeAll()
        //        accessibilityOrderedElements = accessibilityCreateEmptyOrderedElements()
        
        // Make the chart header the first element in the accessible elements array
        if let chart = dataProvider as? LineChartView {
            let element = createAccessibleHeader(usingChart: chart,
                                                 andData: lineData,
                                                 withDefaultDescription: "Line Chart")
            accessibleChartElements.append(element)
        }
        
        context.saveGState()
        
        for i in 0 ..< dataSets.count
        {
            guard let dataSet = lineData.getDataSetByIndex(i) as? ILineChartDataSet else { continue }
            
            if !dataSet.isVisible || dataSet.entryCount == 0
            {
                continue
            }
            
            let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
            let valueToPixelMatrix = trans.valueToPixelMatrix
            
            _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
            
            let circleRadius = dataSet.circleRadius
            let circleDiameter = circleRadius * 2.0
            let circleHoleRadius = dataSet.circleHoleRadius
            let circleHoleDiameter = circleHoleRadius * 2.0
            
            let drawCircleHole = dataSet.isDrawCircleHoleEnabled &&
                circleHoleRadius < circleRadius &&
                circleHoleRadius > 0.0
            let drawTransparentCircleHole = drawCircleHole &&
                (dataSet.circleHoleColor == nil ||
                    dataSet.circleHoleColor == NSUIColor.clear)
            
            for j in stride(from: (_xBounds.range + _xBounds.min), through: _xBounds.range + _xBounds.min, by: 1)
            {
                guard let e = dataSet.entryForIndex(j) else { break }
                
                pt.x = CGFloat(e.x)
                pt.y = CGFloat(e.y * phaseY)
                pt = pt.applying(valueToPixelMatrix)
                
                if (!viewPortHandler.isInBoundsRight(pt.x))
                {
                    break
                }
                
                // make sure the circles don't do shitty things outside bounds
                if (!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y))
                {
                    continue
                }
                
                // Accessibility element geometry
                //                let scaleFactor: CGFloat = 3
                //                let accessibilityRect = CGRect(x: pt.x - (scaleFactor * circleRadius),
                //                                               y: pt.y - (scaleFactor * circleRadius),
                //                                               width: scaleFactor * circleDiameter,
                //                                               height: scaleFactor * circleDiameter)
                //                // Create and append the corresponding accessibility element to accessibilityOrderedElements
                //                if let chart = dataProvider as? LineChartView
                //                {
                //                    let element = createAccessibleElement(withIndex: j,
                //                                                          container: chart,
                //                                                          dataSet: dataSet,
                //                                                          dataSetIndex: i)
                //                    { (element) in
                //                        element.accessibilityFrame = accessibilityRect
                //                    }
                //
                //                    accessibilityOrderedElements[i].append(element)
                //                }
                
                if !dataSet.isDrawCirclesEnabled
                {
                    continue
                }
                
                context.setFillColor(dataSet.getCircleColor(atIndex: j)!.cgColor)
                
                rect.origin.x = pt.x - circleRadius
                rect.origin.y = pt.y - circleRadius
                rect.size.width = circleDiameter
                rect.size.height = circleDiameter
                
                if drawTransparentCircleHole
                {
                    // Begin path for circle with hole
                    context.beginPath()
                    context.addEllipse(in: rect)
                    
                    // Cut hole in path
                    rect.origin.x = pt.x - circleHoleRadius
                    rect.origin.y = pt.y - circleHoleRadius
                    rect.size.width = circleHoleDiameter
                    rect.size.height = circleHoleDiameter
                    context.addEllipse(in: rect)
                    
                    // Fill in-between
                    context.fillPath(using: .evenOdd)
                }
                else
                {
                    context.fillEllipse(in: rect)
                    
                    if drawCircleHole
                    {
                        context.setFillColor(dataSet.circleHoleColor!.cgColor)
                        
                        // The hole rect
                        rect.origin.x = pt.x - circleHoleRadius
                        rect.origin.y = pt.y - circleHoleRadius
                        rect.size.width = circleHoleDiameter
                        rect.size.height = circleHoleDiameter
                        
                        context.fillEllipse(in: rect)
                    }
                }
            }
        }
        
        context.restoreGState()
        
        // Merge nested ordered arrays into the single accessibleChartElements.
        //        accessibleChartElements.append(contentsOf: accessibilityOrderedElements.flatMap { $0 } )
        //        accessibilityPostLayoutChangedNotification()
    }
}
