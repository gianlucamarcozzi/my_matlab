function [Ahfi1, Ahfi2] = calculatehfitwospins(A, AFrame, rVers)
    
    [Ahfi1, Ahfi2] = deal(zeros(size(A, 1), length(rVers)));
    %% For spin 1
    for ii = 1:size(A, 1)
        % Calculate the hyperfine tensor for the given A values and A frame
        % TODO AFrame(1:3) should become AFrame(ii:3)
        Ahfi1Tensor = rotatematrixeuangles(diag(A(ii, 1:3)), AFrame(1:3));
        % Project along rVers
        Ahfi1(ii, :) = squeeze( ...
            sqrt( sum( (pagemtimes(Ahfi1Tensor, rVers)).^2)));

        %% For spin 2
        % Calculate the hyperfine tensor for the given A values and A frame
        Ahfi2Tensor = rotatematrixeuangles(diag(A(ii, 4:6)), AFrame(4:6));
        % Project along rVers
        Ahfi2(ii, :) = squeeze( ...
            sqrt( sum( (pagemtimes(Ahfi2Tensor, rVers)).^2)));
    end
end