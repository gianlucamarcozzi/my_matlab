function energ = myeigenenergies(w0, J, d, Omega)
    
    signJmd(1, 1, :) = [-1, 1, -1, 1];  % (1, 1, 4)
    signOmega(1, 1, :) = [-1, -1, 1, 1];  % (1, 1, 4)
    
    energ = w0 + pagemtimes(signJmd, J - d) + pagemtimes(signOmega, Omega);
end

