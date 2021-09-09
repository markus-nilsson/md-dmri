function t_ex = ning18_1d_xps2tex(xps) 

ds              = xps.mde_delta1;
db              = xps.td + (1/3) * xps.mde_delta1; 

t_ex            = 1/3 * ...
    (db - (1/3) * ds).^(-2) .* ...
    (db.^3 - db.^2 .* ds + (2/3) * ds.^2 .* db - (4/21) * ds.^3);

end