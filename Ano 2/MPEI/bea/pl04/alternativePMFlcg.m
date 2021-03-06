function y = alternativePMFlcg(XI, pX, N)

    % generate numbers between 0 and 1
    %randNums = rand(1,N);
    
    % map it to the PMF
    xCDF = cumsum(pX);
    
    % choose multiplication factor accordingly
    y = zeros(1, length(N));
    
    for i=1:N %length(randNums)
        aux = find(xCDF > rand());%randNums(i));
        y(i) = XI(aux(1));
    end
end