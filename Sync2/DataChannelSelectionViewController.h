//
//  DataChannelSelectionViewController.h
//  Sync2
//
//  Created by Ricky Kirkendall on 1/15/18.
//  Copyright © 2018 Sixgill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataChannelSelectionViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *selectChannelButton;

@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, readwrite) BOOL useDummy;

- (IBAction)selectChannelButtonTapped:(id)sender;

@end
