function Inew = create_transformed_image(I,A,m,n) 
% I is the input grayscale image, A is the 3x3 transform matrix 
% this function creates an image Inew, such that the image values satisfy
% I(row,col) = Inew(rowprime,colprime),
% where [rowprime;colprime,1] = A*[row;col;1]

% get the coordinates of all the pixels in Inew (these are xprime, yprime)
[r,c] = meshgrid([1:m], [1:n]);

% find the corresponsing coordinates in I
% note that we need to invert A here, 
I_coord = inv(A)*[r(:)';c(:)';ones(1,length(r(:)))];

% this is required in case the transform is a homography, otherwise it is has
% no effect, as all the 3rd coordinates will equal 1.
I_coord = [I_coord(1,:)./I_coord(3,:);
	       I_coord(2,:)./I_coord(3,:)];
             
% get the values from the input image           
val = interp2(I(:,:,1), I_coord(2,:), I_coord(1,:));

% reshape the values to get the image
Inew = reshape(val,n,m)';
