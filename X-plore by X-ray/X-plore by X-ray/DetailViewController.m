//
//  DetailViewController.m
//  X-plore by X-ray
//
//  Created by Dima Bespalov on 4/18/15.
//  Copyright (c) 2015 Dima Bespalov. All rights reserved.
//

#import "DetailViewController.h"
#import "SnapshotCollectionViewCell.h"
#import "InsertUrlViewController.h"
#import "ImageProcessingViewController.h"
#import "Patient.h"
#import "Snapshot.h"

@interface DetailViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIActionSheetDelegate>

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) UIImagePickerController *imagePicker;
@property (nonatomic) UIPopoverController *popover;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) NSURL *urlForImage;

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

- (void)setDetailItem:(Patient *)newDetailItem {
    if (_detailPatient != newDetailItem) {
        _detailPatient = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailPatient)
    {
        self.firstName.text = self.detailPatient.firstName;
        self.lastName.text = self.detailPatient.lastName;
        self.regNum.text = [self.detailPatient.regNum stringValue];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    if (self.detailPatient) {
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Insert image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add from album", @"Add from Url", nil];
    
    [actionSheet showFromBarButtonItem:sender animated:YES];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex)
    {
        [self.popover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else if (1 == buttonIndex)
    {
        [self performSegueWithIdentifier:@"URL for image" sender:self.detailPatient];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"%@", info);
    UIImage *image = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
    Snapshot *snapshot = [[Snapshot alloc] initWithEntity:[[self.fetchedResultsController fetchRequest] entity] insertIntoManagedObjectContext:self.context];
    snapshot.dateAdded = [NSDate date];
    snapshot.fileName = [NSString stringWithFormat:@"%@_snapshot_%@", self.detailPatient.regNum, snapshot.dateAdded];
    
    [self.detailPatient addSnapshotsObject:snapshot];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data = UIImageJPEGRepresentation(image, 100);
    
    NSString *filePath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:snapshot.fileName] stringByAppendingPathExtension:@"png"];
    if([fileManager createFileAtPath:filePath contents:data attributes:nil])
    {
        //Save the context.
        NSError *error = nil;
        if (![self.context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }

    } else {
        NSLog(@"Image file did not saved");
    }
    
//    CoreDataManager 
    
    
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
    Snapshot *snapshot = [self.fetchedResultsController objectAtIndexPath:indexPath];
    SnapshotCollectionViewCell *cell = (SnapshotCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"snapshot" forIndexPath:indexPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *destinationUrl = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    destinationUrl = [destinationUrl URLByAppendingPathComponent:snapshot.fileName];
    destinationUrl = [destinationUrl URLByAppendingPathExtension:@"png"];
    
    NSData *data = [NSData dataWithContentsOfURL:destinationUrl];
    
    cell.imageView.image = [[UIImage alloc] initWithData:data];
    [cell.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    cell.userInteractionEnabled = YES;
    //cell.imageNameLabel.text = snapshot.fileName;
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    NSLog(@"action");
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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owner == %@", self.detailPatient];
    [fetchRequest setPredicate:predicate];
    
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
    [self.collectionView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"URL for image" isEqualToString:[segue identifier]])
    {
        InsertUrlViewController *controller = segue.destinationViewController;
        [self.splitViewController.navigationController presentViewController:controller animated:YES completion:nil];
    }
    else if ([@"processImage" isEqualToString:[segue identifier]])
    {
        ImageProcessingViewController *imageProcessingController = (ImageProcessingViewController *)[[segue destinationViewController] topViewController];
        imageProcessingController.image = ((SnapshotCollectionViewCell *)sender).imageView.image;
        [self.splitViewController.navigationController presentViewController:imageProcessingController animated:YES completion:nil];
        
    }
}
@end
