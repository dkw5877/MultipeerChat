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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didStartReceivingResourceWithNotification:) name:@"MCdidStartReceivingResourceNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateReceivingProgressWithNotification:) name:@"MCReceivingProgressNotification" object:nil];
}

#pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.files.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    //check the type of entry in the array and generate the cell accordingly.
    if ([self.files[indexPath.row] isKindOfClass:[NSString class]])
    {
        //create a standard table cell
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
        
        if (!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        
        //set the file name as the cell label
        cell.textLabel.text = self.files[indexPath.row];
        
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"newFileCellIdentifier"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"newFileCellIdentifier"];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        
        NSDictionary* fileData = self.files[indexPath.item];
        NSString* fileName = fileData[@"resourceName"];
        NSString* peerID = fileData[@"peerID"];
        NSProgress* progress = fileData[@"progress"];
        
        [(UILabel*)[cell viewWithTag:100]setText:fileName];
        [(UILabel*)[cell viewWithTag:200]setText:peerID];
        [(UIProgressView*)[cell viewWithTag:300]setProgress:progress.fractionCompleted];
        
    }
    
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

#pragma mark - UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [[self.multipeerManager.session connectedPeers]count])
    {
        NSString* filePath = [self.documentsDirectory stringByAppendingPathComponent:self.selectedFile];
        NSString* modifiedName = [NSString stringWithFormat:@"%@ %@",self.multipeerManager.peerId.displayName, self.selectedFile];
        NSURL* url = [NSURL URLWithString:filePath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSProgress* progress = [self.multipeerManager.session sendResourceAtURL:url withName:modifiedName toPeer:[[self.multipeerManager.session connectedPeers] objectAtIndex:buttonIndex] withCompletionHandler:^(NSError *error) {
                if (error)
                {
                    NSLog(@"error: %@", [error userInfo]);
                }
                else
                {
                    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"File Transfer" message:@"File sent successfully" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Great!",nil];
                    
                    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                    [self.files replaceObjectAtIndex:self.selectedRow withObject:self.selectedFile];
                    [self.fileTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                }
            }];
            
            [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
        });
    }
}

#pragma mark -  KVO related method

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString* sendingMessage = [NSString stringWithFormat:@"%@ - Sending %.f%%",self.selectedFile, [(NSProgress*)object fractionCompleted] * 100];
    
    //update the file array
    [self.files replaceObjectAtIndex:self.selectedRow withObject:sendingMessage];
    
    //reload data on the main thread
    [self.fileTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark -  NSNotificationCenterRelated Method
- (void)didStartReceivingResourceWithNotification:(NSNotification*)notification
{
    [self.files addObject:[notification userInfo]];
    
    //reload the table on the main thread
    [self.fileTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)updateReceivingProgressWithNotification:(NSNotification*)notification
{
    
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
        
        if (error)
        {
            NSLog(@"error: %@", [error userInfo]);
        }
        
        [fileManager copyItemAtPath:[[NSBundle mainBundle]pathForResource:@"sample_file2" ofType:@"txt"]
                             toPath:file1Path
                              error:&error];
        
        if (error)
        {
            NSLog(@"error: %@", [error userInfo]);
        }
    }
}

@end
