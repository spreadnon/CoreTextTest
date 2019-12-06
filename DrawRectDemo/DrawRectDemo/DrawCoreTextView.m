//
//  DrawCoreTextView.m
//  DrawRectDemo
//
//  Created by iOS123 on 2019/12/6.
//  Copyright © 2019 CQL. All rights reserved.
//

#import "DrawCoreTextView.h"
#import <CoreText/CoreText.h>
@implementation DrawCoreTextView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //1.获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //2.旋转坐标
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //3.创建绘制区域
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, self.bounds);
    
    //4.创建需要绘制的文字与计算需要绘制的区域
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]initWithString:@"编者按：中国特色社会主义制度和国家治理体系，生长于中国社会土壤，形成于革命、建设、改革长期实践，是植根中华历史文化传统、吸收借鉴人类制度文明有益成果丰富起来的，不仅保障了我国经济快速发展和社会长期稳定的奇迹，也为多元文明共生并进的人类社会发展增添更多色调、更多范式、更多选择。党的十九届四中全会通过的《中共中央关于坚持和完善中国特色社会主义制度、推进国家治理体系和治理能力现代化若干重大问题的决定》，从13个方面系统总结和深刻阐述了我国国家制度和国家治理体系的显著优势，紧紧围绕“坚持和巩固什么” “完善和发展什么”，提出了一系列新思想新观点新举措，提出了把新时代改革开放推向前进的根本要求，是我们坚定“四个自信”的基本依据。为深入学习宣传党的十九届四中全会精神，中央网信办与求是杂志社共同组织“中国稳健前行”网上理论传播专栏，邀请思想理论界专家学者撰写系列理论文章，今天在求是网推出第7篇，敬请关注。"];
    [attrString addAttribute:(id)kCTForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(10, 10)];
    // 设置部分文字
    CGFloat fontSize = 20;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    [attrString addAttribute:(id)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(15, 10)];
    CFRelease(fontRef);
    
    // 设置行间距
    CGFloat lineSpacing = 10;
    const CFIndex kNumberOfSettings = 3;
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing}
    };
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    [attrString addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)theParagraphRef range:NSMakeRange(0, attrString.length)];
    CFRelease(theParagraphRef);
    
    // 步骤9：图文混排部分
    // CTRunDelegateCallbacks：一个用于保存指针的结构体，由CTRun delegate进行回调
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    
    // 图片信息字典
    NSDictionary *imgInfoDic = @{@"width":@100,@"height":@30};
    
    // 设置CTRun的代理
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)imgInfoDic);
    
    // 使用0xFFFC作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    
    // 将创建的空白AttributedString插入进当前的attrString中，位置可以随便指定，不能越界
    [attrString insertAttributedString:space atIndex:50];
    
    
    
    //5.根据attrstrings生成ctframsetterref
    CTFramesetterRef framSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    CTFrameRef frame = CTFramesetterCreateFrame(framSetter, CFRangeMake(0, [attrString length]), path, NULL);
    
    // 步骤10：绘制图片
    UIImage *image = [UIImage imageNamed:@"123.jpg"];
    CGContextDrawImage(context, [self calculateImagePositionInCTFrame:frame], image.CGImage);
    
    //6.进行绘制
    CTFrameDraw(frame, context);
    
    //7.内存管理
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framSetter);
}

/**
 *  根据CTFrameRef获得绘制图片的区域
 *
 *  @param ctFrame CTFrameRef对象
 *
 *  @return绘制图片的区域
 */
- (CGRect)calculateImagePositionInCTFrame:(CTFrameRef)ctFrame {
    
    // 获得CTLine数组
    NSArray *lines = (NSArray *)CTFrameGetLines(ctFrame);
    NSInteger lineCount = [lines count];
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    // 遍历每个CTLine
    for (NSInteger i = 0 ; i < lineCount; i++) {
        
        CTLineRef line = (__bridge CTLineRef)lines[i];
        NSArray *runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
        
        // 遍历每个CTLine中的CTRun
        for (id runObj in runObjArray) {
            
            CTRunRef run = (__bridge CTRunRef)runObj;
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (delegate == nil) {
                continue;
            }
            
            NSDictionary *metaDic = CTRunDelegateGetRefCon(delegate);
            if (![metaDic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y;
            runBounds.origin.y -= descent;
            
            CGPathRef pathRef = CTFrameGetPath(ctFrame);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            
            CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            return delegateBounds;
        }
    }
    return CGRectZero;
}

#pragma mark - CTRun delegate 回调方法

static CGFloat ascentCallback(void *ref) {
    
    return [(NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback(void *ref) {
    
    return 0;
}

static CGFloat widthCallback(void *ref) {
    
    return [(NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"width"] floatValue];
}

@end
