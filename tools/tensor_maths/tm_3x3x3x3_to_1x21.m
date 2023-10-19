function o = tm_3x3x3x3_to_1x21(t)
% function t = tm_3x3x3x3_to_1x21(t)
% 
% Convert fourth-order tensor in 3x3x3x3 format to 1x21 format

x = 1;
y = 2;
z = 3;

o = zeros(1,21);

o(1) = t(x,x,x,x); % xxxx = t(1); % all same
o(2) = t(y,y,y,y);
o(3) = t(z,z,z,z); 

c = sqrt(2);
o(4) = (t(x,x,y,y) + t(y,y,x,x)) / c; % xxyy = t(4) / c; 
o(5) = (t(x,x,z,z) + t(z,z,x,x)) / c;
o(6) = (t(y,y,z,z) + t(z,z,y,y)) / c;

c = sqrt(4);
o(7) = (t(x,x,y,z) + t(x,x,z,y) + t(y,z,x,x) + t(z,y,x,x)) / c; % xxyz = t(7) / c; 
o(8) = (t(y,y,x,z) + t(y,y,z,x) + t(x,z,y,y) + t(z,x,y,y)) / c;
o(9) = (t(z,z,x,y) + t(z,z,y,x) + t(x,y,z,z) + t(y,x,z,z)) / c;

c = sqrt(4);
o(10) = (t(x,x,x,y) + t(x,x,y,x) + t(x,y,x,x) + t(y,x,x,x)) / c; % xxxy = t(10) / c;
o(11) = (t(x,x,x,z) + t(x,x,z,x) + t(x,z,x,x) + t(z,x,x,x)) / c;
o(12) = (t(y,y,y,x) + t(y,y,x,y) + t(y,x,y,y) + t(x,y,y,y)) / c;
o(13) = (t(y,y,y,z) + t(y,y,z,y) + t(y,z,y,y) + t(z,y,y,y)) / c;
o(14) = (t(z,z,z,x) + t(z,z,x,z) + t(z,x,z,z) + t(x,z,z,z)) / c;
o(15) = (t(z,z,z,y) + t(z,z,y,z) + t(z,y,z,z) + t(y,z,z,z)) / c;

c = sqrt(4);
o(16) = (t(x,y,x,y) + t(x,y,y,x) + t(y,x,x,y) + t(y,x,y,x)) / c; % xyxy = t(16) / c;
o(17) = (t(x,z,x,z) + t(x,z,z,x) + t(z,x,x,z) + t(z,x,z,x)) / c;
o(18) = (t(y,z,y,z) + t(y,z,z,y) + t(z,y,y,z) + t(z,y,y,z)) / c;

c = sqrt(8);

o(19) = (...
    t(x,y,x,z) + t(x,y,z,x) + t(y,x,x,z) + t(y,x,z,x) + ...
    t(x,z,x,y) + t(z,x,y,x) + t(z,x,x,y) + t(z,x,y,x) )  / c; % xyxz = t(19) / c;

o(20) = (...
    t(x,y,y,z) + t(x,y,z,y) + t(y,x,y,z) + t(y,x,z,y) + ...
    t(y,z,x,y) + t(y,z,y,x) + t(z,y,x,y) + t(z,y,y,x) )  / c;

o(21) = (...
    t(x,z,y,z) + t(x,z,z,y) + t(y,z,x,z) + t(z,y,z,x) + ...
    t(y,z,x,z) + t(y,z,z,x) + t(z,y,x,z) + t(z,y,z,x) )  / c;





