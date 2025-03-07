#import "AppDelegate.h"

#import "ExposureNotification.h"

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import "RNSplashScreen.h"
#import <UserNotifications/UserNotifications.h>
#import <RNCPushNotificationIOS.h>
#import <React/RCTLinkingManager.h>

#import <TSBackgroundFetch/TSBackgroundFetch.h>
#import <BackgroundTasks/BackgroundTasks.h>
#import <objc/runtime.h>

#import <UMCore/UMModuleRegistry.h>
#import <UMReactNativeAdapter/UMNativeModulesProxy.h>
#import <UMReactNativeAdapter/UMModuleRegistryAdapter.h>

#import "MetricsService.h"

static void patchBGTaskSubmission(void);

@interface AppDelegate () <RCTBridgeDelegate>

@property (nonatomic, strong) UMModuleRegistryAdapter *moduleRegistryAdapter;

@end

@implementation AppDelegate

// Required to register for notifications
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
 [RNCPushNotificationIOS didRegisterUserNotificationSettings:notificationSettings];
}

-(BOOL)application:(UIApplication *)application
openURL:(NSURL *)url
options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
return [RCTLinkingManager application:application openURL:url options:options];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
  return [RCTLinkingManager
            application:application
            continueUserActivity:userActivity
            restorationHandler:restorationHandler
         ];
}
// Required for the register event.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
 [RNCPushNotificationIOS didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}
// Required for the notification event. You must call the completion handler after handling the remote notification.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
  [RNCPushNotificationIOS didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}
// Required for the registrationError event.
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
 [RNCPushNotificationIOS didFailToRegisterForRemoteNotificationsWithError:error];
}
// IOS 10+ Required for localNotification event
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler
{
  [RNCPushNotificationIOS didReceiveNotificationResponse:response];
  completionHandler();
}
// IOS 4-10 Required for the localNotification event.
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
 [RNCPushNotificationIOS didReceiveLocalNotification:notification];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleRegistryAdapter = [[UMModuleRegistryAdapter alloc] initWithModuleRegistryProvider:[[UMModuleRegistryProvider alloc] init]];

  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
                                                   moduleName:@"CovidShield"
                                            initialProperties:nil];

  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  // #002D42
  UIColor *linkBlue = [UIColor colorWithRed:2.0f / 255.0f green:120.0f / 255.0f blue:164.0f / 255.0f alpha:1];
  // Sets the default tint color for native components like ActionSheet.
  self.window.tintColor = linkBlue;
  // This is needed to tint the keyboard done button.
  UIToolbar.appearance.tintColor = linkBlue;
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];

  [super application:application didFinishLaunchingWithOptions:launchOptions];

  if([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground) {
    UIStoryboard *launchScreenStoryboard = [UIStoryboard storyboardWithName:@"Launch Screen" bundle:nil];
    UIViewController *launchScreenController = [launchScreenStoryboard instantiateInitialViewController];
    UIView *launchScreenView = [launchScreenController view];
    launchScreenView.frame = self.window.bounds;
    rootView.loadingView = launchScreenView;
  }

  if ([ExposureNotification exposureNotificationSupportType] == ENSupportTypeVersion13dot5AndLater) {
    // [REQUIRED] Register BackgroundFetch
    patchBGTaskSubmission();
    [[TSBackgroundFetch sharedInstance] didFinishLaunching];
  }
  
  MetricsService *metricsService = [MetricsService sharedInstance];
  
  // Will be called when the app starts from either foreground or background
  [metricsService publishMetric:ActiveUser bridge:bridge];
  
  /* If we feel like this listener is not doing the job properly we can try a different solution:
   "Immediately upon launch, you can check if applicationState equals UIApplicationStateBackground in order to determine whether your app was launched into the background."
   */
  [[TSBackgroundFetch sharedInstance] addListener:@"scheduled-check-started-listener" callback:^(NSString *componentName) {
    [metricsService publishMetric:ScheduledCheckStartedToday bridge:bridge];
  }];
  
  // Define UNUserNotificationCenter
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  center.delegate = self;

  return YES;
}

- (NSArray<id<RCTBridgeModule>> *)extraModulesForBridge:(RCTBridge *)bridge
{
    NSArray<id<RCTBridgeModule>> *extraModules = [_moduleRegistryAdapter extraModulesForBridge:bridge];
    // If you'd like to export some custom RCTBridgeModules that are not Expo modules, add them here!
    return extraModules;
}

//Called when a notification is delivered to a foreground app.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
  completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end
#pragma mark Patch for BackgroundTask submission
static IMP _BGTaskScheduler_submitTaskRequest_orig = NULL;

static BOOL preSubmitTaskHook(id me, SEL selector, BGTaskRequest *req, NSError **perr) {
  if([req isKindOfClass: [BGProcessingTaskRequest class]] &&
     [req.identifier isEqualToString: @"app.covidshield.exposure-notification"]) {
    ((BGProcessingTaskRequest*)req).requiresNetworkConnectivity = YES;
    ((BGProcessingTaskRequest*)req).requiresExternalPower = NO;
  }

  return ((BOOL (*)(id, SEL, BGTaskRequest*, NSError**))*_BGTaskScheduler_submitTaskRequest_orig)(me, selector, req, perr);
}


static void patchBGTaskSubmission() {
  SEL submitSelector = @selector(submitTaskRequest:error:);
  Class schedulerClass = objc_getClass("BGTaskScheduler");
  if(schedulerClass == nil) return;

  _BGTaskScheduler_submitTaskRequest_orig = class_replaceMethod(schedulerClass, submitSelector, (IMP)preSubmitTaskHook, "B@:@@");
}

