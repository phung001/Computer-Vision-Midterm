function [highD, highTheta, highInLine] = ransac_theta_d( coord, m, S)

    %High scores for outputting later
    highScore = 0;
    highD = 0;
    highTheta = 0;
    
    for itter=1:S
        %Get random points
        [randPoints, index] = datasample(coord,m,'Replace',false);
        x = randPoints(:,1);
        y = randPoints(:,2);
        
        %Get theta and d to compare later
        theta = atan((x(1)-x(2))/(y(2)-y(1)));
        d = (x(1)*cos(theta)) + (y(1)*sin(theta));
        
        inLine = zeros(1, length(coord));
        %Go through all coordinates
        for i = 1:length(coord)
            %Skip the randomly picked points
            if i == index(1) || i == index(2)
                continue
            end
            
            %Calculate d and find the difference between them
            isIn = abs(d - ((coord(i,1)*cos(theta)) + (coord(i,2)*sin(theta)))); 
            %If difference is small, count as inline
            if isIn < 2
                inLine(i) = 1;
            end
            
        end
        
        %Check the score and replace if higher than the high score
        if(sum(inLine) > highScore)
            highScore = sum(inLine);
            highInLine = inLine;
            highD = d;
            highTheta = theta;
        end
    
    end
    
end