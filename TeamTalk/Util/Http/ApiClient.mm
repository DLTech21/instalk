//
//  ApiClient.m
//  TeamTalk
//
//  Created by Donal Tong on 16/4/12.
//  Copyright © 2016年 DL. All rights reserved.
//

#import "ApiClient.h"
#import "MTTConfig.h"
#import "MTTUserEntity.h"
#import "IMBaseDefine.pb.h"
#import "security.h"
#import "GTMBase64.h"
@implementation ApiClient

+ (id)sharedInstance{
    static ApiClient *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ApiClient alloc] initWithBaseURL:[NSURL URLWithString:APIURL]];
    });
    return _sharedInstance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        NSMutableSet *contentTypes = [[NSMutableSet alloc] initWithSet:self.responseSerializer.acceptableContentTypes];
        [contentTypes addObject:@"text/html"];
        [contentTypes addObject:@"text/plain"];
        [contentTypes addObject:@"multipart/form-data"];
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        responseSerializer.acceptableContentTypes = contentTypes;
        AFHTTPRequestSerializer *request =  [AFHTTPRequestSerializer serializer];
        [request setTimeoutInterval:120];
        [self setRequestSerializer:request];
        [self setResponseSerializer:responseSerializer];
    }
    return self;
}

-(NSString *)encrypt:(NSString *)content
{
    NSData *condata = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *base64String = [[NSString alloc] initWithData:[GTMBase64 encodeData:condata] encoding:NSUTF8StringEncoding];
    
    char* pOut;
    uint32_t nOutLen;
    const char *test =[base64String cStringUsingEncoding:NSUTF8StringEncoding];
    uint32_t nInLen  = strlen(test);
    EncryptMsg(test, nInLen, &pOut, nOutLen);
    NSString *data = [NSString stringWithCString:pOut encoding:NSUTF8StringEncoding];
    Free(pOut);
    return data;
}

-(NSString *)decrypt:(NSString *)content
{
    char* pOut;
    uint32_t nOutLen;
    uint32_t nInLen = strlen([content cStringUsingEncoding:NSUTF8StringEncoding]);
    DecryptMsg([content cStringUsingEncoding:NSUTF8StringEncoding], nInLen, &pOut, nOutLen);
    NSString *data = [NSString stringWithCString:pOut encoding:NSUTF8StringEncoding];
    Free(pOut);
    return data;
}

- (NSMutableDictionary *)defaultGetParameters{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    return parameters;
}


-(void)registerUser:(NSString *)name
           password:(NSString *)password
           nickname:(NSString *)nickname
             avatar:(NSString *)avatar
                sex:(NSString *)sex
            Success:(void (^)(id model) )success
            failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:name forKey:@"name"];
    [parameters setValue:nickname forKey:@"nickname"];
    [parameters setValue:@"1" forKey:@"departId"];
    [parameters setValue:sex forKey:@"sex"];
    [parameters setValue:password forKey:@"pass"];
    [parameters setValue:avatar forKey:@"avatar"];
    [parameters setValue:name forKey:@"phone"];
    [parameters setValue:@"" forKey:@"email"];
    [parameters setValue:@"0" forKey:@"domain"];
    [[ApiClient sharedInstance] POST:@"/Home/User/registerUser"
                          parameters:parameters
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 NSDictionary *jsonObject=[NSJSONSerialization
                                                           JSONObjectWithData:responseObject
                                                           options:NSJSONReadingMutableLeaves
                                                           error:nil];
                                 success(jsonObject);
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 failure(error.description);
                             }];
}

-(void)applyFriend:(NSString *)targetId
               msg:(NSString *)msg
           Success:(void (^)(id model) )success
           failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:[self encrypt:targetId] forKey:@"tid"];
    [parameters setValue:msg forKey:@"msg"];
    [parameters setValue:[self encrypt:[NSString stringWithFormat:@"%ld", [[RuntimeStatus instance].user getOriginalID]]] forKey:@"uid"];
    [parameters setValue:[RuntimeStatus instance].user.avatar forKey:@"avatar"];
    [parameters setValue:[RuntimeStatus instance].user.nick forKey:@"nickname"];
    [[ApiClient sharedInstance] POST:@"/Home/Friend/applyFriend"
                          parameters:parameters
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 if ([responseObject isKindOfClass:[NSData class]]) {
                                     NSString *str=[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                                     NSDictionary *jsonObject=[NSJSONSerialization
                                                               JSONObjectWithData:[GTMBase64 decodeData:[[self decrypt:str] dataUsingEncoding:NSUTF8StringEncoding]]
                                                               options:NSJSONReadingMutableLeaves
                                                               error:nil];
                                     success(jsonObject);
                                 }
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 failure(error.description);
                             }];
}

-(void)confrimFriend:(NSString *)targetId
             Success:(void (^)(id model) )success
             failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:[self encrypt:targetId] forKey:@"tid"];
    [parameters setValue:[self encrypt:[NSString stringWithFormat:@"%ld", [[RuntimeStatus instance].user getOriginalID]]] forKey:@"uid"];
    [[ApiClient sharedInstance] POST:@"/Home/Friend/confirmFriend"
                          parameters:parameters
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 if ([responseObject isKindOfClass:[NSData class]]) {
                                     NSString *str=[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                                     NSDictionary *jsonObject=[NSJSONSerialization
                                                               JSONObjectWithData:[GTMBase64 decodeData:[[self decrypt:str] dataUsingEncoding:NSUTF8StringEncoding]]
                                                               options:NSJSONReadingMutableLeaves
                                                               error:nil];
                                     success(jsonObject);
                                 }
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 failure(error.description);
                             }];
}

-(void)updateUserPush:(NSString *)clientId
              Success:(void (^)(id model) )success
              failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:[self encrypt:clientId] forKey:@"client_id"];
    [parameters setValue:[self encrypt:TheRuntime.pushToken] forKey:@"token"];
    [parameters setValue:[self encrypt:[NSString stringWithFormat:@"%d", ClientTypeClientTypeIos]] forKey:@"platform"];
    [parameters setValue:[self encrypt:[NSString stringWithFormat:@"%ld", [[RuntimeStatus instance].user getOriginalID]]] forKey:@"uid"];
    
    [[ApiClient sharedInstance] POST:@"/Home/User/updateUserPush"
                          parameters:parameters
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 if ([responseObject isKindOfClass:[NSData class]]) {
                                     NSString *str=[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                                     NSDictionary *jsonObject=[NSJSONSerialization
                                                               JSONObjectWithData:[GTMBase64 decodeData:[[self decrypt:str] dataUsingEncoding:NSUTF8StringEncoding]]
                                                               options:NSJSONReadingMutableLeaves
                                                               error:nil];
                                     success(jsonObject);
                                 }
                                 
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 debugLog(@"%@", error.description);
                                 failure(error.description);
                             }];
}
@end
