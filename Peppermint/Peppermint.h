//
//  Peppermint.h
//  Peppermint
//
//  Created by Paul Shen on 11/17/14.
//  Copyright (c) 2014 PaulShen. All rights reserved.
//

#ifndef Peppermint_Peppermint_h
#define Peppermint_Peppermint_h

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#endif
