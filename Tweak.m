
#import <substrate.h>
#import <sys/sysctl.h>

static NSString *mobileName = nil;
static NSString *mobileNameKey = @"deviceName";

%ctor
{
    mobileName = [[NSUserDefaults standardUserDefaults] objectForKey:mobileNameKey];
}

NSString *mobieNameByOriginName(NSString *oldName)
{
    if (mobileName)
    {
        return mobileName;
    }
    else
    {
        return oldName;
    }
}

%hook QQChatViewController

- (BOOL)sendTextMsg:(id)arg1 showText:(NSString *)arg2
{
    if ([arg2 containsString:@"设备型号"]) {
        mobileName = [arg2 substringFromIndex:@"设备型号".length];
        [[NSUserDefaults standardUserDefaults] setObject:mobileName forKey:mobileNameKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if ([arg2 containsString:@"设备型号原值"])
    {
        mobileName = nil;
        [[NSUserDefaults standardUserDefaults] setObject:mobileName forKey:mobileNameKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return %orig;
}

%end

%hook UIDevice

- (id)platform
{
    id ret = %orig;
    return mobieNameByOriginName(ret);
}

%end

%hook APMDeviceInfo

+ (id)platform
{
    id ret = %orig;
    return mobieNameByOriginName(ret);
}

%end

%hook BeaconDeviceUtil

//对应手机在线状态
+ (id)model {
    id ret = %orig;
    return mobieNameByOriginName(ret);
}
%end

%hook QZDevice

//对应QQ空间说说手机型号
- (id)getModel
{
    id ret = %orig;
    return mobieNameByOriginName(ret);
}

%end