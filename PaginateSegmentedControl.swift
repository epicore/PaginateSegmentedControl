//
//  PaginateSegmentedControl.swift
//  patient enabler
//
//  Created by Joshua Weinberg on 7/28/17.
//  Copyright © 2017 3rd Street Apps. All rights reserved.
//

import UIKit

class PaginateSegmentedControl: UISegmentedControl {

    // MARK:Internal property(s)

    internal var selectedDataIndex = 0 // default value
    internal var segmentLimit = 10 // default value
    
    // MARK:Private property(s)
    
    private var data:[String]?
    private let firstPage = 0
    private var pageNumber = 0 // default value
    private var registeredTarget:UIViewController?
    private var registeredAction:Selector?
    
    private var lastPage:Int {
        get {
            if let dat = self.data {
                // integer division truncates any remainder (as desired)
                return dat.count / self.segmentLimit
            } else {
                return 0
            }
        }
    }
    
    private var needsPagination:Bool {
        get {
            if let dat = self.data {
                return self.segmentLimit < dat.count
            } else {
                return false
            }
        }
    }
    
    // MARK: Override methods to control ValueChanged update to subscriber objects
    
    override open var selectedSegmentIndex: Int {
        get {
            return self.computeDataIndicieForSegmentNumber(super.selectedSegmentIndex)
        }
        set {
            self.selectedDataIndex = newValue
            
            if self.needsPagination {
                self.pageNumber = self.computePageNumberForDataIndice(newValue)
                super.selectedSegmentIndex = self.computeSegmentNumberForDataIndice(newValue)
            } else {
                super.selectedSegmentIndex = newValue
            }
        }
    }
    
    override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControlEvents) {
        if controlEvents == .valueChanged {
            self.registeredTarget = target as? UIViewController
            self.registeredAction = action
            super.addTarget(self, action: #selector(self.handleValueChanged(_:)), for: controlEvents)
        } else {
            super.addTarget(target, action: action, for: controlEvents)
        }
    }
    
    @objc
    private func handleValueChanged(_ sender:Any?) {
        
        if let action = self.registeredAction, let target = self.registeredTarget, let dat = self.data {
            
            let newValue = super.selectedSegmentIndex
            
            if self.needsPagination {
                
                if self.userTouchedLeftArrow(newValue) {
                    
                    if self.pageNumber == self.firstPage {
                        self.pageNumber = self.lastPage
                    } else {
                        self.pageNumber -= 1
                    }
                    
                    self.populateSegControl(dat)
                    super.selectedSegmentIndex = self.computeSegmentNumberForDataIndice(self.selectedDataIndex)
                    
                } else if self.userTouchedRightArrow(newValue) {
                    
                    if self.pageNumber == self.lastPage {
                        self.pageNumber = self.firstPage
                    } else {
                        self.pageNumber += 1
                    }
                    
                    self.populateSegControl(dat)
                    super.selectedSegmentIndex = self.computeSegmentNumberForDataIndice(self.selectedDataIndex)
                    
                } else {
                    self.selectedDataIndex = self.computeDataIndicieForSegmentNumber(super.selectedSegmentIndex)
                    target.perform(action, with: self)
                }
                
            } else {
                self.selectedDataIndex = self.computeDataIndicieForSegmentNumber(super.selectedSegmentIndex)
                target.perform(action, with: self)
            }
        }
    }
    
    // MARK:Public method(s)
    
    func configure(withData data:[String], numberOfSegments:Int, andSelectedIndicie indicie:Int) {
        self.segmentLimit = numberOfSegments
        self.populateSegControl(newData:data, selectedIndicie:indicie)
    }
    
    // MARK:Private Helper methods
    
    private func populateSegControl(newData:[String], selectedIndicie:Int) {
        self.data = newData
        self.populateSegControl(newData)
        super.selectedSegmentIndex = self.computeSegmentNumberForDataIndice(selectedIndicie)
    }
    
    private func populateSegControl(_ segmentTitles:[String]) {
        
        // setup variables for the loop
        var i = 0
        let startSlice = self.pageNumber * self.segmentLimit
        var endSlice = startSlice + self.segmentLimit - 1
        
        let showForwardArrow = segmentTitles.count > endSlice
        if !showForwardArrow {
            endSlice = segmentTitles.count - 1
        }
        let dataSlice = segmentTitles[startSlice...endSlice]
        
        // clear all the segments
        self.removeAllSegments()
        
        // populate new segments
        if self.needsPagination {
            self.insertSegment(withTitle: " < ", at: i, animated: false)
            i += 1
        }
        
        for (_, titleString) in dataSlice.enumerated() {
            self.insertSegment(withTitle: titleString, at: i, animated: false)
            i += 1
        }
        
        if self.needsPagination {
            self.insertSegment(withTitle: " > ", at: i, animated: false)
        }
    }
    
    private func computeSegmentNumberForDataIndice(_ dataIndice:Int) -> Int {
        if self.needsPagination {
            var returnValue = -1
            if self.computePageNumberForDataIndice(dataIndice) == self.pageNumber {
                returnValue = dataIndice % self.segmentLimit
                returnValue += 1 // accounts for a left arrow at position 0
            }
            return returnValue
        } else {
            return dataIndice
        }
    }
    
    private func computeDataIndicieForSegmentNumber(_ segmentNumber:Int) -> Int {
        if self.needsPagination {
            return self.pageNumber * self.segmentLimit + segmentNumber - 1
        } else {
            return segmentNumber
        }
    }
    
    private func computePageNumberForDataIndice(_ dataIndice:Int) -> Int {
        return Int(dataIndice / self.segmentLimit)
    }
    
    private func userTouchedLeftArrow(_ segmentTouched:Int) -> Bool {
        return segmentTouched == 0
    }
    
    private func userTouchedRightArrow(_ segmentTouched:Int) -> Bool {
        if let dat = self.data {
            return self.computeDataIndicieForSegmentNumber(segmentTouched) >= dat.count || segmentTouched > self.segmentLimit
        } else {
            return  segmentTouched > self.segmentLimit
        }
    }
}
