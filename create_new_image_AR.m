function Im_out = create_new_image_AR(Im_orig, Im_embed, H)

% interpolate the three channels independently
Imnew1 = create_transformed_image(Im_embed(:,:,1),H,size(Im_orig,1),size(Im_orig,2));
Imnew2 = create_transformed_image(Im_embed(:,:,2),H,size(Im_orig,1),size(Im_orig,2));
Imnew3 = create_transformed_image(Im_embed(:,:,3),H,size(Im_orig,1),size(Im_orig,2));

% figure out which are invalid pixels:
bad_ind = isnan(Imnew1);

% now merge the two images, each channel independently
Im_org1 = Im_orig(:,:,1);
Im_out1 = zeros(size(Im_orig,1),size(Im_orig,2));
Im_out1(bad_ind) = Im_org1(bad_ind);
Im_out1(~bad_ind) = Imnew1(~bad_ind);

Im_org2 = Im_orig(:,:,2);
Im_out2 = zeros(size(Im_orig,1),size(Im_orig,2));
Im_out2(bad_ind) = Im_org2(bad_ind);
Im_out2(~bad_ind) = Imnew2(~bad_ind);

Im_org3 = Im_orig(:,:,3);
Im_out3 = zeros(size(Im_orig,1),size(Im_orig,2));
Im_out3(bad_ind) = Im_org3(bad_ind);
Im_out3(~bad_ind) = Imnew3(~bad_ind);

% create the output image
Im_out(:,:,1) = Im_out1;
Im_out(:,:,2) = Im_out2;
Im_out(:,:,3) = Im_out3;
 
