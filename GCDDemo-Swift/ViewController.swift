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
        //高 > 默认 > 低 > 后台
        let queueHeight: dispatch_queue_t = getGlobalQueue(DISPATCH_QUEUE_PRIORITY_HIGH)
        let queueDefault: dispatch_queue_t = getGlobalQueue(DISPATCH_QUEUE_PRIORITY_DEFAULT)
        let queueLow: dispatch_queue_t = getGlobalQueue(DISPATCH_QUEUE_PRIORITY_LOW)
        let queueBackground: dispatch_queue_t = getGlobalQueue(DISPATCH_QUEUE_PRIORITY_BACKGROUND)
        print(queueHeight)
        print(queueDefault)
        print(queueLow)
        print(queueBackground)
        
        //优先级不是绝对的，大体上会按这个优先级来执行。 一般都是使用默认（default）优先级
        dispatch_async(queueLow) {
            print("低：\(getCurrentThread())")
        }
        
        dispatch_async(queueBackground) {
            print("后台：\(getCurrentThread())")
        }
        
        dispatch_async(queueDefault) {
            print("默认：\(getCurrentThread())")
        }
        
        dispatch_async(queueHeight) {
            print("高：\(getCurrentThread())")
        }
    }
    
    
    @IBAction func tapButton7(sender: AnyObject) {
        //优先级的执行顺序也不是绝对的
        
        //给serialQueueHigh设定DISPATCH_QUEUE_PRIORITY_HIGH优先级
        let serialQueueHigh = getSerialQueue("cn.zeluli.serial1")
        dispatch_set_target_queue(serialQueueHigh, getGlobalQueue(DISPATCH_QUEUE_PRIORITY_HIGH))
            
        let serialQueueLow = getSerialQueue("cn.zeluli.serial1")
        dispatch_set_target_queue(serialQueueLow, getGlobalQueue(DISPATCH_QUEUE_PRIORITY_LOW))
        
        
        dispatch_async(serialQueueLow) {
            print("低：\(getCurrentThread())")
        }
        
        dispatch_async(serialQueueHigh) {
            print("高：\(getCurrentThread())")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

