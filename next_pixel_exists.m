function [r,c, above_high_thresh, Iedge] = exists_next_pixel(Iedge, Ix, Iy, r, c, high_thresh);
% returns the next pixle in the chain, or a negative value if the next pixel does not exist

%make the 3x3 window around the pixel
window = Iedge(r-1:r+1,c-1:c+1);
%make the center of the window equal to zero;
window(2,2) = 0;

%see how many responses we get:
response_no = length(find(window));
if response_no == 0
	above_high_thresh= false;
	r = -1;
	c = -1;
	return
end

% else find the next pixel in the chain
% we check all the adjacent pixels one by one, and return the
% pixel that is nonzero

%initialization:
above_high_thresh=false;


if window(1,1) > 0
	%check if te pixel value is above the high threshold
	if window(1,1) > high_thresh
		above_high_thresh=true;
	end
	%return the indices, and set the pixel to zero, to discard from further consideration
	r = r-1;
	c = c-1;
	Iedge(r,c) = 0;
	return
end


if window(1,2) > 0
	if window(1,2) > high_thresh
		above_high_thresh=true;
	end
	
	r = r-1;
	c = c;
	Iedge(r,c) = 0;
	return
end


if window(1,3) > 0
	if window(1,3) > high_thresh
		above_high_thresh=true;
	end
	
	r = r-1;
	c = c+1;
	Iedge(r,c) = 0;
	return
end


if window(2,1) > 0
	if window(2,1) > high_thresh
		above_high_thresh=true;
	end
	
	r = r;
	c = c-1;
	Iedge(r,c) = 0;
	return
end


if window(2,3) > 0
	if window(2,3) > high_thresh
		above_high_thresh=true;
	end
	
	r = r;
	c = c+1;
	Iedge(r,c) = 0;
	return
end

if window(3,1) > 0
	if window(3,1) > high_thresh
		above_high_thresh=true;
	end
	
	r = r+1;
	c = c-1;
	Iedge(r,c) = 0;
	return
end



if window(3,2) > 0
	if window(3,2) > high_thresh
		above_high_thresh=true;
	end
	
	r = r+1;
	c = c;
	Iedge(r,c) = 0;
	return
end

 
if window(3,3) > 0
	if window(3,3) > high_thresh
		above_high_thresh=true;
	end
	
	r = r+1;
	c = c+1;
	Iedge(r,c) = 0;
	return
end

