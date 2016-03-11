//
//  WebHTTPConnection.h
//  XFReader
//
//  Created by and on 16/3/10.
//  Copyright © 2016年 and. All rights reserved.
//

#import "HTTPConnection.h"
@class MultipartFormDataParser;

@interface WebHTTPConnection : HTTPConnection
{
    MultipartFormDataParser*        parser;
    NSFileHandle*					storeFile;
    
    NSMutableArray*					uploadedFiles;
}
@end
