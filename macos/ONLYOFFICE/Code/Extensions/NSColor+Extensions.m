/*
 * (c) Copyright Univault Technologies 2026-2026
 *
 * This program is a free software product. You can redistribute it and/or
 * modify it under the terms of the GNU Affero General Public License (AGPL)
 * version 3 as published by the Free Software Foundation. In accordance with
 * Section 7(a) of the GNU AGPL its Section 15 shall be amended to the effect
 * that Univault Technologies expressly excludes the warranty of non-infringement
 * of any third-party rights.
 *
 * This program is distributed WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR  PURPOSE. For
 * details, see the GNU AGPL at: http://www.gnu.org/licenses/agpl-3.0.html
 *
 * You can contact Univault Technologies at 0, bldg. 0, office 0 (TEST) Test Legal Street (TEST)
 * street, Moscow (TEST), Russia (TEST), EU, 000000 (TEST).
 *
 * The  interactive user interfaces in modified source and object code versions
 * of the Program must display Appropriate Legal Notices, as required under
 * Section 5 of the GNU AGPL version 3.
 *
 * Pursuant to Section 7(b) of the License you must retain the original Product
 * logo when distributing the program. Pursuant to Section 7(e) we decline to
 * grant you any rights under trademark law for use of our trademarks.
 *
 * All the Product's GUI elements, including illustrations and icon sets, as
 * well as technical writing content are licensed under the terms of the
 * Creative Commons Attribution-ShareAlike 4.0 International. See the License
 * terms at http://creativecommons.org/licenses/by-sa/4.0/legalcode
 *
 */

//
//  NSColor+Extensions.h
//  UNIVAULTOFFICE
//
//  Created by Alexander Yuzhin on 11/04/2025.
//  Copyright © 2026 Univault Technologies. All rights reserved.
//

#import "NSColor+Extensions.h"
#import "ASCConstants.h"
#import "NSApplication+Extensions.h"

#pragma mark - UNIVAULTOFFICE

@implementation NSColor (UnivaultOffice)

+ (NSColor *) brendDocumentEditor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"brend-DocumentEditor"];
    }
    return UIColorFromRGB(0x446995);
}

+ (NSColor *) brendSpreadsheetEditor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"brend-SpreadsheetEditor"];
    }
    return UIColorFromRGB(0x40865c);
}

+ (NSColor *) brendPresentationEditor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"brend-PresentationEditor"];
    }
    return UIColorFromRGB(0xbe664f);
}

+ (NSColor *) brandPdfEditor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"brand-PdfEditor"];
    }
    return UIColorFromRGB(0xaa5252);
}

+ (NSColor *) brandDrawEditor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"brand-DrawEditor"];
    }
    return UIColorFromRGB(0x444796);
}

@end

#pragma mark - Extensions

@implementation NSColor (Extensions)

- (BOOL) isLight {
    CGFloat colorBrightness = 0;
    CGColorSpaceRef colorSpace = CGColorGetColorSpace(self.CGColor);
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);

    if(colorSpaceModel == kCGColorSpaceModelRGB){
        const CGFloat *componentColors = CGColorGetComponents(self.CGColor);

        colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    } else {
        [self getWhite:&colorBrightness alpha:0];
    }

    return (colorBrightness >= .5f);
}

@end
