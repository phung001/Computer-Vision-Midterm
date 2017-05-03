# Computer-Vision-Midterm

### Description

Assignment to overlay an image over several frames of a video, each with varying square shapes. The script uses image thresholding, edge detection, and RANSAC line fitting to determine the square and its corners. Then it estimates a homography transformation to transform the landscape image and overlay it on the pink image. 

The Matlab script takes a total of 350 images located in the "images" folder:

![alt text](https://github.com/phung001/Computer-Vision-Midterm/blob/master/images/video%20001.jpg)

and overlays the following image over the pink square.

![alt text](https://github.com/phung001/Computer-Vision-Midterm/blob/master/landscape_small.jpg)

### Output Video

https://drive.google.com/open?id=0B8hGKwjNNbSTMVFPSHRDWm1DY1k

#### Credit

Most work created by Professor Anastasios Mourikis. Leaving the image thresholding, Canny edge detection, RANSAC line fitting, and corner detection to me, Peter Hung.
