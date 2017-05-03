# Computer-Vision-Midterm

### Description

Assignment to overlay an image over several frames of a video, each with varying rectangle shapes. The script uses image thresholding, edge detection, and RANSAC line fitting to determine the rectangle and its corners. Then it estimates a homography transformation to transform the landscape image and overlay it on the pink image. 

The Matlab script takes a total of 350 images located in the "images" folder:

![alt text](https://github.com/phung001/Computer-Vision-Midterm/blob/master/images/video%20001.jpg)

Uses a combination of image thresholding, edge detection, and line fitting to determine the rectangle and its corners:

![alt text](https://github.com/phung001/Computer-Vision-Midterm/blob/master/Corners.PNG)

And overlays the following image over the pink rectangle.

![alt text](https://github.com/phung001/Computer-Vision-Midterm/blob/master/landscape_small.jpg)

### Output Video

https://drive.google.com/open?id=0B8hGKwjNNbSTMVFPSHRDWm1DY1k

### Running

To run the script, simply download all the files and run the "midterm_AR.m" file on Matlab. 

#### Credit

Most work created by Professor Anastasios Mourikis. Leaving the image thresholding, Canny edge detection, RANSAC line fitting, and corner detection to me, Peter Hung.
