//
//  ViewController.m
//  RunLoopSourceTest
//
//  Created by hanliqiang on 17/2/21.
//  Copyright © 2017年 ustb. All rights reserved.
//

#import "ViewController.h"

static UIColor *customColor;

static void performSourceEvent (void *info){
    
    printf("runLoopSource Have Run Source唤醒主线程工作\n");
    customColor = [UIColor colorWithRed:(random()%255)/255.0 green:(random()%255)/255.0 blue:(random()%255)/255.0 alpha:1];
}



@interface ViewController ()
@property (nonatomic, strong) UIButton *ustbCustomBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    
    
    CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent();
    //添加观察者
    
    
    
    //添加数据源
    CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, performSourceEvent};
    
    CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    
    
    CFRunLoopAddSource(currentRunLoop, source, kCFRunLoopDefaultMode);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xiaoxi) name:@"hh" object:nil];
    
    
    //开辟常驻线程
    dispatch_queue_t q = dispatch_queue_create("ustbQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(q, ^{
        
//        __block NSInteger totaleNumer = 10;
        
        //自定义定时源
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//            totaleNumer--;
//            if (totaleNumer == 0) {
//                CFRunLoopStop(CFRunLoopGetCurrent());
//            }
            NSLog(@"runLoop run!!");
            //发source消息通知主线程工作
            CFRunLoopSourceSignal(source);
            CFRunLoopWakeUp(currentRunLoop);
            //发消息通知主线程工作(消息也是线程通信的一种方式)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hh" object:nil];
        }];
        //添加定时源
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]];
        
        NSLog(@"stop");
        
    });
    
    
    
    
    //添加button
    self.view.backgroundColor = [UIColor whiteColor];
    self.ustbCustomBtn = [UIButton buttonWithType:0];
    [self.view addSubview:self.ustbCustomBtn];
    self.ustbCustomBtn.frame = CGRectMake(10, 100, 200, 200);
    self.ustbCustomBtn.backgroundColor = [UIColor yellowColor];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self createRunLoopObserverWithObserverType:kCFRunLoopBeforeWaiting];
    [self createRunLoopObserverWithObserverType:kCFRunLoopEntry];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self createRunLoopObserverWithObserverType:kCFRunLoopBeforeWaiting];
    [self createRunLoopObserverWithObserverType:kCFRunLoopEntry];
}

- (void)xiaoxi
{
    
    NSLog(@"消息通知主线程工作");
}
- (void)createRunLoopObserverWithObserverType:(CFOptionFlags)flag
{
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFStringRef runLoopMode = kCFRunLoopDefaultMode;
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler
    (kCFAllocatorDefault, flag, true, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity _activity) {
        
        switch (_activity) {
            case kCFRunLoopEntry:
            {
                NSLog(@"即将进入Loop");
            }
                break;
            case kCFRunLoopBeforeTimers:
            {
                NSLog(@"即将处理 Timer");
                break;
            }
            case kCFRunLoopBeforeSources:
                NSLog(@"即将处理 Source");
                break;
            case kCFRunLoopBeforeWaiting:
                
                self.ustbCustomBtn.backgroundColor = customColor;
                
                NSLog(@"即将进入休眠");
                ;
                break;
            case kCFRunLoopAfterWaiting:
                NSLog(@"刚从休眠中唤醒");
                break;
            case kCFRunLoopExit:
                NSLog(@"即将退出Loop");
                break;
            default:
                break;
        }
    });
    CFRunLoopAddObserver(runLoop, observer, runLoopMode);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
