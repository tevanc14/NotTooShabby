# Changelog

## [0.19.0] - 2020-02-04

Added

- `Runner.entitlements` to avoid Apple issue ITMS-90078

## [0.18.0] - 2020-02-03

Changed

- Corrections according to Pedantic
- Fix inability to play video on iOS

## [0.17.0] - 2020-02-03

Added

- Pedantic static analysis

Changed

- Updated YouTube Player dependency
- Cleaned up code organization of playing a video

## [0.16.0] - 2019-10-17

Changed

- Firebase encryption pattern
- Removed alpha channel from app icons

## [0.15.1] - 2019-06-14

Added

- Encrypted Firebase files for build processes

Removed

- Old iOS app icons

## [0.15.0] - 2019-05-28

Added

- Size the player button and written title proportionally to the screen

## [0.14.0] - 2019-05-28

Added

- Reorder videos on watch history page when rewatching a video from that page

Changed

- Check for no videos when creating the stats dialog

## [0.13.0] - 2019-05-28

Added

- Privacy policies

## [0.12.0] - 2019-05-26

Added

- Watch stats dialog
  - Most watched video with count
  - Total watch count

## [0.11.0] - 2019-05-25

Added

- Change video player layout when orientation changes

## [0.10.0] - 2019-05-18

Added

- App icon for iOS

## [0.9.0] - 2019-05-18

Added

- Custom launch screen for Android

## [0.8.0] - 2019-05-16

Added

- Android launch icon
- Roboto Condensed font
- Written title on random video page

Changed

- Convert to AndroidX
- Play video button to logo button

## [0.7.0] - 2019-04-28

Added

- Firebase analytics for iOS

## [0.6.1] - 2019-04-19

Changed

- Unified size of text on info page

## [0.6.0] - 2019-03-30

Added

- Firebase analytics with events for when a video is played
- Blank grey boxes to represent thumbnails while loading

## [0.5.2] - 2019-03-28

Changed

- Fixed bug where a new file would never be retrieved from Cloud Storage as it was only checking if the file was not empty

## [0.5.1] - 2019-03-27

Changed

- Only go into watch history page when the parameters are not null (prevents an error if navigating to the page faster than it can read/download the data files)

## [0.5.0] - 2019-03-27

Added

- Watch history loads a number of results at a time (to avoid trying to render a thousand tiles unnecessarily)

## [0.4.0] - 2019-03-26

Added

- Watch history info text on about page

Changed

- Spacing on about page

## [0.3.2] - 2019-03-26

Changed

- Altered color scheme
- Renamed some functions
- Broke out play button into widgets as opposed to functions

## [0.3.1] - 2019-03-25

Added

- Android app signing

Changed

- Wait on video detail file to get loaded so it doesn't error out the first time opening the app

## [0.3.0] - 2019-03-24

Added

- Can play a video from the Watch History screen
- Show total number of Not Too Shabby videos that exist

Changed

- Miscellaneous cleanup

## [0.2.0] - 2019-03-24

Added

- Use entire video detail object as opposed to just ids
- Page that keeps a local record of watch history
- SnackBar when loading the app for the first time with no internet connection

## [0.1.3] - 2019-03-19

Changed

- Fixed bug where file access would throw errors on first app load

## [0.1.2] - 2019-03-19

Changed

- Enlarged play button
- App display names
- Useful README

## [0.1.1] - 2019-03-17

Changed

- YouTube API key (and removed from source control)
- Removed debugging statements

## [0.1.0] - 2019-03-11

Added

- Read a list of videoIds from a GCS bucket (populated by Cloud Function)
- Cache videoId list locally

## [0.0.1] - 2019-03-05

Added

- Working video randomizer
- About screen
