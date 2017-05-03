function H_est = estimate_homography(Im1_feature_coordinates,Im2_feature_coordinates)
% the inputs are two Nx2 matrices, with the coordinates of the matching
% features in image one and two. These matrices have the following
% structure:
% Im1_feature_coordinates = [f1_row f1_col];
% Im2_feature_coordinates = [f2_row f2_col];

f1_row = Im1_feature_coordinates(:,1);
f1_col = Im1_feature_coordinates(:,2);

f2_row = Im2_feature_coordinates(:,1);
f2_col = Im2_feature_coordinates(:,2);

% make sure we have enough points
if length(f1_row)<4
    disp('Error: at least 4 points needed to estimate homograpy')
    return
end


%% get an initial estimate for the homography:
% To get an initial estimate for the homography, we solve a linear system similar
% to the one defined in Eq. 6.21 of Szeliski. The difference is that the vector of unknowns,
% H_vec, is defined so that the homography matrix is given by
% H_est = [H_vec(1) H_vec(2) H_vec(3);
%     H_vec(4) H_vec(5) H_vec(6);
%     H_vec(7) H_vec(8)      1];

M =[];
b = [];
for i = 1:length(f1_row)
    
    this_M = [f1_row(i) f1_col(i)  1    0            0      0   -f1_row(i)*f2_row(i)   -f2_row(i)*f1_col(i);
              0       0            0   f1_row(i) f1_col(i)  1   -f1_row(i)*f2_col(i)   -f2_col(i)*f1_col(i)];
    
    this_b = [f2_row(i); f2_col(i)];
    
    M = [M;this_M];
    b = [b;this_b];
end

%% get an initial guess by solving the linear system M*A_vec = b
H_vec = M\b; % equivalent to H_vec = (M'*M)\(M'*b), but numerically more stable

% The homography matrix is the following:
H_est = [H_vec(1) H_vec(2) H_vec(3);
    H_vec(4) H_vec(5) H_vec(6);
    H_vec(7) H_vec(8)      1];
 
%% now do iterative refinement using Levenberg-Marquardt, if we are using more than 4 points
if length(f1_row)>4
    lambda = 1;
    
    for iter = 1:20
        % the Hessian matrix (this is the A matrix of Eq. 6.18 in Szeliski)
        A_mat =zeros(8); 
        % the right-hand size of the system (b vector in Eq 6.17 in Szeliski)
        b_vec = zeros(8,1);
                
        H_est = [H_vec(1) H_vec(2) H_vec(3);
            H_vec(4) H_vec(5) H_vec(6);
            H_vec(7) H_vec(8)      1] ;
        
        % res2norm is the squared norm of the residual of all measurements
        res2norm=0;
        for i = 1:length(f1_row)
            
            % compute the residual vector, res, which is the difference between
            % the actual and predicted measurement
            pred_vec3 = H_est*[Im1_feature_coordinates(i,:)';1];
            % this is the predicted coordinate vector in Image 2:
            pred_vec2 = pred_vec3(1:2)/pred_vec3(3);
            res = Im2_feature_coordinates(i,:)' - pred_vec2;
            
            % the Jacobian wrt the transform parameters
            Jac = 1/pred_vec3(3)* [f1_row(i) f1_col(i)  1    0            0      0    -pred_vec2(1)*f1_row(i)   -pred_vec2(1)*f1_col(i);
                                     0       0          0   f2_row(i) f2_col(i)  1    -pred_vec2(2)*f1_row(i)   -pred_vec2(2)*f1_col(i)];
            
            % update the Hessian
            A_mat = A_mat + Jac'*Jac;
            % update the b vector
            b_vec = b_vec + Jac'*res;
            % update the squared norm of the residual
            res2norm = res2norm +res'*res;
        end
       
        % compute the update:
        correction  = (A_mat+lambda*diag(diag(A_mat)))\b_vec;
        H_vec  = H_vec + correction;
        
        %% check whether this correction reduces the norm of the residual
        H_est = [H_vec(1) H_vec(2) H_vec(3);
            H_vec(4) H_vec(5) H_vec(6);
            H_vec(7) H_vec(8)      1];
        
        % we recompute the squared norm of the residual
        res2norm_new=0;
        for i = 1:length(f1_row)
            % compute the residual
            pred_vec3 = H_est*[Im1_feature_coordinates(i,:)';1];
            % this is the predicted coordinate vector in Image 2:
            pred_vec2 = pred_vec3(1:2)/pred_vec3(3);
            % the residual:
            res = Im2_feature_coordinates(i,:)' - pred_vec2;
            
            res2norm_new = res2norm_new +res'*res;
        end
        
        if res2norm_new<(1+1e-6)*res2norm % use this here instead of res2norm_new<res2norm, to allow for small numerical errors around the minimum, and still reduce lambda
            % we're moving in the right direction, reduce lambda
            lambda = lambda/10;
        else
            % the residual norm increased... we reject the solution and
            % increase lambda
            H_vec = H_vec-correction;
            lambda = lambda*10;
        end
        
        if norm(correction)<1e-5
            %we're done
            break
        end
        
    end
  
    % the final estimate:
    H_est = [H_vec(1) H_vec(2) H_vec(3);
        H_vec(4) H_vec(5) H_vec(6);
        H_vec(7) H_vec(8)      1];
end


