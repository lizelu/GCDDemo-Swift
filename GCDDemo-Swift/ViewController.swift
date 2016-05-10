//
//  ViewController.swift
//  GCDDemo-Swift
//
//  Created by Mr.LuDashi on 16/3/29.
//  Copyright © 2016年 ZeluLi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    //同步执行串行队列
    @IBAction func tapButton1(sender: AnyObject) {
        print("\n同步执行串行队列")
        performQueuesUseSynchronization(getSerialQueue("syn.seroal.queue"))
    }
    
    @IBAction func tapButton2(sender: AnyObject) {
        print("\n同步执行并行队列")
        performQueuesUseSynchronization(getConcurrentQueue("syn.concurrent.queue"))
    }
    
    @IBAction func tapButton3(sender: AnyObject) {
        print("\n异步执行串行队列")
        performQueuesUseAsynchronization(getSerialQueue("asyn.seroal.queue"))
    }

    @IBAction func tapButton4(sender: AnyObject) {
        print("\n异步执行并行队列")
        performQueuesUseAsynchronization(getConcurrentQueue("asyn.concurrent.queue"))
    }
    
    @IBAction func tapButton5(sender: AnyObject) {
        deferPerform(3)
    }
    
    @IBAction func tapButton6(sender: AnyObject) {
        globalQueuePriority()
    }
    
    
    @IBAction func tapButton7(sender: AnyObject) {
        setCustomeQueuePriority()
    }
    

    @IBAction func tapButton8(sender: AnyObject) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

