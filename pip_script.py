import os
import subprocess as sp
import sys

# before running this script,
# make sure videos are named STUDYNAME_SUBJECTID_RN_BABY.mp4 and
# STUDYNAME_SUBJECTID_RN_STIM.mp4

# This script will take 2 videos, trim them using the same timecodes,
# and then make a picture in picture video from these two trimmed videos.
# The final video will end in the appendix "_processed.mp4"

# Version history:
# Updated by Shari Liu on 9/22/2020

# ---------- FILL IN -----------------------------

# change to your own directory
videoPath = '/Users/shariliu/Downloads/'

# baby video name
babyVideo = 'PracticeVid1_BabyView.mp4'

# stim video name
stimVideo = 'PracticeVid1_StimView.mp4'

# start and end of each session hours:minutes:seconds
# should be beginning of calibration until end of pref looking period
startTime = '00:22:40'
endTime = '00:31:52'

## ----------- DO NOT EDIT WITHOUT ASKING ---------

subjectName = babyVideo.replace('_BabyView.mp4','')
processedVideo = subjectName + "_Processed.mp4"
videoFiles = os.listdir(videoPath)

# trim baby video
sp.call([
    "ffmpeg",
     '-ss', startTime,
     '-i', os.path.join(videoPath, babyVideo), \
     '-c', 'copy',
     '-t', endTime,
     os.path.join(videoPath, subjectName + "_Baby_Trimmed.mp4")
    ])

# trim stim video
sp.call([
    "ffmpeg",
     '-ss', startTime,
     '-i', os.path.join(videoPath, stimVideo), \
     '-c', 'copy',
     '-t', endTime,
     os.path.join(videoPath, subjectName + "_Stim_Trimmed.mp4")
    ])

sp.call(
    ["ffmpeg", \

     #big video
    "-i", os.path.join(videoPath, subjectName + "_Baby_Trimmed.mp4"), \

     #little video
    "-i", os.path.join(videoPath, subjectName + "_Stim_Trimmed.mp4"), \

    # feel free to play with these options about position and size
    #"-filter_complex", "[1]scale=iw/4:ih/4 [pip]; [0][pip] overlay=main_w-overlay_w-10:main_h-overlay_h-10", \
    "-filter_complex", "[1]scale=iw/4:ih/4 [pip]; [0][pip] overlay=main_w-overlay_w:main_h-main_h", \

	"-profile:v", "main", \
    "-level", "3.1", \
    "-b:v", "440k", \
    "-ar", "44100", \
    "-ab", "128k", \
   # "-s", "720x400", \
    "-vcodec", "h264", \
    "-c:a", "aac", \
	os.path.join(videoPath, processedVideo)
    ])