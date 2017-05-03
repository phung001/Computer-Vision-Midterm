function plot_image_lines(Im,d_eq,theta_eq) 

figure
imshow(Im)
hold on

rows = [1:size(Im,1)];

for i = 1:length(d_eq)
	cols = (d_eq(i) - rows*cos(theta_eq(i)))/sin(theta_eq(i));
	ind = find(cols>1 & cols<size(Im,2));
	plot(cols,rows,'g')
end