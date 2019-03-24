# Not Too Shabby

## Application Description

Plays a random video from the "Not Too Shabby" YouTube playlist by kisscactus

## How does it work

### Backend

There is a Google Cloud Function that is triggered by a Cloud Pub/Sub message which is sent once a day by a Cloud Scheduler. This function uses the YouTube data API to gather a list of video details from the YouTube playlist. A file containing the video details is then pushed to a Cloud Storage bucket.

### Frontend

The app pulls down and caches (in another local file) the aforementioned file. Once this file is loaded, a random video is selected and played. Each play is recorded in yet another local file for a watch history.

#### Why local storage

This application was designed to be serverless, easy, and cheap. Local storage was elected at first because a very small amount of data was going to be stored. And it continued to be the choice as it caused no large issues and would get the job done and it used very little data.
