//
// WS_main.m
// webservice
//
// Created by benyamin mokhtarpour on 7/23/17.
// Copyright © 2017 amir soleimani. All rights reserved.
//

#import "WS_main.h"
#import <maincore/MC_message_dialog.h>
#import <maincore/App_ActionDelegate.h>
#import <models/tbl_auth.h>
#import "WS_SecurityManager.h"
#import <models/database.h>



#ifdef DEBUG
#define DLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], LINE, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DLog( s, ... )
#endif

@interface WS_main ()

@end

@implementation WS_main {
    BOOL ShowFailedDialog;
    void (^FailedHandler)( NSDictionary * _Nullable Response);
    void (^SuccessHandler)( NSDictionary * _Nullable Response);
    void (^CancelHandler)(void);
    WS_SecurityManager *SecurityManager;
    NSString *WS_APIKey; //@"59c4cfa1746ba7000144ea8329b61bccb4c14188490034a958ef72be";
}

NSString *WS_URL = @"";
BOOL TEST_SERVER = FALSE;
BOOL isRequestingRefreshToken = FALSE;
BOOL isRequestingRefreshTokenFromThisFile = FALSE;

- (id)initWithDelegate:(id)delegate failedDialog:(BOOL)failedDialog {
    if ((self = [super init])) {
        [self setDelegate:delegate];
        ShowFailedDialog = failedDialog;
        SecurityManager = [[WS_SecurityManager alloc] init];
        WS_APIKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"APIKey"];
    }
    return self;
}

- (NSString*)ServiceURL:(API_SERVICES)ServiceCode {
    if (!TEST_SERVER) {
        NSString *BaseURL = @"https://api.raad.cloud";
        NSString *NewBaseURL = @"https://api.paygear.ir";
        
        if (![[MCLocalization sharedInstance].language isEqualToString:@"ar"]) {
            // if(![[[NSUserDefaults standardUserDefaults] valueForKey:@"lang"] isEqualToString:@"ar"]) {
            BaseURL = @"https://api.raadsense.com";
            //    BaseURL = @"https://api.paygear.ir";
        }
        //--
        NSLog(@"%@ BaseURL",NewBaseURL);
        switch (ServiceCode) {
            default:
            case API_SERVICE_CLUB:
                return [NewBaseURL stringByAppendingString:@"/club"];
                break;
            case API_SERVICE_ACCOUNT:
                return [NewBaseURL stringByAppendingString:@"/users"];
                break;
            case API_SERVICE_SEARCH:
                return [NewBaseURL stringByAppendingString:@"/search"];
                break;
            case API_SERVICE_SOCIAL:
                return [NewBaseURL stringByAppendingString:@"/social"];
                break;
            case API_SERVICE_PAYMENT:
                return [NewBaseURL stringByAppendingString:@"/payment"];
                break;
            case API_SERVICE_DELIVERY:
                return [NewBaseURL stringByAppendingString:@"/delivery"];
                break;
            case API_SERVICE_COUPON:
                return [NewBaseURL stringByAppendingString:@"/loyalty"];
                break;
            case API_SERVICE_PRODUCT:
                return [NewBaseURL stringByAppendingString:@"/products"];
                break;
            case API_SERVICE_GEO:
                return [NewBaseURL stringByAppendingString:@"/geo"];
                break;
            case API_SERVICE_EXPLORE:
                return [NewBaseURL stringByAppendingString:@"/explore"];
                break;
            case API_SERVICE_FILESERVICE:
                return [NewBaseURL stringByAppendingString:@"/files"];
                break;
            case API_SERVICE_PUSH:
                return [NewBaseURL stringByAppendingString:@"/push"];
                break;
            case API_SERVICE_CASHOUT:
                return [NewBaseURL stringByAppendingString:@"/cashout"];
                break;
            case API_SERVICE_CREDIT:
                return [NewBaseURL stringByAppendingString:@"/credit"];
                break;
            case API_SERVICE_QR:
                return [NewBaseURL stringByAppendingString:@"/qrcode"];
                break;
            case API_SERVICE_TRANSPORT:
                return [NewBaseURL stringByAppendingString:@"/transport"];
                break;
            case NEW_API_SERVICE_ACCOUNT:
                return [NewBaseURL stringByAppendingString:@"/users"];
                break;
        }
    } else { //TODO:Test.
        NSString *BaseURL = @"http://dev.docker.raad";
        if (![[MCLocalization sharedInstance].language isEqualToString:@"ar"])
            BaseURL = @"http://dev.docker.raad";
        //--
        switch (ServiceCode) {
            default:
            case API_SERVICE_CLUB:
                return [BaseURL stringByAppendingString:@":32701"]; //?
                break;
            case API_SERVICE_ACCOUNT:
                return [BaseURL stringByAppendingString:@":30201"];
                break;
            case API_SERVICE_SEARCH:
                return [BaseURL stringByAppendingString:@":30701"];
                break;
            case API_SERVICE_SOCIAL:
                return [BaseURL stringByAppendingString:@":30101"];
                break;
            case API_SERVICE_PAYMENT:
                return [BaseURL stringByAppendingString:@":30601"];
                break;
            case API_SERVICE_DELIVERY:
                return [BaseURL stringByAppendingString:@"/delivery"];
                break;
            case API_SERVICE_COUPON:
                return [BaseURL stringByAppendingString:@":30301"];
                break;
            case API_SERVICE_PRODUCT:
                return [BaseURL stringByAppendingString:@":30501"];
                break;
            case API_SERVICE_GEO:
                return [BaseURL stringByAppendingString:@"/geo"];
                break;
            case API_SERVICE_EXPLORE:
                return [BaseURL stringByAppendingString:@"/explore"];
                break;
            case API_SERVICE_FILESERVICE:
                return [BaseURL stringByAppendingString:@"/files"];
                break;
            case API_SERVICE_PUSH:
                return [BaseURL stringByAppendingString:@"/push"];
                break;
            case API_SERVICE_CASHOUT:
                return [BaseURL stringByAppendingString:@"/cashout"];
                break;
            case API_SERVICE_CREDIT:
                return [BaseURL stringByAppendingString:@"/credit"];
                break;
            case API_SERVICE_QR:
                return [BaseURL stringByAppendingString:@"/qrcode"];
                break;
                
        }
    }
}

/**
 * Success Handler
 */
- (void)addSuccessHandler:(void (^ __nullable)(id Response))successhandler {
    SuccessHandler = successhandler;
}

/**
 * Failed Handler
 */
- (void)addFailedHandler:(void (^ __nullable)(NSDictionary *Response))failedhandler {
    FailedHandler = failedhandler;
}

/**
 * Cancel Handler
 */
- (void)addCancelHandler:(void (^ __nullable)(void))cancelhandler {
    CancelHandler = cancelhandler;
}

/**
 * Call Base Method
 */
- (void)Call:(NSString*)Method postbody:(NSArray*__nonnull)Body request:(NSString*)Request auth:(BOOL)Auth {
    [self Call:Method body:[Body objectAtIndex:0] request:Request auth:Auth];
}
NSString *TempURL;

- (void)Call:(NSString*)Method body:(id __nonnull)Body request:(NSString*)Request auth:(BOOL)Auth {
    TempURL = Method;
    if (!self.CheckIsOld && [[[NSUserDefaults standardUserDefaults] objectForKey:@"is_new"] boolValue]) {
        [self action_authproblem];
    }
    
    NSError *error;
    NSString *jsonString;
    NSDictionary *Params = nil;
    if ([Request isEqualToString:@"GET"] && Body != nil) {
        jsonString = @"";
        Params = Body;
    } else if (Body != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:Body options:0 error:&error];
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", jsonString);
    } else {
        jsonString = @"";
    }
    
    //--
    NSLog(@"%@ x",[NSString stringWithFormat:@"%@%@",WS_URL,Method]);
    self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    //    NSString *quotedClassName = ;
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:Request URLString:[[NSString stringWithFormat:@"%@%@",WS_URL,Method] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] parameters:Params error:nil];
    req = [self HeaderRequest:req];
    
    
    //-- Auth Check,Set
    if (Auth) {
        NSLog(@"%@ %@",[SecurityManager getTokenType],[SecurityManager getJWT]);
        if ([SecurityManager getJWT] != nil && [SecurityManager getTokenType] != nil) {
            [req setValue:[NSString stringWithFormat:@"%@ %@",[SecurityManager getTokenType],[SecurityManager getJWT]] forHTTPHeaderField:@"Authorization"];
        } else {
            return;
        }
    }
    
    //--
    if (![Request isEqualToString:@"GET"])
        [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //--
    req.timeoutInterval = 15.0;
    
    //    while (isRequestingRefreshToken && ![Method isEqualToString:@"https://api.raad.cloud/users/v3/auth/refresh"]) {}
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[self.manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"%@ \n %@ \n %@",response,responseObject, error.userInfo );
        
        //--Header Auth & Status Code.
        [self HeaderAuth:[(NSHTTPURLResponse *)response allHeaderFields]];
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        
        //        if ([response.URL.relativePath isEqualToString:@"/users/v3/auth/refresh"]) {
        //
        //        }
        if (isRequestingRefreshToken) {
            isRequestingRefreshToken = FALSE;
            NSLog(@"XXXXX%@ \n %@ \n %@",response,responseObject, error.userInfo );
            if (isRequestingRefreshTokenFromThisFile) {
                isRequestingRefreshTokenFromThisFile = FALSE;
                if (statusCode >= 200 && statusCode <= 299) {
                    [self TokenErrorHandler:@{}];
                    return ;
                }
            }
        }
        
        //--
        if (statusCode >= 200 && statusCode <= 299) { //Success
            if (self->SuccessHandler != nil) {
                if (responseObject == nil) {
                    self->SuccessHandler(@{});
                }
                else {
                    self->SuccessHandler(responseObject);
                }
            }
            //        }else if (statusCode == 403) { //Auth Problem.
            //            self->FailedHandler(nil);
            //            [self action_authproblem];
            //
        } else if (statusCode == 401 || statusCode == 403) {
            if (statusCode == 403 && [response.URL.relativePath isEqualToString:@"/users/v3/auth/refresh"]) {
                [self action_authproblem];
            } else {
                if (isRequestingRefreshToken == FALSE) {
                    if (self->FailedHandler != nil) {
                        self->FailedHandler(@{ @"server error" : @"Unreachable"});
                    }
                    isRequestingRefreshTokenFromThisFile = true;
                    [self refresh_token];
                }
            }
        } else if (statusCode >= 500 && statusCode < 600) {
            if (self->FailedHandler != nil) {
                self->FailedHandler(@{ @"server error" : @"Unreachable"});
            }
        } else { //if (statusCode == 404 && statusCode == 500 && statusCode == 400) { //Other Error.
            
            if (self->FailedHandler != nil){
                if (responseObject != nil) {
                    
                    self->FailedHandler(responseObject);
                }
                else {
                    self->FailedHandler(error.userInfo);
                    //                    isRequestingRefreshToken = FALSE;
                }
            }
            if (self->ShowFailedDialog && responseObject != nil)
                [self ErrorHandler:responseObject];
            //            else if (self->ShowFailedDialog && responseObject == nil)
            //                [self ErrorHandler:@{ @"message" : @"خطا در سرویس"}];
            
            else if (self->ShowFailedDialog && self->FailedHandler != nil && error != nil) {
                self->FailedHandler(error.userInfo);
            }
            [self action_toasterror:statusCode];
            //            isRequestingRefreshToken = FALSE;
        }
        if ([response.URL.relativePath isEqualToString:@"/users/v3/auth/refresh"] ) {
            isRequestingRefreshToken = FALSE;
        }
    }] resume];
    
}


/**
 * description : upload file request
 */
- (void)CallMultiPart:(NSString*)Method files:(NSMutableArray*)Files auth:(BOOL)Auth {
    
    //--Request
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@",WS_URL,Method] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        UIImage *IMG = [Files firstObject];
        UIImage *IMGScaled = [core_utils imageWithImage:IMG scaledToWidth:900];
        [formData appendPartWithFileData:UIImageJPEGRepresentation(IMGScaled,0.95f) name:@"image" fileName:[NSString stringWithFormat:@"file_1.jpg"] mimeType:@"image/jpeg"];
    } error:nil];
    
    
    //-- Auth Check,Set
    if (Auth) {
        if ([SecurityManager getJWT] != nil && [SecurityManager getTokenType] != nil)
            [request setValue:[NSString stringWithFormat:@"%@ %@",[SecurityManager getTokenType],[SecurityManager getJWT]] forHTTPHeaderField:@"Authorization"];
    }
    
    //--Request Header
    self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [[self.manager
      uploadTaskWithStreamedRequest:request
      progress:^(NSProgress * _Nonnull uploadProgress) {
          /*
           * Progress Bar Delegate
           */
      } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
          [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
          //-- Logs
          //NSLog(@"%@ \n %@",response,responseObject);
          /*
           * Response Handler
           */
          [self HeaderAuth:[(NSHTTPURLResponse *)response allHeaderFields]];
          NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
          
          if (statusCode >= 200 && statusCode <= 299) { //Success
              if (self->SuccessHandler != nil)
                  self->SuccessHandler(responseObject);
              //          } else if (statusCode == 403) { //Auth Problem.
              //              [self action_authproblem];
          } else if (statusCode == 401 || statusCode == 403) { //Auth Problem.
              [self refresh_token];
          } else {
              if (self->FailedHandler != nil)
                  self->FailedHandler(responseObject);
              if (self->ShowFailedDialog && responseObject != nil)
                  [self ErrorHandler:responseObject];
              [self action_toasterror:statusCode];
          }
      }] resume];
    
}


/**
 * description : header request
 */
- (NSMutableURLRequest*)HeaderRequest:(NSMutableURLRequest*)req {
    req.timeoutInterval = 60;
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setValue:WS_APIKey forHTTPHeaderField:@"api-key"];
    [req setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"] forHTTPHeaderField:@"X-DEVICE-TOKEN"];
    [req setValue:@"0" forHTTPHeaderField:@"X-DEVICE-TYPE"];
    [req setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"X-APP-VERSION"];
    return req;
}


/*
 * description : Header Auth Database Config
 */
- (void)HeaderAuth:(NSDictionary * _Nonnull)HeadersField {
    if ([HeadersField objectForKey:@"X-ACCESS-TOKEN"]) {
        NSLog(@"\n refresh_token: %@", [HeadersField objectForKey:@"X-REFRESH-TOKEN"]);
        [SecurityManager setJWT:[HeadersField objectForKey:@"X-ACCESS-TOKEN"]];
        [SecurityManager setRefreshToken:[HeadersField objectForKey:@"X-REFRESH-TOKEN"]];
        [SecurityManager setTokenType:[HeadersField objectForKey:@"X-TOKEN-TYPE"]];
        [SecurityManager setExpiresIn:[HeadersField objectForKey:@"X-EXPIRES-IN"]];
    }
}


/*
 * description : Actions after Request
 */
- (void)action_authproblem {
    NSLog(@"[AUTH]: Switch To Login.");
    
    //-- Clear Database
    [database clean_logout];
    
    //-- Cancel All Operations
    AFHTTPSessionManager *coremanager = [AFHTTPSessionManager manager]; //manager should be instance which you are using across application
    [coremanager.session invalidateAndCancel];
    
    //-- Clear KeyChain
    [SecurityManager Clear];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        id appdelegate = [[UIApplication sharedApplication] delegate];
        if ([appdelegate respondsToSelector:@selector(App_SwitchLogin)])
            [appdelegate App_SwitchLogin];
    });
    
}

- (void)refresh_token {
    
    NSLog(@"%@\n refresh_token: ", [SecurityManager getRefreshToken]);
    if (SecurityManager.getRefreshToken == nil) {
        if (self->FailedHandler != nil) {
            self->FailedHandler(@{ @"local error" : @"token failed"});
            return;
        }
    }
    NSDictionary *bodyrequest = @{@"refresh_token":[SecurityManager getRefreshToken],
                                  @"appid":@"59bec3fa0eca810001ceeb86"};
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@",[self ServiceURL:API_SERVICE_ACCOUNT],@"/v3/auth/refresh"];
    if (isRequestingRefreshToken) {
        return;
    } else {
        isRequestingRefreshToken = TRUE;
        [self Call:MethodURL body:bodyrequest request:@"POST" auth:false];
    }
}

- (void)action_toasterror:(NSInteger)statusCode {
    NSLog(@"Toast Error %ld",(long)statusCode);
}


/**
 * description : cancel request
 */
- (void)cancelRequest {
    AFHTTPSessionManager *coremanager = [AFHTTPSessionManager manager];
    [coremanager.session invalidateAndCancel];
    [[self.manager operationQueue] cancelAllOperations];
}


/*
 * description : Error Handler, Show Dialog
 */
- (void)ErrorHandler:(NSDictionary*)Response {
    if ([self.delegate isKindOfClass:[UIViewController class]])
        [[(UIViewController *)self.delegate view] endEditing:YES];
    
    //--
    NSString *Message = @"";
    @try {
        if ([Response objectForKey:@"errors"]) {
            NSDictionary *Errors = [Response objectForKey:@"errors"];
            for (NSString *Key in Errors) {
                NSArray *Values = [Errors objectForKey:Key];
                for (int i = 0; i<[Values count]; i++) {
                    Message = [Message stringByAppendingString:[NSString stringWithFormat:@"%@\n",[Values objectAtIndex:i]]];
                }
            }
            if ([Message length] > 2)
                Message = [Message stringByReplacingOccurrencesOfString:@"\n" withString:@""];//[Message substringToIndex:[Message length] - 2];
            else
                Message = @"server.error".localizedLowercaseString;
        } else if ([Response objectForKey:@"message"]) {
            Message = [Response objectForKey:@"message"];
        }
        
    } @catch (NSException *exception) {
        @try {
            if ([Response objectForKey:@"message"] != nil)
                Message = [Response objectForKey:@"message"];
            else
                Message = @"خطایی رخ داده است. دوباره تلاش کنید.";
        } @catch (NSException *exception) {
            Message = @"--";
        }
    }
    
    //--Show Dialog
    [self ShowErrorDialog:Message];
}

- (void)TokenErrorHandler:(NSDictionary*)Response {
    if ([self.delegate isKindOfClass:[UIViewController class]])
        [[(UIViewController *)self.delegate view] endEditing:YES];
    
    //--
    NSString *Message = [MCLocalization stringForKey:@"Token_Error"];
    //--Show Dialog
    [self ShowErrorDialog:Message];
}


- (void)ShowErrorDialog:(NSString*)Message {
    MC_message_dialog *Dialog = [[MC_message_dialog alloc]  initWithTitle:[MCLocalization stringForKey:@"GLOBAL_BLOCK"]
                                                                  message:Message
                                                                 delegate:[UIApplication sharedApplication].delegate.window.rootViewController];
    MC_ActionDialog *Ok = [MC_ActionDialog actionWithTitle:[MCLocalization stringForKey:@"GLOBAL_BLOCK"] style:MCMessageDialogActionButtonBlue handler:nil];
    [Dialog addAction:Ok];
    [Dialog ShowDialog];
}


@end
