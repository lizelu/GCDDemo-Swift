//
//  GCD.swift
//  GCDDemo-Swift
//
//  Created by Mr.LuDashi on 16/3/29.
//  Copyright © 2016年 ZeluLi. All rights reserved.
//

import Foundation

/**
 获取当前线程
 
 - returns: NSThread
 */
func getCurrentThread() -> Thread {
    let currentThread = Thread.current
    return currentThread
}

/**
 当前线程休眠
 
 - parameter timer: 休眠时间/单位：s
 */
func currentThreadSleep(_ timer: TimeInterval) -> Void {
    Thread.sleep(forTimeInterval: timer)
    
    //或者使用
    //sleep(UInt32(timer))
}



/**
 获取主队列
 
 - returns: dispatch_queue_t
 */
func getMainQueue() -> DispatchQueue {
    return DispatchQueue.main
}


/**
 获取全局队列
*/

func getGlobalQueue() -> DispatchQueue {
    return DispatchQueue.global()
    
}



/**
 创建并行队列
 
 - parameter label: 并行队列的标记
 
 - returns: 并行队列
 */
func getConcurrentQueue(_ label: String) -> DispatchQueue {
    return DispatchQueue(label: label, attributes: DispatchQueue.Attributes.concurrent)
}


/**
 创建串行队列
 
 - parameter label: 串行队列的标签
 
 - returns: 串行队列
 */
func getSerialQueue(_ label: String) -> DispatchQueue {
    return DispatchQueue(label: label)
}


/**
队列的同步执行
 
 - parameter queue: 队列
 */
func performQueuesUseSynchronization(_ queue: DispatchQueue) -> Void {
    
    for i in 0..<3 {
        queue.sync {
            currentThreadSleep(1)
            print("当前执行线程：\(getCurrentThread())")
            print("执行\(i)")
        }
        print("\(i)执行完毕")
    }
    print("所有队列使用同步方式执行完毕")
}

/**
 队列的异步执行
 
 - parameter queue: 队列
 */
func performQueuesUseAsynchronization(_ queue: DispatchQueue) -> Void {
    
    //一个串行队列，用于同步执行
    let serialQueue = getSerialQueue("serialQueue")
    
    for i in 0..<3 {
        queue.async {
            currentThreadSleep(Double(arc4random()%3))
            let currentThread = getCurrentThread()
            
            serialQueue.sync(execute: {              //同步锁
                print("Sleep的线程\(currentThread)")
                print("当前输出内容的线程\(getCurrentThread())")
                print("执行\(i):\(queue)\n")
            })
        }
        
        print("\(i)添加完毕\n")
    }
    print("使用异步方式添加队列")
}


/**
 延迟执行
 
 - parameter time: 延迟执行的时间
 */
func deferPerform(_ time: Double) -> Void {
    
    //dispatch_time用于计算相对时间,当设备睡眠时，dispatch_time也就跟着睡眠了
    let delayTime: DispatchTime = DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    getGlobalQueue().asyncAfter(deadline: delayTime) {
        print("执行线程：\(getCurrentThread())\ndispatch_time: 延迟\(time)秒执行\n")
    }
    
    //dispatch_walltime用于计算绝对时间,而dispatch_walltime是根据挂钟来计算的时间，即使设备睡眠了，他也不会睡眠。
    let nowInterval = Date().timeIntervalSince1970
    let nowStruct = timespec(tv_sec: Int(nowInterval), tv_nsec: 0)
    let delayWalltime = DispatchWallTime(timespec: nowStruct)
    getGlobalQueue().asyncAfter(wallDeadline: delayWalltime) {
        print("执行线程：\(getCurrentThread())\ndispatch_walltime: 延迟\(time)秒执行\n")
    }
    
    print(NSEC_PER_SEC) //一秒有多少纳秒
}

/**
 全局队列的优先级关系
 */
func globalQueuePriority() {
}

/**
 给串行队列或者并行队列设置优先级
 */
func setCustomeQueuePriority() {
    //优先级的执行顺序也不是绝对的
    
    //Work is virtually instantaneous.:     DispatchQoS.userInteractive
    //Work is nearly instantaneous, such as a few seconds or less.  DispatchQoS.userInitiated
    //Work takes a few seconds to a few minutes.    DispatchQoS.utility
    //Work takes significant time, such as minutes or hours. DispatchQoS.background
    
    print("userInteractive & userInitiated")
    let queue1 = DispatchQueue(label:"zeluli.queue1", qos: DispatchQoS.userInteractive)
    let queue2 = DispatchQueue(label:"zeluli.queue2", qos: DispatchQoS.userInitiated)
    queue1.async {
        for i in 100..<110{
            print("😄", i, getCurrentThread())
        }
    }
    
    queue2.async {
        for i in 200..<210{
            print("😭", i, getCurrentThread())
        }
    }
    
    
    sleep(1)
    
    print("\n\n=========第二批==========\n")
    print("userInitiated & utility")
    let queue3 = DispatchQueue(label:"zeluli.queue3", qos: DispatchQoS.userInitiated)
    let queue4 = DispatchQueue(label:"zeluli.queue4", qos: DispatchQoS.utility)
    
    queue3.async {
        for i in 300..<310{
            print("😄", i, getCurrentThread())
        }
    }
    
    queue4.async {
        for i in 400..<410{
            print("😭", i, getCurrentThread())
        }
    }
    
    
    sleep(1)
    print("\n\n=========第三批==========\n")
    print("utility & background")
    let queue5 = DispatchQueue(label:"zeluli.queue5", qos: DispatchQoS.utility)
    let queue6 = DispatchQueue(label:"zeluli.queue6", qos: DispatchQoS.background)
    
    queue5.async {
        for i in 500..<510{
            print("😄", i, getCurrentThread())
        }
    }
    
    queue6.async {
        for i in 600..<610{
            print("😭", i, getCurrentThread())
        }
    }
}

/**
 一组队列执行完毕后在执行需要执行的东西，可以使用dispatch_group来执行队列
 */
func performGroupQueue() {
    print("\n任务组自动管理：")
    
    let concurrentQueue: DispatchQueue = getConcurrentQueue("cn.zeluli")
    let group: DispatchGroup = DispatchGroup()
    
    //将group与queue进行管理，并且自动执行
    for i in 1...3 {
        concurrentQueue.async(group: group) {
            currentThreadSleep(1)
            print("任务\(i)执行完毕\n")
        }
    }
    
    //队列组的都执行完毕后会进行通知
    group.notify(queue: getMainQueue()) {
        print("所有的任务组执行完毕！\n")
    }

    print("异步执行测试，不会阻塞当前线程")
}

/**
 * 使用enter与leave手动管理group与queue
 */
func performGroupUseEnterAndleave() {
    print("\n任务组手动管理：")
    let concurrentQueue: DispatchQueue = getConcurrentQueue("cn.zeluli")
    let group: DispatchGroup = DispatchGroup()
    
    //将group与queue进行手动关联和管理，并且自动执行
    for i in 1...3 {
        group.enter()                     //进入队列组
        
        concurrentQueue.async(execute: {
            currentThreadSleep(1)
            print("任务\(i)执行完毕\n")
            
            group.leave()                 //离开队列组
        })
    }
    group.wait()//阻塞当前线程，直到所有任务执行完毕
    print("任务组执行完毕")
    
    group.notify(queue: concurrentQueue) {
        print("手动管理的队列执行OK")
    }
}

//信号量同步锁
func useSemaphoreLock() {
    
    let concurrentQueue = getConcurrentQueue("cn.zeluli")
    
    //创建信号量
    let semaphoreLock: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    var testNumber = 0
    
    for index in 1...10 {
        concurrentQueue.async(execute: {
            semaphoreLock.wait()//上锁
            
            testNumber += 1
            currentThreadSleep(Double(1))
            print(getCurrentThread())
            print("第\(index)次执行: testNumber = \(testNumber)\n")
            
            semaphoreLock.signal()                      //开锁
            
        })
    }
    
    print("异步执行测试\n")
}




/**
 循环执行_类似于dispatch_apply
 */
func useDispatchApply() {
    
    print("循环多次执行并行队列")
    DispatchQueue.concurrentPerform(iterations: 10) { (index) in
        currentThreadSleep(Double(index))
        print("第\(index)次执行，\n\(getCurrentThread())\n")
    }
}

//暂停和重启队列
func queueSuspendAndResume() {
    let concurrentQueue = getConcurrentQueue("cn.zeluli")
    
    concurrentQueue.suspend()   //将队列进行挂起
    concurrentQueue.async { 
        print("任务执行")
    }
    
    currentThreadSleep(2)
    concurrentQueue.resume()    //将挂起的队列进行唤醒
}

/**
 使用给队列加栅栏
 */
func useBarrierAsync() {
    let concurrentQueue: DispatchQueue = getConcurrentQueue("cn.zeluli")
    for i in 0...3 {
        concurrentQueue.async {
            currentThreadSleep(Double(i))
            print("第一批：\(i)\(getCurrentThread())")
        }
    }
    
    
    concurrentQueue.async(flags: .barrier, execute: {
        print("\n第一批执行完毕后才会执行第二批\n\(getCurrentThread())\n")
    }) 
    
    
    for i in 0...3 {
        concurrentQueue.async {
            currentThreadSleep(Double(i))
            print("第二批：\(i)\(getCurrentThread())")
        }
    }
    
    print("异步执行测试\n")
}

/**
 以加法运算的方式合并数据
 */
func useDispatchSourceAdd() {
    var sum = 0     //手动计数的sum, 来模拟记录merge的数据
    
    let queue = getGlobalQueue()
    
    //创建source
    let dispatchSource:DispatchSource = DispatchSource.makeUserDataAddSource(queue: queue) as! DispatchSource
    
    dispatchSource.setEventHandler {
//        print("source中所有的数相加的和等于\(dispatchSource.Date)")
        print("sum = \(sum)\n")
        sum = 0
       currentThreadSleep(0.3)
    }

    dispatchSource.resume()
    
    for i in 1...10 {
        sum += i
        print(i)
//        dispatchSource.mergeData(value: UInt(i))
        currentThreadSleep(0.1)
    }
}


/**
 以或运算的方式合并数据
 */
func useDispatchSourceOr() {
    
    var or = 0     //手动计数的sum, 来记录merge的数据
    
    let queue = getGlobalQueue()
    
    //创建source
    let dispatchSource:DispatchSource = DispatchSource.makeUserDataOrSource(queue: queue) as! DispatchSource
    
    dispatchSource.setEventHandler {
//        print("source中所有的数相加的和等于\(dispatchSource.data)")
        print("or = \(or)\n")
        or = 0
        currentThreadSleep(0.3)
        
    }
    
    dispatchSource.resume()
    
    for i in 1...10 {
        or |= i
        print(i)
//        dispatchSource.mergeData(value: UInt(i))
        
        currentThreadSleep(0.1)
        
    }
    
    print("\nsum = \(or)")
}

/**
 使用dispatch_source创建定时器
 */
func useDispatchSourceTimer() {
    let queue: DispatchQueue = getGlobalQueue()
    let source = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 0), queue: queue)
   
    //设置间隔时间，从当前时间开始，允许偏差0纳秒
    let timer = UInt64(1) * NSEC_PER_SEC
    source.scheduleRepeating(deadline: DispatchTime.init(uptimeNanoseconds: UInt64(timer)), interval: DispatchTimeInterval.seconds(Int(1)), leeway: DispatchTimeInterval.seconds(0))
    
    var timeout = 10    //倒计时时间
    
    //设置要处理的事件, 在我们上面创建的queue队列中进行执行
    source.setEventHandler {
        print(getCurrentThread())
        if(timeout <= 0) {
            source.cancel()
        } else {
            print("\(timeout)s")
            timeout -= 1
        }
    }
    
    //倒计时结束的事件
    source.setCancelHandler { 
        print("倒计时结束")
    }
    source.resume()
}


