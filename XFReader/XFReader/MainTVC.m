//
//  MainTVC.m
//  XFReader
//
//  Created by and on 16/3/10.
//  Copyright © 2016年 and. All rights reserved.
//

#import "MainTVC.h"

#import "FileItemModel.h"
#import "DetailVC.h"
@interface MainTVC ()

@property (strong, nonatomic) NSMutableArray *dataSource;


@end

@implementation MainTVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSArray *files = [self blFiles];
    //[_dataSource setArray:files];
    //[self blFileItems:[NSString stringWithFormat:@"%@/%@",[self filesPath],_dataSource[0]]];
    [_dataSource removeAllObjects];
    for (NSString *title in files) {
        FileItemModel *model = [self blFileItems:title];
        if ([model.type isEqualToString:@".no"]) {
            continue;
        }
        [_dataSource addObject:model];
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSource = [NSMutableArray array];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}
/**
 *  根据文件目录，获取文件大小，等
 NSFileCreationDate = "2016-03-10 02:54:29 +0000";
 NSFileExtensionHidden = 0;
 NSFileGroupOwnerAccountID = 20;
 NSFileGroupOwnerAccountName = staff;
 NSFileModificationDate = "2016-03-10 02:54:29 +0000";
 NSFileOwnerAccountID = 501;
 NSFilePosixPermissions = 420;
 NSFileReferenceCount = 1;
 NSFileSize = 292486;
 NSFileSystemFileNumber = 32630918;
 NSFileSystemNumber = 16777220;
 NSFileType = NSFileTypeRegular;
 */
- (FileItemModel *)blFileItems:(NSString *)title {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [NSString stringWithFormat:@"%@/%@",[self filesPath],title];
    NSDictionary *attr = [fm attributesOfItemAtPath:path error:nil];
    FileItemModel *model = [[FileItemModel alloc] init];
    
    model.path = path;
    model.size = [self filesizeFromFloat:[[attr objectForKey:@"NSFileSize"] floatValue]];
    
    NSArray *typeArr = [title componentsSeparatedByString:@"."];
    model.title = [title stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",typeArr[typeArr.count - 1]] withString:@""];
    if (typeArr.count < 2 || typeArr[0] == nil || [typeArr[0] isEqualToString:@""]) {
        model.type = @".no";
    }else {
        model.type = typeArr[1];
    }
    //model.size = [NSString stringWithFormat:@"%@",[attr objectForKey:@"NSFileSize"]];
    model.pic = @"home_horn_new";
    return model;
}

- (NSString *)filesizeFromFloat:(float)size {
    int m = size / 1024 / 1024;
    float k = ((int)size % 1024) / 1024 / 1024;
    NSString *sizeStr = @"";
    if (m == 0 && k <= 0) {//不足1k
        sizeStr = [NSString stringWithFormat:@"%.2fk",size / 1024];
    }else if (m == 0 && k > 0) {
        sizeStr = [NSString stringWithFormat:@"%.2fk",size / 1024];
    }else {
        sizeStr = [NSString stringWithFormat:@"%.2fM",size / 1024 / 1024];
    }
    return sizeStr;
}

/**
 *  获取文件夹下所有文件目录
 *
 *  @return 文件目录
 */
- (NSArray *)blFiles {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm subpathsAtPath:[self filesPath]];
    return files;
}

//返回文件路径
- (NSString *)filesPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filesPath = [documentsDirectory stringByAppendingPathComponent:@"upload"];
    return filesPath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mainCell" forIndexPath:indexPath];
    
    FileItemModel *model = _dataSource[indexPath.row];
    // Configure the cell...
    cell.textLabel.text = model.title;
    cell.detailTextLabel.text = model.size;
    cell.imageView.image = [UIImage imageNamed:model.pic];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 }


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    FileItemModel *model = _dataSource[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //删除文件
        [self deleteFileWithPath:model.path];
        //删除数据源
        [_dataSource removeObjectAtIndex:indexPath.row];
        //从tableView中移除此项
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        
    }   
}

/**
 *  删除文件
 */
- (void)deleteFileWithPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
}
/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UIViewController *destination = segue.destinationViewController;
    if ([destination isKindOfClass:[DetailVC class]]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        FileItemModel *model = _dataSource[indexPath.row];
        DetailVC *detail = (DetailVC *)destination;
        detail.model = model; 
    }
    

}


@end
