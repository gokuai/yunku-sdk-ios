//
//  MyPrintPageRender.h
//  GoKuai
//
//  Created by Roffa Zhou on 13-7-2.
//
//

#import <UIKit/UIKit.h>

@interface MyPrintPageRender : UIPrintPageRenderer
- (NSData*) convertUIWebViewToPDFsaveWidth: (float)pdfWidth saveHeight:(float) pdfHeight;
@end
