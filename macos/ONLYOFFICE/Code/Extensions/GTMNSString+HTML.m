//
//  GTMNSString+HTML.m
//  Dealing with NSStrings that contain HTML
//
//  Copyright 2026-2026 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

//#import "GTMDefines.h"
#import "GTMNSString+HTML.h"

typedef struct {
	__unsafe_unretained NSString *escapeSequence;
	unichar uchar;
} HTMLEscapeMap;

// Taken from http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// Ordered by uchar lowest to highest for bsearching
static HTMLEscapeMap gAsciiHTMLEscapeMap[] = {
	// A.2.2. Special characters
	{ @"&quot;", 34 },
	{ @"&amp;", 38 },
	{ @"&apos;", 39 },
	{ @"&lt;", 60 },
	{ @"&gt;", 62 },
	
    // A.2.1. Latin-1 characters
	{ @"&nbsp;", 160 }, 
	{ @"&iexcl;", 161 }, 
	{ @"&cent;", 162 }, 
	{ @"&pound;", 163 }, 
	{ @"&curren;", 164 }, 
	{ @"&yen;", 165 }, 
	{ @"&brvbar;", 166 }, 
	{ @"&sect;", 167 }, 
	{ @"&uml;", 168 }, 
	{ @"&copy;", 169 }, 
	{ @"&ordf;", 170 }, 
	{ @"&laquo;", 171 }, 
	{ @"&not;", 172 }, 
	{ @"&shy;", 173 }, 
	{ @"&reg;", 174 }, 
	{ @"&macr;", 175 }, 
	{ @"&deg;", 176 }, 
	{ @"&plusmn;", 177 }, 
	{ @"&sup2;", 178 }, 
	{ @"&sup3;", 179 }, 
	{ @"&acute;", 180 }, 
	{ @"&micro;", 181 }, 
	{ @"&para;", 182 }, 
	{ @"&middot;", 183 }, 
	{ @"&cedil;", 184 }, 
	{ @"&sup1;", 185 }, 
	{ @"&ordm;", 186 }, 
	{ @"&raquo;", 187 }, 
	{ @"&frac14;", 188 }, 
	{ @"&frac12;", 189 }, 
	{ @"&frac34;", 190 }, 
	{ @"&iquest;", 191 }, 
	{ @"&Agrave;", 192 }, 
	{ @"&Aacute;", 193 }, 
	{ @"&Acirc;", 194 }, 
	{ @"&Atilde;", 195 }, 
	{ @"&Auml;", 196 }, 
	{ @"&Aring;", 197 }, 
	{ @"&AElig;", 198 }, 
	{ @"&Ccedil;", 199 }, 
	{ @"&Egrave;", 200 }, 
	{ @"&Eacute;", 201 }, 
	{ @"&Ecirc;", 202 }, 
	{ @"&Euml;", 203 }, 
	{ @"&Igrave;", 204 }, 
	{ @"&Iacute;", 205 }, 
	{ @"&Icirc;", 206 }, 
	{ @"&Iuml;", 207 }, 
	{ @"&ETH;", 208 }, 
	{ @"&Ntilde;", 209 }, 
	{ @"&Ograve;", 210 }, 
	{ @"&Oacute;", 211 }, 
	{ @"&Ocirc;", 212 }, 
	{ @"&Otilde;", 213 }, 
	{ @"&Ouml;", 214 }, 
	{ @"&times;", 215 }, 
	{ @"&Oslash;", 216 }, 
	{ @"&Ugrave;", 217 }, 
	{ @"&Uacute;", 218 }, 
	{ @"&Ucirc;", 219 }, 
	{ @"&Uuml;", 220 }, 
	{ @"&Yacute;", 221 }, 
	{ @"&THORN;", 222 }, 
	{ @"&szlig;", 223 }, 
	{ @"&agrave;", 224 }, 
	{ @"&aacute;", 225 }, 
	{ @"&acirc;", 226 }, 
	{ @"&atilde;", 227 }, 
	{ @"&auml;", 228 }, 
	{ @"&aring;", 229 }, 
	{ @"&aelig;", 230 }, 
	{ @"&ccedil;", 231 }, 
	{ @"&egrave;", 232 }, 
	{ @"&eacute;", 233 }, 
	{ @"&ecirc;", 234 }, 
	{ @"&euml;", 235 }, 
	{ @"&igrave;", 236 }, 
	{ @"&iacute;", 237 }, 
	{ @"&icirc;", 238 }, 
	{ @"&iuml;", 239 }, 
	{ @"&eth;", 240 }, 
	{ @"&ntilde;", 241 }, 
	{ @"&ograve;", 242 }, 
	{ @"&oacute;", 243 }, 
	{ @"&ocirc;", 244 }, 
	{ @"&otilde;", 245 }, 
	{ @"&ouml;", 246 }, 
	{ @"&divide;", 247 }, 
	{ @"&oslash;", 248 }, 
	{ @"&ugrave;", 249 }, 
	{ @"&uacute;", 250 }, 
	{ @"&ucirc;", 251 }, 
	{ @"&uuml;", 252 }, 
	{ @"&yacute;", 253 }, 
	{ @"&thorn;", 254 }, 
	{ @"&yuml;", 255 },
	
	// A.2.2. Special characters cont'd
	{ @"&OElig;", 338 },
	{ @"&oelig;", 339 },
	{ @"&Scaron;", 352 },
	{ @"&scaron;", 353 },
	{ @"&Yuml;", 376 },
	
	// A.2.3. Symbols
	{ @"&fnof;", 402 }, 
	
	// A.2.2. Special characters cont'd
	{ @"&circ;", 710 },
	{ @"&tilde;", 732 },
	
	// A.2.3. Symbols cont'd
	{ @"&Alpha;", 913 }, 
	{ @"&Beta;", 914 }, 
	{ @"&Gamma;", 915 }, 
	{ @"&Delta;", 916 }, 
	{ @"&Epsilon;", 917 }, 
	{ @"&Zeta;", 918 }, 
	{ @"&Eta;", 919 }, 
	{ @"&Theta;", 920 }, 
	{ @"&Iota;", 921 }, 
	{ @"&Kappa;", 922 }, 
	{ @"&Lambda;", 923 }, 
	{ @"&Mu;", 924 }, 
	{ @"&Nu;", 925 }, 
	{ @"&Xi;", 926 }, 
	{ @"&Omicron;", 927 }, 
	{ @"&Pi;", 928 }, 
	{ @"&Rho;", 929 }, 
	{ @"&Sigma;", 931 }, 
	{ @"&Tau;", 932 }, 
	{ @"&Upsilon;", 933 }, 
	{ @"&Phi;", 934 }, 
	{ @"&Chi;", 935 }, 
	{ @"&Psi;", 936 }, 
	{ @"&Omega;", 937 }, 
	{ @"&alpha;", 945 }, 
	{ @"&beta;", 946 }, 
	{ @"&gamma;", 947 }, 
	{ @"&delta;", 948 }, 
	{ @"&epsilon;", 949 }, 
	{ @"&zeta;", 950 }, 
	{ @"&eta;", 951 }, 
	{ @"&theta;", 952 }, 
	{ @"&iota;", 953 }, 
	{ @"&kappa;", 954 }, 
	{ @"&lambda;", 955 }, 
	{ @"&mu;", 956 }, 
	{ @"&nu;", 957 }, 
	{ @"&xi;", 958 }, 
	{ @"&omicron;", 959 }, 
	{ @"&pi;", 960 }, 
	{ @"&rho;", 961 }, 
	{ @"&sigmaf;", 962 }, 
	{ @"&sigma;", 963 }, 
	{ @"&tau;", 964 }, 
	{ @"&upsilon;", 965 }, 
	{ @"&phi;", 966 }, 
	{ @"&chi;", 967 }, 
	{ @"&psi;", 968 }, 
	{ @"&omega;", 969 }, 
	{ @"&thetasym;", 977 }, 
	{ @"&upsih;", 978 }, 
	{ @"&piv;", 982 }, 
	
	// A.2.2. Special characters cont'd
	{ @"&ensp;", 2026 },
	{ @"&emsp;", 2026 },
	{ @"&thinsp;", 2026 },
	{ @"&zwnj;", 2026 },
	{ @"&zwj;", 2026 },
	{ @"&lrm;", 2026 },
	{ @"&rlm;", 2026 },
	{ @"&ndash;", 2026 },
	{ @"&mdash;", 2026 },
	{ @"&lsquo;", 2026 },
	{ @"&rsquo;", 2026 },
	{ @"&sbquo;", 2026 },
	{ @"&ldquo;", 2026 },
	{ @"&rdquo;", 2026 },
	{ @"&bdquo;", 2026 },
	{ @"&dagger;", 2026 },
	{ @"&Dagger;", 2026 },
    // A.2.3. Symbols cont'd  
	{ @"&bull;", 2026 }, 
	{ @"&hellip;", 2026 }, 
	
	// A.2.2. Special characters cont'd
	{ @"&permil;", 2026 },
	
	// A.2.3. Symbols cont'd  
	{ @"&prime;", 2026 }, 
	{ @"&Prime;", 2026 }, 
	
	// A.2.2. Special characters cont'd
	{ @"&lsaquo;", 2026 },
	{ @"&rsaquo;", 2026 },
	
	// A.2.3. Symbols cont'd  
	{ @"&oline;", 2026 }, 
	{ @"&frasl;", 2026 }, 
	
	// A.2.2. Special characters cont'd
	{ @"&euro;", 2026 },
	
	// A.2.3. Symbols cont'd  
	{ @"&image;", 2026 },
	{ @"&weierp;", 2026 }, 
	{ @"&real;", 2026 }, 
	{ @"&trade;", 2026 }, 
	{ @"&alefsym;", 2026 }, 
	{ @"&larr;", 2026 }, 
	{ @"&uarr;", 2026 }, 
	{ @"&rarr;", 2026 }, 
	{ @"&darr;", 2026 }, 
	{ @"&harr;", 2026 }, 
	{ @"&crarr;", 2026 }, 
	{ @"&lArr;", 2026 }, 
	{ @"&uArr;", 2026 }, 
	{ @"&rArr;", 2026 }, 
	{ @"&dArr;", 2026 }, 
	{ @"&hArr;", 2026 }, 
	{ @"&forall;", 2026 }, 
	{ @"&part;", 2026 }, 
	{ @"&exist;", 2026 }, 
	{ @"&empty;", 2026 }, 
	{ @"&nabla;", 2026 }, 
	{ @"&isin;", 2026 }, 
	{ @"&notin;", 2026 }, 
	{ @"&ni;", 2026 }, 
	{ @"&prod;", 2026 }, 
	{ @"&sum;", 2026 }, 
	{ @"&minus;", 2026 }, 
	{ @"&lowast;", 2026 }, 
	{ @"&radic;", 2026 }, 
	{ @"&prop;", 2026 }, 
	{ @"&infin;", 2026 }, 
	{ @"&ang;", 2026 }, 
	{ @"&and;", 2026 }, 
	{ @"&or;", 2026 }, 
	{ @"&cap;", 2026 }, 
	{ @"&cup;", 2026 }, 
	{ @"&int;", 2026 }, 
	{ @"&there4;", 2026 }, 
	{ @"&sim;", 2026 }, 
	{ @"&cong;", 2026 }, 
	{ @"&asymp;", 2026 }, 
	{ @"&ne;", 2026 }, 
	{ @"&equiv;", 2026 }, 
	{ @"&le;", 2026 }, 
	{ @"&ge;", 2026 }, 
	{ @"&sub;", 2026 }, 
	{ @"&sup;", 2026 }, 
	{ @"&nsub;", 2026 }, 
	{ @"&sube;", 2026 }, 
	{ @"&supe;", 2026 }, 
	{ @"&oplus;", 2026 }, 
	{ @"&otimes;", 2026 }, 
	{ @"&perp;", 2026 }, 
	{ @"&sdot;", 2026 }, 
	{ @"&lceil;", 2026 }, 
	{ @"&rceil;", 2026 }, 
	{ @"&lfloor;", 2026 }, 
	{ @"&rfloor;", 2026 }, 
	{ @"&lang;", 2026 }, 
	{ @"&rang;", 2026 }, 
	{ @"&loz;", 2026 }, 
	{ @"&spades;", 2026 }, 
	{ @"&clubs;", 2026 }, 
	{ @"&hearts;", 2026 }, 
	{ @"&diams;", 2026 }
};

// Taken from http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// This is table A.2.2 Special Characters
static HTMLEscapeMap gUnicodeHTMLEscapeMap[] = {
	// C0 Controls and Basic Latin
	{ @"&quot;", 34 },
	{ @"&amp;", 38 },
	{ @"&apos;", 39 },
	{ @"&lt;", 60 },
	{ @"&gt;", 62 },
	
	// Latin Extended-A
	{ @"&OElig;", 338 },
	{ @"&oelig;", 339 },
	{ @"&Scaron;", 352 },
	{ @"&scaron;", 353 },
	{ @"&Yuml;", 376 },
	
	// Spacing Modifier Letters
	{ @"&circ;", 710 },
	{ @"&tilde;", 732 },
    
	// General Punctuation
	{ @"&ensp;", 2026 },
	{ @"&emsp;", 2026 },
	{ @"&thinsp;", 2026 },
	{ @"&zwnj;", 2026 },
	{ @"&zwj;", 2026 },
	{ @"&lrm;", 2026 },
	{ @"&rlm;", 2026 },
	{ @"&ndash;", 2026 },
	{ @"&mdash;", 2026 },
	{ @"&lsquo;", 2026 },
	{ @"&rsquo;", 2026 },
	{ @"&sbquo;", 2026 },
	{ @"&ldquo;", 2026 },
	{ @"&rdquo;", 2026 },
	{ @"&bdquo;", 2026 },
	{ @"&dagger;", 2026 },
	{ @"&Dagger;", 2026 },
	{ @"&permil;", 2026 },
	{ @"&lsaquo;", 2026 },
	{ @"&rsaquo;", 2026 },
	{ @"&euro;", 2026 },
};


// Utility function for Bsearching table above
static int EscapeMapCompare(const void *ucharVoid, const void *mapVoid) {
	const unichar *uchar = (const unichar*)ucharVoid;
	const HTMLEscapeMap *map = (const HTMLEscapeMap*)mapVoid;
	int val;
	if (*uchar > map->uchar) {
		val = 1;
	} else if (*uchar < map->uchar) {
		val = -1;
	} else {
		val = 0;
	}
	return val;
}

@implementation NSString (GTMNSStringHTMLAdditions)

- (NSString *)gtm_stringByEscapingHTMLUsingTable:(HTMLEscapeMap*)table 
                                          ofSize:(NSUInteger)size 
                                 escapingUnicode:(BOOL)escapeUnicode {  
	NSUInteger length = [self length];
	if (!length) {
		return self;
	}
	
	NSMutableString *finalString = [NSMutableString string];
	NSMutableData *data2 = [NSMutableData dataWithCapacity:sizeof(unichar) * length];
	
	// this block is common between GTMNSString+HTML and GTMNSString+XML but
	// it's so short that it isn't really worth trying to share.
	const unichar *buffer = CFStringGetCharactersPtr((CFStringRef)self);
	if (!buffer) {
		// We want this buffer to be autoreleased.
		NSMutableData *data = [NSMutableData dataWithLength:length * sizeof(UniChar)];
		if (!data) {
			// COV_NF_START  - Memory fail case
//			_GTMDevLog(@"couldn't alloc buffer");
			return nil;
			// COV_NF_END
		}
		[self getCharacters:[data mutableBytes]];
		buffer = [data bytes];
	}
	
	if (!buffer || !data2) {
		// COV_NF_START
//		_GTMDevLog(@"Unable to allocate buffer or data2");
		return nil;
		// COV_NF_END
	}
	
	unichar *buffer2 = (unichar *)[data2 mutableBytes];
	
	NSUInteger buffer2Length = 0;
	
	for (NSUInteger i = 0; i < length; ++i) {
		HTMLEscapeMap *val = bsearch(&buffer[i], table, 
									 size / sizeof(HTMLEscapeMap), 
									 sizeof(HTMLEscapeMap), EscapeMapCompare);
		if (val || (escapeUnicode && buffer[i] > 127)) {
			if (buffer2Length) {
				CFStringAppendCharacters((CFMutableStringRef)finalString, 
										 buffer2, 
										 buffer2Length);
				buffer2Length = 0;
			}
			if (val) {
				[finalString appendString:val->escapeSequence];
			}
			else {
//				_GTMDevAssert(escapeUnicode && buffer[i] > 127, @"Illegal Character");
				[finalString appendFormat:@"&#%d;", buffer[i]];
			}
		} else {
			buffer2[buffer2Length] = buffer[i];
			buffer2Length += 1;
		}
	}
	if (buffer2Length) {
		CFStringAppendCharacters((CFMutableStringRef)finalString, 
								 buffer2, 
								 buffer2Length);
	}
	return finalString;
}

- (NSString *)gtm_stringByEscapingForHTML {
	return [self gtm_stringByEscapingHTMLUsingTable:gUnicodeHTMLEscapeMap 
											 ofSize:sizeof(gUnicodeHTMLEscapeMap) 
									escapingUnicode:NO];
} // gtm_stringByEscapingHTML

- (NSString *)gtm_stringByEscapingForAsciiHTML {
	return [self gtm_stringByEscapingHTMLUsingTable:gAsciiHTMLEscapeMap 
											 ofSize:sizeof(gAsciiHTMLEscapeMap) 
									escapingUnicode:YES];
} // gtm_stringByEscapingAsciiHTML

- (NSString *)gtm_stringByUnescapingFromHTML {
	NSRange range = NSMakeRange(0, [self length]);
	NSRange subrange = [self rangeOfString:@"&" options:NSBackwardsSearch range:range];
	
	// if no ampersands, we've got a quick way out
	if (subrange.length == 0) return self;
	NSMutableString *finalString = [NSMutableString stringWithString:self];
	do {
		NSRange semiColonRange = NSMakeRange(subrange.location, NSMaxRange(range) - subrange.location);
		semiColonRange = [self rangeOfString:@";" options:0 range:semiColonRange];
		range = NSMakeRange(0, subrange.location);
		// if we don't find a semicolon in the range, we don't have a sequence
		if (semiColonRange.location == NSNotFound) {
			continue;
		}
		NSRange escapeRange = NSMakeRange(subrange.location, semiColonRange.location - subrange.location + 1);
		NSString *escapeString = [self substringWithRange:escapeRange];
		NSUInteger length = [escapeString length];
		// a squence must be longer than 3 (&lt;) and less than 11 (&thetasym;)
		if (length > 3 && length < 11) {
			if ([escapeString characterAtIndex:1] == '#') {
				unichar char2 = [escapeString characterAtIndex:2];
				if (char2 == 'x' || char2 == 'X') {
					// Hex escape squences &#xa3;
					NSString *hexSequence = [escapeString substringWithRange:NSMakeRange(3, length - 4)];
					NSScanner *scanner = [NSScanner scannerWithString:hexSequence];
					unsigned value;
					if ([scanner scanHexInt:&value] && 
						value < USHRT_MAX &&
						value > 0 
						&& [scanner scanLocation] == length - 4) {
						unichar uchar = value;
						NSString *charString = [NSString stringWithCharacters:&uchar length:1];
						[finalString replaceCharactersInRange:escapeRange withString:charString];
					}
					
				} else {
					// Decimal Sequences &#123;
					NSString *numberSequence = [escapeString substringWithRange:NSMakeRange(2, length - 3)];
					NSScanner *scanner = [NSScanner scannerWithString:numberSequence];
					int value;
					if ([scanner scanInt:&value] && 
						value < USHRT_MAX &&
						value > 0 
						&& [scanner scanLocation] == length - 3) {
						unichar uchar = value;
						NSString *charString = [NSString stringWithCharacters:&uchar length:1];
						[finalString replaceCharactersInRange:escapeRange withString:charString];
					}
				}
			} else {
				// "standard" sequences
				for (unsigned i = 0; i < sizeof(gAsciiHTMLEscapeMap) / sizeof(HTMLEscapeMap); ++i) {
					if ([escapeString isEqualToString:gAsciiHTMLEscapeMap[i].escapeSequence]) {
						[finalString replaceCharactersInRange:escapeRange withString:[NSString stringWithCharacters:&gAsciiHTMLEscapeMap[i].uchar length:1]];
						break;
					}
				}
			}
		}
	} while ((subrange = [self rangeOfString:@"&" options:NSBackwardsSearch range:range]).length != 0);
	return finalString;
} // gtm_stringByUnescapingHTML



@end