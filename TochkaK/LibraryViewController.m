
//  LibraryViewController.m
//  TochkaK
//
//  Created by Alexandra Vtyurina on 08/03/14.
//
//

#import "LibraryViewController.h"


@interface LibraryViewController ()
@property (strong, nonatomic) NSArray *books;
@property (strong, nonatomic) LibraryManager *manager;

@property (strong, nonatomic) UINavigationBar *navigationBar;
//@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) LibraryDetailedBookViewController *currentDetailedVC;

@property (weak, nonatomic) IBOutlet UITableView *tableViewOutlet;

@end

@implementation LibraryViewController

//- (UITableView *)tableView {
//    if (!_tableView) {
//        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 410)];
//    }
//    return _tableView;
//}

- (UINavigationBar *)navigationBar {
    if (!_navigationBar) {
        _navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    }
    return _navigationBar;
}

- (LibraryManager *)manager {
    return [LibraryManager sharedManager];
}

- (LibraryDetailedBookViewController *)currentDetailedVC {
    if (!_currentDetailedVC) {
        //_currentDetailedVC = [[LibraryDetailedBookViewController alloc] init];
        _currentDetailedVC = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailedBookViewController"];//@"TestViewController"];
    }
    return _currentDetailedVC;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"did load");
//    [self.view addSubview:self.tableView];
//    
    [self.manager requestBooksList];
//
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadUI)
                                                 name:@"BOOKS_RETRIEVED"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(repopulateCurrentDetailedVC)
                                                 name:BookDetailsIsReadyToBePresented
                                               object:nil];
    self.tableViewOutlet.delegate = self;
    self.tableViewOutlet.dataSource = self;
}

- (void)repopulateCurrentDetailedVC {
    
    UITabBarController *parent = self.tabBarController;
    NSInteger selectedIndex = parent.selectedIndex;
    NSInteger myIndex = [parent.viewControllers indexOfObject:self.navigationController];
    
    if (selectedIndex == myIndex) {
        self.currentDetailedVC.bookToShow = [[LibraryManager sharedManager] requestedBook];
        [self.currentDetailedVC updateUI];
    }
}
- (void)reloadUI {
    self.books = [self.manager.books sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        switch (self.order) {
            case TITLE: {
                NSString* s1 = [obj1 valueForKey:@"title"];
                NSString* s2 = [obj2 valueForKey:@"title"];
                return [s1 compare:s2];
                break;
            }
            case AUTHOR_TITLE: {
                NSString* s1 = [obj1 valueForKey:@"authorTitle"];
                NSString* s2 = [obj2 valueForKey:@"authorTitle"];
                if ([s1 isEqual:[NSNull null]]) { s1 = @""; }
                if ([s2 isEqual:[NSNull null]]) { s2 = @""; }
                return [s1 compare:s2];
                break;
            }
            case PRICE: {
                BOOL b1 = [[obj1 valueForKey:@"free"] boolValue];
                BOOL b2 = [[obj2 valueForKey:@"free"] boolValue];
                if (!b1 && b2) return NSOrderedDescending;
                if (b1 && !b2) return NSOrderedAscending;
                return NSOrderedSame;
                break;
            }
            default:
                break;
        }
    }];
//    [self.tableView reloadData];
    [self.tableViewOutlet reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSString *title =  [[self.books objectAtIndex:[indexPath row]] valueForKey:@"title"];
    
    if ([title isEqual:[NSNull null]]) { title = @"Unknown name"; }
    
    cell.textLabel.text = title;
    
    NSString *authorTitle =  [[self.books objectAtIndex:[indexPath row]] valueForKey:@"authorTitle"];
    if ([authorTitle isEqualToString:@""]) { authorTitle = @"Unknown author"; }
    
    BOOL free = [[[self.books objectAtIndex:[indexPath row]] valueForKey:@"free"] boolValue];
    NSString *price = free ? @"бесплатная" : @"платная";
    
    cell.detailTextLabel.text =  [NSString stringWithFormat:@"%@, %@", authorTitle, price];
    cell.selected = NO;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LibraryBook *book = [self.books objectAtIndex:indexPath.row];
    
    //how can self.manager be a nil?! it's a singleton
    [[LibraryManager sharedManager] requestDetailedBookWithID:book.ID];
    
    [self.navigationController pushViewController:self.currentDetailedVC animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.books.count;
}

@end
