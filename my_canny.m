function [edgeimage, chainlist] = my_canny(Im, sigma, T_high,T_low)
% this function uses double thresholding, and nonmaximal suppresion
% it is written in the spirit of Canny's edge detector
% it returns the edge image, and the coordinates of the linked edge pixels

%% smooth the image
halfsize = 3*sigma;
x = [-halfsize:halfsize];
g = normpdf(x, 0, halfsize/3);
g2 = conv2(g,g');
g2 = g2/sum(sum(g2));
Im = filter2(g2,Im,'same');

[m,n] = size(Im); 

%apply the sobel operator:
filtx = [-1 0 1; 
		-2 0 2; 
		-1 0 1];
filty = filtx';
Ix=conv2(Im,filtx,'same');
Iy=conv2(Im,filty,'same');

%gradient magnitude
Gradient_mag = sqrt(Ix.^2 + Iy.^2);

% at this point in the code the image Gradient_mag should contain the
% magnitude of the image gradient at each pixel location
% figure
% imshow(Gradient_mag)

%nonmaximal suppression
Gradient_mag = Gradient_mag+eps; %this is to avoid divisions by zero in the next steps
[mj,mi]=meshgrid(1:n,1:m);

%the points we use to test for maximum (left and right of the edge, along the gradient direction)
test1_i = mi(:) - .4*Iy(:)./Gradient_mag(:);
test1_j = mj(:) - .4*Ix(:)./Gradient_mag(:);

test2_i = mi(:) + .4*Iy(:)./Gradient_mag(:);
test2_j = mj(:) + .4*Ix(:)./Gradient_mag(:);

%the interpolated values we use to test for maximum 
val1 = interp2(Gradient_mag , test1_j,test1_i); 
val2 = interp2(Gradient_mag , test2_j,test2_i);

%we keep all points above the high threshold, and are maximum
Iedge_vec = Gradient_mag(:).*(Gradient_mag(:) > T_low).*(Gradient_mag(:) > val1).* (Gradient_mag(:) > val2);

%the edge image:
Edge_image_magnitude = reshape(Iedge_vec,m,n);

%% here Edge_image_magnitude should be an image where the pixels that are 
%% local maxima along the gradient, and have values above T_low, have value
%% equal to their gradient magnitude, and everything else should be zero
% figure
% imshow(Edge_image_magnitude)

%----------------------------------------
% the code below implements edge following to find connected edge segments
%----------------------------------------
%the nonzero elements: 
Inonzero = find(Edge_image_magnitude);
chainlist=[];

%edge following:
no_of_chains=0;
for ii=1:length(Inonzero)
	
	%get the next point in the list of edgels
	[r,c] = ind2sub([m n], Inonzero(ii));
	
	% if the point has not been already visited:
	if Edge_image_magnitude(r,c) > 0
		if Edge_image_magnitude(r,c) > T_high
			found_high_thresh=true;
		else
			found_high_thresh=false;
		end
		%set the pixel to zero, so that we don't take into consideration again
		Edge_image_magnitude(r,c)=0;
		%start a new chain 
		chain = [r c];
		end_of_chain = false;
		%find next pixel in the chain
		while (~end_of_chain)
			%function that returns the next pixel in the chain, if it exists
			[r,c, above_high_thresh , Edge_image_magnitude] = next_pixel_exists(Edge_image_magnitude, Ix(r,c), Iy(r,c), r, c, T_high);
			if r > 0
				%then the chain continues.
				%we check for pixels above the high threshold
				if above_high_thresh
					found_high_thresh=true;
				end
				%add the point to the chain
% 				chain = [chain sub2ind([m n],r,c)];
				chain = [chain ;[r c]];
			else
				% we've visited all the pixels of the chain. check if the edge is an acceptable one:
				% discard small chains (<4 pixels) and those that have no pixels above the high threshold
				if (found_high_thresh & length(chain) > 3  )
					no_of_chains = no_of_chains+1;
					chainlist(no_of_chains).chain = chain;
				end
				end_of_chain = true;
			end
			
		end
		
	end
end


% create the final output image, showing only the accepted edges
edgeimage = zeros(size(Im));
for i=1:length(chainlist)
	for j = 1:size(chainlist(i).chain,1)
		edgeimage(chainlist(i).chain(j,1),chainlist(i).chain(j,2))=1;
	end
end
 
