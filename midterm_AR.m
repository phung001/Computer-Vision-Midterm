close all
clear all

% the image we will embed
Im_embed = im2double(imread('landscape_small.jpg'));

% load the results -- THESE SHOULD ONLY BE USED AS REFERENCE, NOT AS PART
% OF YOUR SOLUTION
load AR_intermediate_results 

% initialize the video file (note: you may need to use a different encoding
% option if you are using a different OS. This code works with Windows 7, and 
% should hopefully work with other OS's as well).
vid = VideoWriter('video_result.avi','Motion JPEG AVI');
open(vid)

%Find average pink value.        
Im_orig = im2double(imread(['images/video ',num2str(1,'%03d'),'.jpg']));
avgPinkR = mean(mean(Im_orig(230:250, 310:330, 1)))
avgPinkG = mean(mean(Im_orig(230:250, 310:330, 2)))
avgPinkB = mean(mean(Im_orig(230:250, 310:330, 3)))

for frame = 1:350
    frame
    
    % open the image
    try
        Im_orig = im2double(imread(['images/video ',num2str(frame,'%03d'),'.jpg']));
    catch
        continue
    end
        
    %%% YOUR CODE HERE 
    
    %Find the average pink RGB values for comparison
    avgPinkR = mean(mean(Im_orig(230:250, 310:330, 1)));
    avgPinkG = mean(mean(Im_orig(230:250, 310:330, 2)));
    avgPinkB = mean(mean(Im_orig(230:250, 310:330, 3)));
    
    %Remove all except pink RGB values into new picture
    newIm = zeros(480, 640, 'double');
    for i = 1:480
        for j = 1:640
            if (Im_orig(i,j,1) > avgPinkR - 0.13) && (Im_orig(i,j,1) < avgPinkR + 0.13)
                if (Im_orig(i,j,2) > avgPinkG - 0.13) && (Im_orig(i,j,2) < avgPinkG + 0.13)
                    if (Im_orig(i,j,3) > avgPinkB - 0.13) && (Im_orig(i,j,3) < avgPinkB + 0.13)
                        newIm(i,j) = 1;
                    end
                end
            end
        end
    end
    
    %Apply edge detection
    newIm = my_canny(newIm, 1, 0.5, 0.5/3);
    
    %-----RANSAC line fitting-----
    %get coordinates of inlines and remove them from image, repeat 4 times
    [newRow, newCol] = find(newIm == 1);
    [d1 theta1 inLines] = ransac_theta_d([newRow, newCol], 2, 107);
    for i = 1:length(inLines)
        if  inLines(i) == 1
            newIm(newRow(i), newCol(i)) = 0;
        end
    end
    [newRow, newCol] = find(newIm == 1);
    [d2 theta2 inLines] = ransac_theta_d([newRow, newCol], 2, 107);
    for i = 1:length(inLines)
        if  inLines(i) == 1
            newIm(newRow(i), newCol(i)) = 0;
        end
    end
    [newRow, newCol] = find(newIm == 1);
    [d3 theta3 inLines] = ransac_theta_d([newRow, newCol], 2, 107);
    for i = 1:length(inLines)
        if  inLines(i) == 1
            newIm(newRow(i), newCol(i)) = 0;
        end
    end
    [newRow, newCol] = find(newIm == 1);
    [d4 theta4 inLines] = ransac_theta_d([newRow, newCol], 2, 107);
    for i = 1:length(inLines)
        if  inLines(i) == 1
            newIm(newRow(i), newCol(i)) = 0;
        end
    end
    
%     plot_image_lines(tempIm, [d1, d2, d3, d4], [theta1, theta2, theta3, theta4]); 
    
    %Find the intersections of the lines (6 combinations)
    x = [];
    A = [cos(theta1), sin(theta1); cos(theta2), sin(theta2)];
    B = [d1; d2];
    x = [x linsolve(A, B)];
    A = [cos(theta1), sin(theta1); cos(theta3), sin(theta3)];
    B = [d1; d3];
    x = [x linsolve(A, B)];
    A = [cos(theta1), sin(theta1); cos(theta4), sin(theta4)];
    B = [d1; d4];
    x = [x linsolve(A, B)];
    A = [cos(theta2), sin(theta2); cos(theta3), sin(theta3)];
    B = [d2; d3];
    x = [x linsolve(A, B)];
    A = [cos(theta2), sin(theta2); cos(theta4), sin(theta4)];
    B = [d2; d4];
    x = [x linsolve(A, B)];
    A = [cos(theta3), sin(theta3); cos(theta4), sin(theta4)];
    B = [d3; d4];
    x = [x linsolve(A, B)];
    
    %Filter out the bad intersections, and add it to an matrix
    cornersx = [];
    cornersy = [];
    for i = 1:6
        if x(1,i) > 0 && x(2,i) > 0 && x(1,i) < 480 && x(2,i) < 640
            cornersx = [cornersx x(2,i)];
            cornersy = [cornersy x(1,i)];
        end
    end
    
    %Find what each corner represents
    boxMid = [mean(cornersx), mean(cornersy)];                              
    topLeft = 0;
    topRight = 0;
    botLeft = 0;
    botRight = 0;
    for i = 1:4
        if cornersx(i) < boxMid(1) && cornersy(i) < boxMid(2)
            topLeft = [cornersy(i) cornersx(i)];
        elseif cornersx(i) > boxMid(1) && cornersy(i) < boxMid(2)
            topRight = [cornersy(i) cornersx(i)];
        elseif cornersx(i) < boxMid(1) && cornersy(i) > boxMid(2)
            botLeft = [cornersy(i) cornersx(i)];
        else
            botRight = [cornersy(i) cornersx(i)];
        end
    end
    
    %Create matrix for corners, and corresponding 
    %corners of the embedded image
    cornerFeatures = [topLeft; topRight; botLeft; botRight];
    cornerEmbed = [ [0,0]; [0,500]; [375,0]; [375,500] ];
    transform = estimate_homography(cornerEmbed,cornerFeatures);

    %% Your task is to write code that will compute this transformation
     %transform = results(frame).transform;
    
    % get the new image that has the embedded photo in it
    Imnew = create_new_image_AR(Im_orig, Im_embed, transform);
    
    imshow(Imnew)
    pause(0.01)
    
    % add the new frame to the video
    writeVideo(vid,Imnew)
end
 
% close the video file
close(vid)
             
 