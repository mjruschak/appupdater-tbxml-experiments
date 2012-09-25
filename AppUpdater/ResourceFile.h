//
//  ResourceFile.h
//  AppUpdater
//
//  Created by mruschak on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResourceFile : NSObject {
    
}

@property (strong, nonatomic) NSNumber *fileId;
@property (strong, nonatomic) NSString *fileLabel;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *fileGroup;
@property (strong, nonatomic) NSString *fileType;
@property (strong, nonatomic) NSNumber *fileDownloaded;

@end
