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
    @IBAction func tapButton1(_ sender: AnyObject) {
        print("\n同步执行串行队列")
        performQueuesUseSynchronization(getSerialQueue("syn.serial.queue"))
    }
    
    //同步执行并行队列
    @IBAction func tapButton2(_ sender: AnyObject) {
        print("\n同步执行并行队列")
        performQueuesUseSynchronization(getConcurrentQueue("syn.concurrent.queue"))
    }
    
    @IBAction func tapButton3(_ sender: AnyObject) {
        print("\n异步执行串行队列")
        performQueuesUseAsynchronization(getSerialQueue("asyn.serial.queue"))
    }

    @IBAction func tapButton4(_ sender: AnyObject) {
        print("\n异步执行并行队列")
        performQueuesUseAsynchronization(getConcurrentQueue("asyn.concurrent.queue"))
        
    }
    
    /**
     延迟执行
     
     - parameter sender: 
     */
    @IBAction func tapButton5(_ sender: AnyObject) {
        deferPerform(1)
    }
    
    /**
     设置全局队列的优先级
     
     - parameter sender:
     */
    @IBAction func tapButton6(_ sender: AnyObject) {
        globalQueuePriority()
    }
    
    /**
     设置自建队列优先级
     
     - parameter sender:
     */
    @IBAction func tapButton7(_ sender: AnyObject) {
        setCustomeQueuePriority()
    }
    
    /**
     自动管理任务组
     
     - parameter sender:
     */
    @IBAction func tapButton8(_ sender: AnyObject) {
        getGlobalQueue().async { 
            performGroupQueue()
            
        }
    }
    
    //手动管理任务组
    @IBAction func tapButton08(_ sender: AnyObject) {
        performGroupUseEnterAndleave()
    }
    
    /**
     信号量同步锁
     
     - parameter sender:
     */
    @IBAction func tapButton12(_ sender: AnyObject) {
        useSemaphoreLock()
    }

    
    
    /**
     使用任务栅栏
     
     - parameter sender:
     */
    @IBAction func tapButton9(_ sender: AnyObject) {
        useBarrierAsync()
    }
    
    @IBAction func tapButton10(_ sender: AnyObject) {
        useDispatchApply()
    }
    
    @IBAction func tapButton11(_ sender: AnyObject) {
        queueSuspendAndResume()
    }
    
    
    @IBAction func tapButton13(_ sender: AnyObject) {
        useDispatchSourceAdd()
    }
    
    @IBAction func tapButton14(_ sender: AnyObject) {
        useDispatchSourceOr()
    }
    
    
    @IBAction func tapButton15(_ sender: AnyObject) {
        useDispatchSourceTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

