//
//  BankViewController.m
//  Gecko iOS
//
//  Created by Master on 8/20/14.
//  Copyright (c) 2014 Zipline, inc. All rights reserved.
//

#import "BankViewController.h"
#import "PersonalInfoCell.h"
@interface BankViewController ()

@end

@implementation BankViewController
- (IBAction)done:(id)sender {
    [self.view endEditing:YES];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.addresses = [[NSArray alloc] init];

    UIButton *saveChanges = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveChanges setFrame:CGRectMake(0, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 70, self.view.frame.size.width, 50)];
    [saveChanges addTarget:self
               action:@selector(save)
     forControlEvents:UIControlEventTouchUpInside];
    saveChanges.backgroundColor = [UIColor colorWithRed:148.0/255 green:221.0/255 blue:204.0/255 alpha:1];
    [saveChanges setTitle:@"SAVE CHANGES" forState:UIControlStateNormal];
    [saveChanges setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.view addSubview:saveChanges];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) save{
    BankAccount *new = [[BankAccount alloc] init];
    CreateBankAccountCell *routing = (CreateBankAccountCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    new.routing = routing.mainInfo.text;
    NSLog(@"%@", routing.mainInfo.text);
    CreateBankAccountCell *name = (CreateBankAccountCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    new.name = name.mainInfo.text;
    NSLog(@"%@", name.mainInfo.text);
    CreateBankAccountCell *number = (CreateBankAccountCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
    new.account = number.mainInfo.text;
    NSLog(@"%@", name.mainInfo.text);
    //CreateBankAccountCell *number = (CreateBankAccountCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    //new.account = number.mainInfo.text;
    //NSLog(@"%@", name.mainInfo.text);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 3;
    if(section == 1)
        return _addresses.count + 1;
    if (section == 2)
        return 3;
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        if(indexPath.row == 0){
            CreateBankAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"routingCell" forIndexPath:indexPath];
            return cell;
        }
        if(indexPath.row == 1){
            CreateBankAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nameCell" forIndexPath:indexPath];
            return cell;
        }
        if(indexPath.row == 2){
            CreateBankAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountCell" forIndexPath:indexPath];
            return cell;
        }
    }
    else if(indexPath.section == 1){
        if(indexPath.row == self.addresses.count){
            CreateBankAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addAddressCell" forIndexPath:indexPath];
            return cell;
        }
    }
    else{
        if (indexPath.row == 0){
            CreateBankAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"streetCell" forIndexPath:indexPath];
            return cell;
        }
        else if (indexPath.row == 1){
            CreateBankAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cityCell" forIndexPath:indexPath];
            return cell;
        }
        else{
            CreateBankAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"zipcodeCell" forIndexPath:indexPath];
            return cell;
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

- (NSString*) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0)
        return @"WHAT BANK DO YOU USE?";
    if (section == 1)
        return @"USE ACCOUNT ADDRESS";
    if (section == 2)
        return @"MAILING ADDRESS";
    return @" ";
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
