//
//  SecondViewController.m
//  MultipeerChat
//
//  Created by user on 6/23/14.
//  Copyright (c) 2014 someCompanyNameHere. All rights reserved.
//

#import "FileShareViewController.h"
#import "MultipeerManager.h"

@interface FileShareViewController ()< UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate >

@property (weak, nonatomic) IBOutlet UITableView *fileTableView;
@property (nonatomic)MultipeerManager* multipeerManager;
@property (nonatomic)NSString* documentsDirectory;
@property (nonatomic)NSMutableArray* files;
@property (nonatomic)NSArray* getAllDocDirFiles;
@property (nonatomic)NSString* selectedFile;
@property (nonatomic)NSInteger selectedRow;

@end

@implementation FileShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self copySampleFilesToDocumentsDirectoryIfNecessary];
    self.files = [[NSMutableArray alloc]initWithArray:[self getAllDocDirFiles]];
    [self.fileTableView reloadData];
}

#pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.files.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"newFileCellIdentifier"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"newFileCellIdentifier"];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }

    cell.textLabel.text = self.files[indexPath.item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* selectedFile = self.files[indexPath.item];
    UIActionSheet* confirmSending = [[UIActionSheet alloc]initWithTitle:selectedFile
                                                            delegate:(id)self
                                                   cancelButtonTitle:nil
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:nil];
    
    for (int i = 0; i < [[self.multipeerManager.session connectedPeers]count]; i++)
    {
        [confirmSending addButtonWithTitle:[[[self.multipeerManager.session connectedPeers] objectAtIndex:i] displayName]];
    }
    
    [confirmSending setCancelButtonIndex:[confirmSending addButtonWithTitle:@"Cancel"]];
    [confirmSending showInView:self.view];
    self.selectedFile = [self.files objectAtIndex:indexPath.item];
    self.selectedRow = indexPath.row;

}

#pragma mark - custom methods

- (NSArray*)getAllDocDirFiles
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error;
    
    NSArray* files = [fileManager contentsOfDirectoryAtPath:_documentsDirectory error:&error];
    if (error)
    {
        NSLog(@"error: %@",[error userInfo]);
    }
    
    return files;
}

- (void)copySampleFilesToDocumentsDirectoryIfNecessary
{
    NSArray* searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    self.documentsDirectory = [[NSString alloc]initWithString:[searchPaths firstObject]];
    
    NSString* file1Path = [self.documentsDirectory stringByAppendingPathExtension:@"sample_file1.txt"];
    NSString* file2Path = [self.documentsDirectory stringByAppendingPathExtension:@"sample_file2.txt"];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error;
    
    if (![fileManager fileExistsAtPath:file1Path] || ![fileManager fileExistsAtPath:file2Path])
    {
        [fileManager copyItemAtPath:[[NSBundle mainBundle]pathForResource:@"sample_file1" ofType:@"txt"]
                                                                   toPath:file1Path
                              error:&error];
        
        if (error) {
            NSLog(@"error: %@", [error userInfo]);
        }
        
        [fileManager copyItemAtPath:[[NSBundle mainBundle]pathForResource:@"sample_file2" ofType:@"txt"]
                             toPath:file1Path
                              error:&error];
        
        if (error) {
            NSLog(@"error: %@", [error userInfo]);
        }
    }
}

@end
