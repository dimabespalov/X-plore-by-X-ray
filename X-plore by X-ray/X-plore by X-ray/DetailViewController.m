//
//  DetailViewController.m
//  X-plore by X-ray
//
//  Created by Dima Bespalov on 4/18/15.
//  Copyright (c) 2015 Dima Bespalov. All rights reserved.
//

#import "DetailViewController.h"
#import "SnapshotCollectionViewCell.h"
@interface DetailViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) UIImagePickerController *imagePicker;
@property (nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) UIImage *image;
@property (weak, nonatomic) NSString *imageName;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation DetailViewController

- (NSManagedObjectContext *)context
{
    if (nil == _context){
        _context = [[CoreDataManager defaultManager] managedObjectContext];
    }
    return _context;
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
//        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"firstName"] description];
        self.firstName.text = [[self.detailItem valueForKey:@"firstName"] description];
        self.lastName.text = [[self.detailItem valueForKey:@"lastName"] description];
        self.regNum.text = [[self.detailItem valueForKey:@"regNum"] description];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    if (self.detailItem) {
        self.detailPatientInfoView.hidden = NO;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addImage:)];
    self.navigationItem.rightBarButtonItem = addButton;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Add Image

- (UIImagePickerController *)imagePicker
{
    if (nil == _imagePicker){
        _imagePicker = [UIImagePickerController new];
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

- (UIPopoverController *)popover
{
    if (nil == _popover)
    {
        _popover = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker];
    }
    return _popover;
}

- (void)addImage:(id)sender
{
    [self.popover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"%@", info);
    self.image = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
    self.imageName = @"IMAGE";
    NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:[[self.fetchedResultsController fetchRequest].entity name] inManagedObjectContext:self.context];
    [newObject setValue:@"Image" forKey:@"fileName"];
    [newObject setValue:[NSDate date] forKey:@"dateAdded"];
    //Save the context.
    NSError *error = nil;
    if (![self.context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.popover dismissPopoverAnimated:YES];
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    SnapshotCollectionViewCell *cell = (SnapshotCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"snapshot" forIndexPath:indexPath];
    //UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    //[cell addSubview:imageView];
    cell.imageNameLabel.text = [object valueForKey:@"fileName"];
    return cell;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (nil != _fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Snapshot" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owner.regNum = %@", self.regNum];
    //[fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
}

//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
//{
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        default:
//            return;
//    }
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath
//{
//    
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
}

@end
