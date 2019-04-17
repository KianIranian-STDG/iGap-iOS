//
//  KPDropMenu.m
//  KPDropMenu
//
//  Created by Krishna Patel on 22/03/17.
//  Copyright © 2017 Krishna. All rights reserved.
//

#import "KPDropMenu.h"

@interface KPDropMenu () <UITableViewDelegate, UITableViewDataSource>
{
    int SelectedIndex;
    UITableView *tblView;
	UIRefreshControl *refreshControl;
    UIFont *selectedFont, *font, *itemFont;
    BOOL isCollapsed;
    UITapGestureRecognizer *tapGestureBackground;
    UILabel *label;
	UIImageView *imgV;
	
	CGRect frame;
	
}
@end

@implementation KPDropMenu

- (instancetype)init {
    if (self = [super init])
        [self initLayer];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder])
        [self initLayer];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame])
        [self initLayer];
    return self;
}

- (void)initLayer {
    
    SelectedIndex = 0;
    isCollapsed = TRUE;
    _itemTextAlignment = _titleTextAlignment = NSTextAlignmentCenter;
    _titleColor = [UIColor blackColor];
    _titleFontSize = 14.0;
    _itemHeight = 60.0;
    _itemBackground = [UIColor whiteColor];
    _itemTextColor = [UIColor blackColor];
    _itemFontSize = 14.0;
    _itemsFont = [UIFont systemFontOfSize:14.0];
    _DirectionDown = YES;
	
}

#pragma mark - Setter

-(void)setTitle:(NSString *)title{
    _title = title;
}

-(void)setTitleTextAlignment:(NSTextAlignment)titleTextAlignment{
    if(titleTextAlignment)
        _titleTextAlignment = titleTextAlignment;
}

-(void)setItemTextAlignment:(NSTextAlignment)itemTextAlignment{
    if(itemTextAlignment)
        _itemTextAlignment = itemTextAlignment;
}

-(void)setTitleColor:(UIColor *)titleColor{
    if(titleColor)
        _titleColor = titleColor;
}

-(void)setTitleFontSize:(CGFloat)titleFontSize{
    if(titleFontSize)
        _titleFontSize = titleFontSize;
    
}

-(void)setItemHeight:(double)itemHeight{
    if(itemHeight)
        _itemHeight = itemHeight;
}

-(void)setItemBackground:(UIColor *)itemBackground{
    if(itemBackground)
        _itemBackground = itemBackground;
}

-(void)setItemTextColor:(UIColor *)itemTextColor{
    if(itemTextColor)
        _itemTextColor = itemTextColor;
}

-(void)setItemFontSize:(CGFloat)itemFontSize{
    if(itemFontSize)
        _itemFontSize = itemFontSize;
}

-(void)setItemsFont:(UIFont *)itemFont1{
    if(itemFont1)
        _itemsFont = itemFont1;
}

-(void)setDirectionDown:(BOOL)DirectionDown{
    _DirectionDown = DirectionDown;
}

#pragma mark - Setups

-(void)layoutSubviews{
    [super layoutSubviews];
    
//    self.layer.cornerRadius = 4;
//    self.layer.borderColor = [[UIColor grayColor] CGColor];
//    self.layer.borderWidth = 1;
	
    if(label == nil){
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        label.textColor = _titleColor;
        label.text = _title;
        label.textAlignment = _titleTextAlignment;
        label.font = font;
		label.layer.cornerRadius = self.frame.size.height / 2;
        [self addSubview:label];
    }
	
	if (imgV ==nil) {
		imgV = [[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 25, 25)];
		[self addSubview:imgV];
	}
	
	imgV.image = _backgroundImage;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self addGestureRecognizer:tapGesture];
	
	if (_superView == nil) {
		_superView = self.superview;
		if(_DirectionDown)
			frame = CGRectMake(self.superview.frame.origin.x,  self.superview.frame.size.height + self.superview.frame.origin.y , [UIScreen mainScreen].bounds.size.width, 0);
		else
			frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,[UIScreen mainScreen].bounds.size.width, 0);
		
	}
	else {
		if(_DirectionDown)
			frame = CGRectMake(_superView.frame.origin.x, self.superview.frame.size.height + self.superview.frame.origin.y + _superView.frame.origin.y, _superView.frame.size.width, 0);
		else
			frame = CGRectMake(_superView.frame.origin.x, _superView.frame.origin.y, _superView.frame.size.width, 0);

	}
	
	refreshControl = [[UIRefreshControl alloc]init];

	tblView = [[UITableView alloc] initWithFrame:frame] ;
	
	tblView.delegate = self;
	tblView.dataSource = self;
	tblView.backgroundColor = _itemBackground;
	tblView.separatorColor = [UIColor clearColor];
	[tblView addSubview:refreshControl];
	[refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];

}

- (void)refreshTable {
		//TODO: refresh your data
	
	if([_delegate respondsToSelector:@selector(refresh:)])
		[_delegate refresh:^(void) {
            [self->refreshControl endRefreshing];
            [self->tblView reloadData];
		}];
}

-(void)didTap : (UIGestureRecognizer *)gesture {
    isCollapsed = !isCollapsed;
    if(!isCollapsed) {
		CGFloat height = (CGFloat)(_items.count > 5 ? _itemHeight * 5 : _itemHeight * (double)(_items.count + 1));
        
        tblView.layer.zPosition = 1;
        [tblView removeFromSuperview];
        tblView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        tblView.layer.borderWidth = 1;
        tblView.layer.cornerRadius = 4;
		
        [_superView addSubview:tblView];
		[tblView reloadData];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            if(self->_DirectionDown) {
                self->frame.size.height = height;
                self->tblView.frame = self->frame;
			}
			else {
                self->frame.size.height = height;
                self->tblView.frame = self->frame;
			}
        }];
        
        if(_delegate != nil){
            if([_delegate respondsToSelector:@selector(didShow:)])
                [_delegate didShow:self];
        }
        
        UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        view.tag = 99121;
        [_superView insertSubview:view belowSubview:tblView];
        
        tapGestureBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBackground:)];
        [view addGestureRecognizer:tapGestureBackground];
        
    }
    else{
        [self collapseTableView];
    }
}

-(void)didTapBackground : (UIGestureRecognizer *)gesture {
    isCollapsed = TRUE;
    [self collapseTableView];
}

-(void)collapseTableView{
    if(isCollapsed){
        [UIView animateWithDuration:0.25 animations:^{
            
            if(self->_DirectionDown) {
                self->frame.size.height = 0;
                self->tblView.frame = self->frame;
			}
			else {
                self->frame.size.height = 0;
                self->tblView.frame = self->frame;
			}
        }];
        
        [[_superView viewWithTag:99121] removeFromSuperview];
        
        if(_delegate != nil){
            if([_delegate respondsToSelector:@selector(didHide:)])
                [_delegate didHide:self];
        }
		SelectedIndex = 0;
    }
}

#pragma mark - UITableView's Delegate and Datasource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
	
	NSDictionary *dic = _items[indexPath.row];
	cell.backgroundColor = [UIColor lightTextColor];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
	cell.textLabel.text = dic[@"name"];
	
	cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
	NSString *userType = @"";

	userType = dic[@"role"];
	cell.detailTextLabel.text = userType;
	
	cell.imageView.layer.cornerRadius = 46/2;
	cell.imageView.layer.masksToBounds = true;
	cell.imageView.clipsToBounds = true;
	cell.imageView.image = [self image:dic[@"image"] ScaledToSize:CGSizeMake(46, 46)];

    cell.textLabel.font = _itemsFont;
    cell.textLabel.textColor = _itemTextColor;
	cell.detailTextLabel.font = _itemsFont;
	cell.detailTextLabel.textColor = [UIColor grayColor];
	
    if (indexPath.row == SelectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.textLabel.textColor = _titleColor;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.backgroundColor = _itemBackground;
    cell.tintColor = self.tintColor;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _itemHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SelectedIndex = (int)indexPath.row;
//    label.text = _items[SelectedIndex];
	
//    if(_itemsIDs.count > 0)
//        self.tag = [_itemsIDs[SelectedIndex] integerValue];
	
    if(_delegate != nil){
        if([_delegate respondsToSelector:@selector(didSelectItem:atIndex:)])
            [_delegate didSelectItem:self atIndex:SelectedIndex];
		
		isCollapsed = TRUE;
		[self collapseTableView];
    }
    
}

- (UIImage*)image:(UIImage *)image ScaledToSize:(CGSize)size {
	UIGraphicsBeginImageContext(size);
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}
@end
