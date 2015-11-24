//
//  CardCell.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/24.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardModel.h"

/**
 *  名片cell
 */
@interface CardCell : UITableViewCell

- (void) setContentWithModel:(CardModel *)model;

@end
