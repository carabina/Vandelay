//
//  ExportAlertController.swift
//  Vandelay
//
//  Created by Daniel Saidi on 2016-05-30.
//  Copyright © 2016 Daniel Saidi. All rights reserved.
//

/*
 
 This alert controller can be used to easily display a
 list of export options to the user of the app.
 
 When using this alert class, you must remember to set
 the dataProvider and completion properties. If you do
 not, the app will crash whenever a user taps a button.
 
 */


import UIKit

public class ExportAlertController: UIAlertController {
    
    
    // MARK: Properties
    
    public var completion: ((result: ExportResult) -> ())!
    public var dataProvider: ExportDataProvider!
    
    
    
    // MARK: Public functions
    
    public func addDataExporter(exporter: DataExporter, withTitle title: String) {
        let action = UIAlertAction(title: title, style: .Default) { action in
            self.dataProvider.getExportData({ data in
                if (data == nil) {
                    let error = "ExportAlertController did not receive any data."
                    let result = exporter.getResultWithErrorMessage(error)
                    self.completion?(result: result)
                } else {
                    exporter.exportData(data!, completion: self.completion)
                }
            })
        }
        self.addAction(action)
    }
    
    public func addStringExporter(exporter: StringExporter, withTitle title: String) {
        let action = UIAlertAction(title: title, style: .Default) { action in
            self.dataProvider.getExportDataString({ string in
                if (string == nil) {
                    let error = "ExportAlertController did not receive a string."
                    let result = exporter.getResultWithErrorMessage(error)
                    self.completion?(result: result)
                } else {
                    exporter.exportString(string!, completion: self.completion)
                }
            })
        }
        self.addAction(action)
    }
}