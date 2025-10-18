#import "FastPdf.h"
#import "FastPdf-Swift.h"


@implementation FastPdf {
  FastPdfImpl *moduleImpl;
}
-(instancetype) init {
  self = [super init];
  if(self) {
    moduleImpl = [FastPdfImpl new];
  }
  return self;
}


- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeFastPdfSpecJSI>(params);
}

+ (NSString *)moduleName
{
  return @"FastPdf";
}

- (void)openPdf:(nonnull NSString *)uri
         resolve:(nonnull RCTPromiseResolveBlock)resolve
          reject:(nonnull RCTPromiseRejectBlock)reject
{
  [moduleImpl openPdfWithUri:uri
                   resolver:^(NSString * _Nonnull result) {
                     resolve(result);
                   }
                   rejecter:^(NSString * _Nonnull error) {
                     reject(@"E_OPEN_PDF", error, nil);
                   }];
}

@end
