//
//  MTDOriginMulticastDelegate.m
//  MulticastDelegate
//
//  Created by Vladislav Grigoryev on 30.05.2020.
//  Copyright © 2020 GORA Studio. https://gora.studio
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "MTDOriginMulticastDelegate.h"

@implementation MTDOriginMulticastDelegate

#pragma mark - NSProxy

- (void)forwardInvocation:(NSInvocation *)invocation
{
  if ([self.origin respondsToSelector:invocation.selector]) {
     [invocation invokeWithTarget:self.origin];
  }

  [super forwardInvocation:invocation];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
  NSMethodSignature *methodSinature = [self.origin methodSignatureForSelector:selector];
  if (methodSinature) {
    return methodSinature;
  }
  return [super methodSignatureForSelector:selector];
}

- (BOOL)respondsToSelector:(SEL)selector
{
  return [self.origin respondsToSelector:selector] || [super respondsToSelector:selector];
}

- (BOOL)conformsToProtocol:(Protocol *)protocol
{
    return [self.origin conformsToProtocol:protocol] || [super conformsToProtocol:protocol];
}

@end
