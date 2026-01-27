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
//  ASCTabsControl.h
//  UNIVAULTOFFICE
//
//  Created by Alexander Yuzhin on 9/7/15.
//  Copyright (c) 2026 Univault Technologies. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ASCTabsControl;
@class ASCTabView;

@interface ASCTabsMulticastDelegate : NSObject
- (void)addDelegate:(id)delegate;
@end

@protocol ASCTabsControlDelegate <NSObject>
@optional
- (void)tabs:(ASCTabsControl *)control didResize:(CGRect)rect;
- (void)tabs:(ASCTabsControl *)control didAddTab:(ASCTabView *)tab;
- (BOOL)tabs:(ASCTabsControl *)control willRemovedTab:(ASCTabView *)tab;
- (void)tabs:(ASCTabsControl *)control didRemovedTab:(ASCTabView *)tab;
- (void)tabs:(ASCTabsControl *)control didSelectTab:(ASCTabView *)tab;
- (void)tabs:(ASCTabsControl *)control didUpdateTab:(ASCTabView *)tab;
- (void)tabs:(ASCTabsControl *)control didReorderTab:(ASCTabView *)tab from:(NSInteger)oldIndex to:(NSInteger)newIndex;
@end

@interface ASCTabsControl : NSControl
@property (nonatomic) NSMutableArray *tabs;
@property (nonatomic) CGFloat minTabWidth;
@property (nonatomic) CGFloat maxTabWidth;
@property (nonatomic, assign) id <ASCTabsControlDelegate> delegate;
@property (readonly) ASCTabsMulticastDelegate* multicastDelegate;

- (void)addTab:(ASCTabView *)tab;
- (void)addTab:(ASCTabView *)tab selected:(BOOL)selected;
- (void)removeTab:(ASCTabView *)tab;
- (void)removeTab:(ASCTabView *)tab selected:(BOOL)selected;
- (void)removeAllTabs;
- (void)selectTab:(ASCTabView *)tab;
- (void)updateTab:(ASCTabView *)tab;
- (void)selectNextTab;
- (void)selectPreviouseTab;

- (ASCTabView *)tabWithUUID:(NSString *)uuid;
- (ASCTabView *)selectedTab;
@end