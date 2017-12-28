//
//  ViewController.swift
//  PoliPoli-Alpha
//
//  Created by Tatsuya Moriguchi on 12/27/17.
//  Copyright © 2017 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    private static let lineEntityName = "Line"
    private static let lineNumberKey = "lineNumber"
    private static let lineTextKey = "lineText"
    
    @IBOutlet var lineFields:[UITextField]!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext

        // Since want to retrieve all Line objects in the persistent store, do not create a predicate.
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: ViewController.lineEntityName)
        
        do{
            let objects = try context.fetch(request)
            for object in objects {
                let lineNum: Int = (object as AnyObject).value(forKey: ViewController.lineNumberKey)! as! Int
                let lineText = (object as AnyObject).value(forKey: ViewController.lineTextKey) as? String ?? ""
                let textField = lineFields[lineNum]
                textField.text = lineText
            }
            
            let app = UIApplication.shared
            NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationWillResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: app)
        } catch{
            // Error thrown from executeFetchRequest()
            print("there was an error in executeFetchRequest(): \(error)")
        }
    }
    
    func applicationWillResignActive(_ notification: Notification) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        for i in 0 ..< lineFields.count {
            let textField = lineFields[i]
            
            let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: ViewController.lineEntityName)
            let pred = NSPredicate(format: "%K = %d", ViewController.lineNumberKey, i)
            request.predicate = pred
            
            do {
                let objects = try context.fetch(request)
                var theLine:NSManagedObject! = objects.first as? NSManagedObject
                if theLine == nil {
                    // No existing data for this row - insert a new managed object for it.
                    theLine = NSEntityDescription.insertNewObject(forEntityName: ViewController.lineEntityName, into: context) as NSManagedObject
                }
                
                theLine.setValue(i, forKey: ViewController.lineNumberKey)
                theLine.setValue(textField.text, forKey: ViewController.lineTextKey)
            } catch {
                print("there was an error in executeFetchRequest() \(error)")
            }
        }
        appDelegate.saveContext()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

