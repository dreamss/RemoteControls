    //
// RemoteControls.m
// Now Playing Cordova Plugin
//
// Created by François LASSERRE on 12/05/13.
// Copyright 2013 François LASSERRE. All rights reserved.
// MIT Licensed
//

#import "RemoteControls.h"

@implementation RemoteControls

static RemoteControls *remoteControls = nil;

- (void)pluginInitialize
{
    NSLog(@"RemoteControls plugin init.");
}

- (void)updateMetas:(CDVInvokedUrlCommand*)command
{
    NSString *artist = [command.arguments objectAtIndex:0];
    NSString *title = [command.arguments objectAtIndex:1];
    NSString *album = [command.arguments objectAtIndex:2];
    NSString *cover = [command.arguments objectAtIndex:3];
    NSString *duration = [command.arguments objectAtIndex:4];

    NSString* basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@%@", basePath, cover];
    
    MPMediaItemArtwork *albumArt;
    if (NSClassFromString(@"MPNowPlayingInfoCenter"))  {
        MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
        NSDictionary *songInfo = @{
                                   MPMediaItemPropertyTitle: title,
                                   MPMediaItemPropertyArtist: artist,
                                   MPMediaItemPropertyAlbumTitle:album,
                                   MPMediaItemPropertyPlaybackDuration : duration
                                   };
        center.nowPlayingInfo = songInfo;
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
        if(fileExists){
            UIImage *image = [UIImage imageNamed:fullPath];
            albumArt = [[MPMediaItemArtwork alloc] initWithImage:image];
            NSMutableDictionary *playingInfo = [NSMutableDictionary dictionaryWithDictionary:center.nowPlayingInfo];
            [playingInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
            center.nowPlayingInfo = playingInfo;
        }
    }
}


- (void)receiveRemoteEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        NSString *subtype = nil;
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                NSLog(@"playpause clicked.");
                subtype = @"playpause";
                break;
                
            case UIEventSubtypeRemoteControlPlay:
                NSLog(@"play clicked.");
                subtype = @"play";
                break;
                
            case UIEventSubtypeRemoteControlPause:
                NSLog(@"nowplaying pause clicked.");
                subtype = @"pause";
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                //[self previousTrack: nil];
                NSLog(@"prev clicked.");
                subtype = @"prevTrack";
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"next clicked.");
                subtype = @"nextTrack";
                //[self nextTrack: nil];
                break;
                
            default:
                break;
        }
        NSDictionary *dict = @{
                               @"subtype": subtype
                               };
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options: 0 error: nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString *jsStatement = [NSString stringWithFormat:@"window.plugins.remoteControls.receiveRemoteEvent(%@);", jsonString];
        [self.webView stringByEvaluatingJavaScriptFromString:jsStatement];  

    }
}

+(RemoteControls *)remoteControls
{
    //objects using shard instance are responsible for retain/release count
    //retain count must remain 1 to stay in mem
    
    if (!remoteControls)
    {
        remoteControls = [[RemoteControls alloc] init];
    }
    
    return remoteControls;
}


@end