//
//  NCProjectTableViewCell.m
//  NaiveC
//
//  Created by 梁志远 on 01/01/2018.
//  Copyright © 2018 Ogreaxe. All rights reserved.
//

#import "NCProjectTableViewCell.h"

@interface NCProjectTableViewCell()

@property (nonatomic) NSImageView * seperator;

@end

@implementation NCProjectTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//- (instancetype)initWithStyle:(NSTableViews)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        NSImageView * seperator = [[NSImageView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-1, self.bounds.size.width, 1)];
//        seperator.backgroundColor = [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1.0];
//        [self.contentView addSubview:seperator];
//        self.seperator = seperator;
//    }
//    return self;
//}

-(id)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    
    if (self) {
        NSImageView * seperator = [[NSImageView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-1, self.bounds.size.width, 1)];
        seperator.layer.backgroundColor =  [NSColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1.0].CGColor;
        [self addSubview:seperator];
        self.seperator = seperator;
    }
    return self;
}

//-(void)layoutSubviews{
//    [super layoutSubviews];
//
//    self.seperator.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 1);
//}

@end
