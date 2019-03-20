# Not Too Shabby

## Application Description

Plays a random video from the "Not Too Shabby" YouTube playlist by kisscactus

## How does it work

### Backend

There is a Google Cloud Function that is triggered by a Cloud Pub/Sub message which is sent once a day by a Cloud Scheduler. This function uses the YouTube data API to gather a list of video ids from the YouTube playlist. A file containing these ids is then pushed to a Cloud Storage bucket.

### Frontend

The app pulls down and caches the aforementioned file of video ids. Once this file is loaded, a random id is selected and played.
