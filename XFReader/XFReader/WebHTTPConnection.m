//
//  MyHTTPConnection.m
//  Http
//
//  Created by and on 16/3/2.
//  Copyright © 2016年 and. All rights reserved.
//

#import "WebHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"

#import "MultipartFormDataParser.h"
#import "MultipartMessageHeaderField.h"
#import "HTTPDynamicFileResponse.h"
#import "HTTPFileResponse.h"

static const int httpLogLevel = HTTP_LOG_LEVEL_VERBOSE; // | HTTP_LOG_FLAG_TRACE;

@implementation WebHTTPConnection


- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    HTTPLogTrace();
    
    // Add support for POST
    
    
    if ([method isEqualToString:@"POST"])
    {
        if ([path isEqualToString:@"/upload.html"])
        {
            return YES;
        }
        return YES;
    }
    if ([method isEqualToString:@"DELETE"]) {
        return YES;
    }
    return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
    HTTPLogTrace();
    
    // Inform HTTP server that we expect a body to accompany a POST request
    
    if([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload.html"]) {
        // here we need to make sure, boundary is set in header
        NSString* contentType = [request headerField:@"Content-Type"];
        NSUInteger paramsSeparator = [contentType rangeOfString:@";"].location;
        if( NSNotFound == paramsSeparator ) {
            return NO;
        }
        if( paramsSeparator >= contentType.length - 1 ) {
            return NO;
        }
        NSString* type = [contentType substringToIndex:paramsSeparator];
        if( ![type isEqualToString:@"multipart/form-data"] ) {
            // we expect multipart/form-data content type
            return NO;
        }
        
        // enumerate all params in content-type, and find boundary there
        NSArray* params = [[contentType substringFromIndex:paramsSeparator + 1] componentsSeparatedByString:@";"];
        for( NSString* param in params ) {
            paramsSeparator = [param rangeOfString:@"="].location;
            if( (NSNotFound == paramsSeparator) || paramsSeparator >= param.length - 1 ) {
                continue;
            }
            NSString* paramName = [param substringWithRange:NSMakeRange(1, paramsSeparator-1)];
            NSString* paramValue = [param substringFromIndex:paramsSeparator+1];
            
            if( [paramName isEqualToString: @"boundary"] ) {
                // let's separate the boundary from content-type, to make it more handy to handle
                [request setHeaderField:@"boundary" value:paramValue];
            }
        }
        // check if boundary specified
        if( nil == [request headerField:@"boundary"] )  {
            return NO;
        }
        return YES;
    }
    return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    HTTPLogTrace();
    
    if ([path hasPrefix:@"/ajax/list.html"]) {//获取文件列表
        
        NSLog(@"列表");
        NSString* templatePath = [[config documentRoot] stringByAppendingPathComponent:@"/ajax/list.html"];
        NSMutableDictionary *replacementDict = [NSMutableDictionary dictionary];
        
        if ([method isEqualToString:@"DELETE"]) {//删除文件 /ajax/list.html?q=str
            NSLog(@"删除 path = %@",path);
            NSArray *tArr = [[path stringByRemovingPercentEncoding] componentsSeparatedByString:@"="];
            
            if (tArr.count >= 2) {
                if ([self deleteFile:tArr[1]]) {//删除成功
                    NSLog(@"删除成功");
                    [replacementDict setObject:[NSString stringWithFormat:@"<div id='deleteresponse' class='blockdiv'>删除成功</div>%@",[self fileList]] forKey:@"list"];

                }else {
                    NSLog(@"删除失败");
                    [replacementDict setObject:[NSString stringWithFormat:@"<div id='deleteresponse' class='blockdiv'>删除失败</div>%@",[self fileList]] forKey:@"list"];
                }
            }else {
                NSLog(@"参数错误");
                [replacementDict setObject:[NSString stringWithFormat:@"<div id='deleteresponse' class='blockdiv'>参数错误</div>%@",[self fileList]] forKey:@"list"];
            }
        }else {
            [replacementDict setObject:[self fileList] forKey:@"list"];
        }

        
        return [[HTTPDynamicFileResponse alloc] initWithFilePath:templatePath forConnection:self separator:@"%" replacementDictionary:replacementDict];
    }
    
    //POST
    if ([method isEqualToString:@"POST"] && [path hasPrefix:@"/ajax/up.html"]) {
        NSString *postStr = nil;
        
        NSData *postData = [request body];
        if (postData)
        {
            postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        }
        
        HTTPLogVerbose(@"%@[%p]: postStr: %@", THIS_FILE, self, postStr);
        
        // Result will be of the form "answer=..."
        NSData *response = nil;
        response = [postStr dataUsingEncoding:NSUTF8StringEncoding];
        return [[HTTPDataResponse alloc] initWithData:response];
    }
    
    
    
    if ([path isEqualToString:@"/index.html"] || [path isEqualToString:@"/"] || [path hasPrefix:@"/index.html"]) {
        
        NSString* templatePath = [[config documentRoot] stringByAppendingPathComponent:@"index.html"];
        NSMutableDictionary *replacementDict = [NSMutableDictionary dictionary];
        
        [replacementDict setObject:@"哈哈" forKey:@"ceshi"];
        [replacementDict setObject:[self fileList] forKey:@"filess"];
        //        [replacementDict setObject:@"Wifi传书" forKey:@"header"];
        //        [replacementDict setObject:@"wifi传书" forKey:@"title"];
        //        [replacementDict setObject:@"iOS" forKey:@"device"];
        //        [replacementDict setObject:@"拖拽文件到窗口或者点击“上传书籍”按钮选择您要上传的书籍，上传完成后就可以在书架上看到您上传的书啦，赶紧上传吧" forKey:@"prologue"];
        //        [replacementDict setObject:@"Wifi传书1.0" forKey:@"footer"];
        //        [replacementDict setObject:st forKey:@"epilogue"];
        // use dynamic file response to apply our links to response template
        return [[HTTPDynamicFileResponse alloc] initWithFilePath:templatePath forConnection:self separator:@"%" replacementDictionary:replacementDict];
    }
    return [super httpResponseForMethod:method URI:path];
}
/**
 *  根据标题删除文件 1.txt
 */
- (BOOL )deleteFile:(NSString *)title {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSError *error;
    [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/upload/%@",documentDir,title] error:&error];
    if (error) {
        return NO;
    }else {
        return YES;
    }
}

- (NSString *)fileList {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    NSString *uploadFile = [NSString stringWithFormat:@"%@/upload",documentDir];
    //        if (![fileList containsObject:@"upload"]) {//不存在则新建文件夹
    //            [fileManager createDirectoryAtPath:uploadFile attributes:nil];
    //        }
    NSArray *upA = [fileManager directoryContentsAtPath:uploadFile];
    NSMutableString *st = [NSMutableString string];
    /**
     *  <form action="">
     <input type="text" id="txt1" onkeyup="showHint(this.value)" />
     <img id="txt" width='50px' height='50px' onclick=showHint('A') />
     </form>
     */
    [st appendString:@"<table>"];
    for (NSString *ul in upA) {
        [st appendString:@"<tr><td  class='trs'>"];
        [st appendString:ul];
        [st appendString:[NSString stringWithFormat:@"</td><td  class='trs'><button id='imgg' src='/img/close.png' class='imgIcon' onclick=deleteFile('%@') >删除</button></td></tr>",ul]];
    }
    [st appendString:@"</table> <script src='/js.js'> </script>"];
    return st;
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
    HTTPLogTrace();
    
    // set up mime parser
    NSString* boundary = [request headerField:@"boundary"];
    parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    parser.delegate = self;
    
    uploadedFiles = [[NSMutableArray alloc] init];
}

- (void)processBodyData:(NSData *)postDataChunk
{
    HTTPLogTrace();
    // append data to the parser. It will invoke callbacks to let us handle
    // parsed data.
    
    BOOL result = [request appendData:postDataChunk];
//    NSString *postStr = [[NSString alloc] initWithData:postDataChunk encoding:NSUTF8StringEncoding];
//    NSLog(@"post = %@",postStr);
//    if (!result) {
//        NSLog(@"失败");
//    }
}


//-----------------------------------------------------------------
#pragma mark multipart form data parser delegate


- (void) processStartOfPartWithHeader:(MultipartMessageHeader*) header {
    // in this sample, we are not interested in parts, other then file parts.
    // check content disposition to find out filename
    
    MultipartMessageHeaderField* disposition = [header.fields objectForKey:@"Content-Disposition"];
    NSString* filename = [[disposition.params objectForKey:@"filename"] lastPathComponent];
    
    if ( (nil == filename) || [filename isEqualToString: @""] ) {
        // it's either not a file part, or
        // an empty form sent. we won't handle it.
        return;
    }
    //    NSString* uploadDirPath = [[config documentRoot] stringByAppendingPathComponent:@"upload"];
    NSString* uploadDirPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/upload"];
    
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager]fileExistsAtPath:uploadDirPath isDirectory:&isDir ]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:uploadDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString* filePath = [uploadDirPath stringByAppendingPathComponent: filename];
    if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
        storeFile = nil;
    }
    else {
        HTTPLogVerbose(@"Saving file to %@", filePath);
        if(![[NSFileManager defaultManager] createDirectoryAtPath:uploadDirPath withIntermediateDirectories:true attributes:nil error:nil]) {
            HTTPLogError(@"Could not create directory at path: %@", filePath);
        }
        if(![[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
            HTTPLogError(@"Could not create file at path: %@", filePath);
        }
        storeFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [uploadedFiles addObject: [NSString stringWithFormat:@"/upload/%@", filename]];
    }
}


- (void) processContent:(NSData*) data WithHeader:(MultipartMessageHeader*) header
{
    // here we just write the output from parser to the file.
    if( storeFile ) {
        [storeFile writeData:data];
    }
}

- (void) processEndOfPartWithHeader:(MultipartMessageHeader*) header
{
    // as the file part is over, we close the file.
    [storeFile closeFile];
    storeFile = nil;
}

- (void) processPreambleData:(NSData*) data
{
    // if we are interested in preamble data, we could process it here.
    
}

- (void) processEpilogueData:(NSData*) data
{
    // if we are interested in epilogue data, we could process it here.
    
}


@end
