//
//  ViewController.m
//  XFReader
//
//  Created by and on 16/3/9.
//  Copyright © 2016年 and. All rights reserved.
//

#import "ViewController.h"
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "MyHTTPConnection.h"

#include <ifaddrs.h>
#include <arpa/inet.h>

#import "WebHTTPConnection.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;


@interface ViewController ()

@property (strong, nonatomic) HTTPServer *httpServer;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startServer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.httpServer stop];
}

- (void)dealloc {
    _httpServer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setServer];
    
    _addressLabel.text = [NSString stringWithFormat:@"确保电脑与手机在同一wifi网络下\n在电脑浏览器地址栏输入\nhttp://%@:%@",[self deviceIPAdress],@"8080"];

}

- (void)startServer
{
    // Start the server (and check for problems)
    
    NSError *error;
    if([self.httpServer start:&error]){
        DDLogInfo(@"成功 Started HTTP Server on port %hu %@", [self.httpServer listeningPort],self.httpServer.domain);
    }else{
        DDLogError(@"失败 Error starting HTTP Server: %@", error);
    }
}

- (void)setServer {
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    self.httpServer = [[HTTPServer alloc] init];//初始化
    
    [self.httpServer setType:@"_http._tcp."];//通过Bonjour服务发布的类型,允许浏览器访问
    [self.httpServer setPort:8080];//设置端口
    [self.httpServer setConnectionClass:[WebHTTPConnection class]];//设置处理连接的自定义类文件
    
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
    DDLogInfo(@"Setting document root: %@", webPath);
    
    [self.httpServer setDocumentRoot:webPath];//设置服务器根目录
    NSLog(@"home = %@",NSHomeDirectory());
}

- (NSString *)deviceIPAdress {
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    
    NSLog(@"手机的IP是：%@", address);
    return address;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
