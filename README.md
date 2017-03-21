## GCD 内容相关Demo, Swift版
Swift3.0相关代码已在github上更新。之前关于iOS开发多线程的内容发布过一篇博客，其中介绍了NSThread、操作队列以及GCD，介绍的不够深入。今天就以GCD为主题来全面的总结一下GCD的使用方式。GCD的历史以及好处在此就不做过多的赘述了。本篇博客会通过一系列的实例来好好的总结一下GCD。GCD在iOS开发中还是比较重要的，使用场景也是非常多的，处理一些比较耗时的任务时基本上都会使用到GCD, 在使用是我们也要主要一些线程安全也死锁的东西。

本篇博客中对iOS中的GCD技术进行了较为全面的总结，下方模拟器的截图就是我们今天要介绍的内容，都是关于GCD的。下方视图控制器中每点击一个Button都会使用GCD的相关技术来执行不同的内容。本篇博客会对使用到的每个技术点进行详细的讲解。在讲解时，为了易于理解，我们还会给出原理图，这些原理图都是根据本篇博客中的实例进行创作的，在其他地方可见不着。

![](http://images2015.cnblogs.com/blog/545446/201605/545446-20160515214503648-186877899.png)

上面每个按钮都对应着一坨坨的代码，上面这个截图算是我们本篇博客的一个，下面我们将会对每坨代码进行详细的介绍。通过这些介绍，你应该对GCD有了更全面而且更详细的了解。建议参考着下方的介绍，然后自己动手去便实现代码，这样效果是灰常的好的。本篇博客中的所有代码都会在github上进行分享，本篇博客的后方会给出github分享地址。其实本篇博客可以作为你的GCD参考手册，虽然本篇博客没有囊括所有GCD的东西，但是平时经常使用的部分还是有的。废话少说，进入今天博客的主题，接下来我们将一个Button接着一个Button的介绍。

## 一、常用GCD方法的封装

为了便于实例的实现，我们首先对一些常用的GCD方法进行封装和提取。该部分算是为下方的具体实例做准备的，本部分封装了一些下面示例所公用的方法。接下来我们将逐步的对每个提取的函数进行介绍，为下方示例的实现做准备。在封装方法之前，要说明一点的是在GCD中我们的任务是放在队列中在不同的线程中执行的，要明白一点就是我们的任务是放在队列中的Block中，然后Block再在相应的线程中完成我们的任务。

如下图所示，在下方队列中存入了三个Block，每个Block对应着一个任务，这些任务会根据队列的特性已经执行方式被放到相应的线程中来执行。队列可分为并行队列（Concurrent Qeueu）和串行队列（Serial Queue），队列可以进行同步执行(Synchronize)以及异步执行（Asynchronize）, 稍后会进行详细的分析与介绍。我们要知道队列第GCD的基础。

![](http://images2015.cnblogs.com/blog/545446/201605/545446-20160512103228905-1463046040.png)

#### 1.获取当前线程与当前线程休眠

首先我们将获取当前线程的方法进行封装，因为有时候我们会经常查看我们的任务是在那些线程中执行的。在此我们使用了NSThread的currentThread()方法来获取当前线程。下方的getCurrentThread()方法就是我们提取的获取当前线程的方法。方法内容比较简单，在此就不做过多赘述了。
```Swift
/**
 获取当前线程
 
 - returns: NSThread
 */
func getCurrentThread() -> Thread {
    let currentThread = Thread.current
    return currentThread
}
```
　　

上述代码段是获取当前线程的方法，接着我们要实现一个让当前线程休眠的方法。因为我们在示例时，常常会让当前线程来休眠一段时间来模拟那些耗时的操作。下方代码段中的currentThreadSleep()函数就是我们提取的当前线程休眠的函数。该函数有一个NSTimeInterval类型的参数，该参数就是要休眠的时间。NSTimeInterval其实就是Double类型的别名，所以我们在调用currentThreadSleep()方法时需要传入一个Double类型的休眠时间。当然你也可以调用sleep()方法来对当前线程进行休眠，但是需要注意的是sleep()的参数是UInt32位的整型。下方就是我们休眠当前线程的函数。
```Swift
/**
 当前线程休眠
 
 - parameter timer: 休眠时间/单位：s
 */
func currentThreadSleep(_ timer: TimeInterval) -> Void {
    Thread.sleep(forTimeInterval: timer)
    
    //或者使用
    //sleep(UInt32(timer))
}
```

#### 2.获取主队列与全局队列

下方封装的getMainQueue()函数就是获取主队列的函数，因为有时候我们在其他线程中处理完耗时的任务（比如网络请求）后，需要在主队列中对UI进行更新。因为我们知道在iOS中有个RunLoop的概念，在iOS系统中触摸事件、屏幕刷新等都是在RunLoop中做的。因为本篇博客的主题是GCD, 在此就对RunLoop做过多的赘述了，如果你对RunLoop不太了解，那么你就先简单将RunLoop理解成1/60执行一次的循环即可，当然真正的RunLoop要比一个单纯的循环复杂的多，以后有机会的话在以RunLoop为主题更新一篇博客吧。言归正传，下方就是获取我们主队列的方法，简单一点的说因为我们要更新UI，所以要获取主队列。
```Swift
/**
 获取主队列
 
 - returns: dispatch_queue_t
 */
func getMainQueue() -> DispatchQueue {
    return DispatchQueue.main
}
```
　　

接下来我们要封装一个获取全局队列（Global Queue）的函数，在封装函数之前我们先来聊聊什么是全局队列。全局队列是系统提供的一个队列，该队列拿过来就能用，按执行方式来说，全局队列应该称得上是并行队列，关于串并行队列的具体概念下方会给出介绍。我们在获取全局队列的时候要知道其队列的优先级，优先级越高的队列就越先执行，当然该处的优先级不是绝对的。队列真正的执行顺序还需要根据CUP当前的状态来定，大部分是按照你指定的队列优先级来执行的，不过也有例外。下方实例会给出详细的介绍。下方就是我们获取全局队列的函数，在获取全局队列为为全局队列指定一个优先级，默认为DISPATCH_QUEUE_PRIORITY_DEFAULT。
```Swift
/**
 获取全局队列
*/

func getGlobalQueue() -> DispatchQueue {
    return DispatchQueue.global()
    
}

```
　　

#### 3.创建串行队列与并行队列

因为我们在实现实例时会创建一些并行队列和串行队列，所以我们要对并行队列的创建于串行队列的创建进行提取。GCD中是调用dispatch_queue_create()函数来创建我们想要的线程的。dispatch_queue_create()函数有两个参数，第一个参数是队列的标示，用来标示你创建的队列对象，一般是域名的倒写如“cn.zeluli”这种形式。第二个参数是所创建队列的类型，DISPATCH_QUEUE_CONCURRENT就说明创建的是并行队列，DISPATCH_QUEUE_SERIAL表明你创建的是串行队列。至于两者的区别，还是那句话，下方实例中会给出详细的介绍。
```Swift
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
```
