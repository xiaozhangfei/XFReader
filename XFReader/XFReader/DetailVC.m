//
//  DetailVC.m
//  XFReader
//
//  Created by and on 16/3/10.
//  Copyright © 2016年 and. All rights reserved.
//

#import "DetailVC.h"
#import "FileItemModel.h"
@interface DetailVC ()
{
    NSInputStream *inputStream;
}

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation DetailVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [inputStream open];

    //进入时，确定读入
    [self loadFileContentsIntoTextView];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [inputStream close];
    inputStream = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _model.title;
    
    
    NSError *error;
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    float fontSize = 16.0;
    
    
    
//    NSString *content = [NSString stringWithContentsOfFile:_model.path encoding:enc error:&error];
//    if (content == nil) {
//        NSLog(@"error = %@",[error localizedDescription]);
//    }else {
//        self.textView.text = content;
//    }
    
    //通过流打开一个文件
    
    //NSInputStream *
    inputStream = [[NSInputStream alloc] initWithFileAtPath:_model.path];
    

    
}

- (IBAction)nextPage:(id)sender {
    [self loadFileContentsIntoTextView];
    
}

//读取文件内容操作
- (void) loadFileContentsIntoTextView{

    NSInteger maxLength = 400;
    uint8_t readBuffer [maxLength];
    //是否已经到结尾标识
    BOOL endOfStreamReached = NO;
    // NOTE: this tight loop will block until stream ends
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    if (1) {
        NSInteger bytesRead = [inputStream read: readBuffer maxLength:maxLength];
        if (bytesRead == 0) {//文件读取到最后
            endOfStreamReached = YES;
            NSLog(@"已经最后一页了");

        }else if (bytesRead == -1){//文件读取错误
            endOfStreamReached = YES;
            NSLog(@"读取错误");
        }else {
            NSString *readBufferString =[[NSString alloc] initWithBytesNoCopy: readBuffer length: bytesRead encoding: enc freeWhenDone: NO];
            //将字符不断的加载到视图
            [self appendTextToView: readBufferString];
        }
    }
}

- (void)appendTextToView:(NSString *)string {
    self.textView.text = string;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
