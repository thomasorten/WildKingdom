//
//  ViewController.m
//  WildKingdom
//
//  Created by Thomas Orten on 5/30/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "ViewController.h"
#import "animalViewCell.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITabBarControllerDelegate, UITabBarDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewCell *myCollectionViewCell;
@property NSMutableArray *imagesArray;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabBarController.delegate = self;
    self.imagesArray = [[NSMutableArray alloc] init];
    [self getPhotosByTerm:self.title];
}

- (void)getPhotosByTerm:(NSString *)searchTerm
{
    NSString *searchString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=9401ce3d1573537ff059cca44fe122f4&text=%@&content_type=1&extras=url_m&per_page=10&format=json&nojsoncallback=1", searchTerm];
    NSURL *url = [NSURL URLWithString:searchString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
        NSArray *images = [[json objectForKey:@"photos"] objectForKey:@"photo"];
        for (NSDictionary *imageDictionary in images) {
            NSURL *imageUrl = [NSURL URLWithString:[imageDictionary objectForKey:@"url_m"]];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
            [self.imagesArray addObject:image];
        }
        [self.myCollectionView reloadData];
    }];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCollectionViewCellID" forIndexPath:indexPath];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[self.imagesArray objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imagesArray.count;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [self getPhotosByTerm:self.title];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    int screenWidth = [[UIScreen mainScreen] bounds].size.width;
    int screenHeight = [[UIScreen mainScreen] bounds].size.height;
    if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        self.myCollectionView.frame = CGRectMake(0, self.myCollectionView.frame.origin.y, screenWidth, screenHeight);
    } else {
        self.myCollectionView.frame = CGRectMake(0, self.myCollectionView.frame.origin.y, screenHeight, screenWidth);
    }
    [self.myCollectionView reloadData];
}

@end
