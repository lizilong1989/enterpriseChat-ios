//
//  ECBaseTableViewController.m
//  enterpriseChat
//
//  Created by dujiepeng on 15/7/29.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "ECBaseTableViewController.h"
#import "RealtimeSearchUtil.h"
#import "EMSearchDisplayController.h"
@interface ECBaseTableViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (nonatomic, strong) NSMutableArray *tempDatasource;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) EMSearchDisplayController *searchController;
@end

@implementation ECBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    if (self.isNeedSearch) {
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = @"test";
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}

#pragma mark - searchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    self.tempDatasource = [self.datasource mutableCopy];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    self.datasource = [self.tempDatasource mutableCopy];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    __weak typeof(self) weakSelf = self;
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.tempDatasource
                                                    searchText:(NSString *)searchText
                                       collationStringSelector:@selector(searchKey)
                                                   resultBlock:^(NSArray *results)
     {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.datasource removeAllObjects];
                [weakSelf.datasource addObjectsFromArray:results];
                weakSelf.searchController.resultsSource = [self.datasource copy];
                [weakSelf.searchController.searchResultsTableView reloadData];
            });
        }
    }];
}

#pragma mark - getter
-(UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.delegate = self;
    }
    
    return _searchBar;
}

-(EMSearchDisplayController *)searchDisplayController{
    if (!_searchController) {
        __weak typeof(self) weakSelf = self;
        _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar
                                                              contentsController:self];
        [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            return [weakSelf tableView:tableView cellForRowAtIndexPath:indexPath];
        }];
        
        [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
            return [weakSelf tableView:tableView heightForRowAtIndexPath:indexPath];
        }];
        
        [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            [weakSelf tableView:tableView didSelectRowAtIndexPath:indexPath];
        }];
        
        [_searchController setSearchDisplayControllerDidEndSearch:^(UISearchDisplayController *controller) {
            [weakSelf.tableView setContentOffset:CGPointMake(0, -64) animated:YES];
        }];
    }
    
    return _searchController;
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 49)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    
    return _tableView;
}

#pragma mark - getter
-(NSMutableArray *)datasource{
    if (!_datasource) {
        _datasource = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return _datasource;
}


@end
