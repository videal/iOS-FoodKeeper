//
//  SidePanelController.h
//  FoodKeeper
//
//  Created by Alexander Voityuk on 17.03.14.
//  Copyright (c) 2014 Videal. All rights reserved.
//

#import "JASidePanelController.h"
#import "FKDataManager.h"

#define kNotificationToggleLeftPanel @"kToggleLeftPanel"

@interface SidePanelController : JASidePanelController

- (UIBarButtonItem *)rightButtonForCenterPanel;

- (void)showAddProductViewWithProduct:(Product *)product storageType:(ProductStorageType)storageType;

@end
