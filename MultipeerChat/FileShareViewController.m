//
//  SecondViewController.m
//  MultipeerChat
//
//  Created by user on 6/23/14.
//  Copyright (c) 2014 someCompanyNameHere. All rights reserved.
//

#import "FileShareViewController.h"

@interface FileShareViewController ()< UITableViewDataSource, UITableViewDelegate >
@property (weak, nonatomic) IBOutlet UITableView *fileTableView;

@end

@implementation FileShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"newFileCellIdentifier"];
    return cell;
}

@end
