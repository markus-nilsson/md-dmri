function t = tm_1x21_to_3x3x3x3(t)
% function t = tm_1x21_to_3x3x3x3(t)
% 
% Convert fourth-order tensor in 1x21 format to 3x3x3x3 format

xxxx = t(1); % all same
yyyy = t(2);
zzzz = t(3);

c = sqrt(2);
xxyy = t(4) / c; 
xxzz = t(5) / c;
yyzz = t(6) / c;

c = sqrt(4);
xxyz = t(7) / c; 
yyxz = t(8) / c;
zzxy = t(9) / c;

c = sqrt(4);
xxxy = t(10) / c;
xxxz = t(11) / c;
yyxy = t(12) / c;
yyyz = t(13) / c;
zzxz = t(14) / c;
zzyz = t(15) / c;

c = sqrt(4);
xyxy = t(16) / c;
xzxz = t(17) / c;
yzyz = t(18) / c;

c = sqrt(8);
xyxz = t(19) / c;
xyyz = t(20) / c;
xzyz = t(21) / c;

t = zeros(3,3,3,3);

% 9
t(1,1,1,1) = xxxx;
t(1,1,1,2) = xxxy;
t(1,1,1,3) = xxxz;

t(1,1,2,1) = xxxy;
t(1,1,2,2) = xxyy;
t(1,1,2,3) = xxyz;

t(1,1,3,1) = xxxz;
t(1,1,3,2) = xxyz;
t(1,1,3,3) = xxzz;

% 9+9
t(1,2,1,1) = xxxy;
t(1,2,1,2) = xyxy;
t(1,2,1,3) = xyxz;

t(1,2,2,1) = xyxy;
t(1,2,2,2) = yyxy;
t(1,2,2,3) = xyyz;

t(1,2,3,1) = xyxz;
t(1,2,3,2) = xyyz;
t(1,2,3,3) = zzxy;

% 27
t(1,3,1,1) = xxxz;
t(1,3,1,2) = xyxz;
t(1,3,1,3) = xzxz;

t(1,3,2,1) = xyxz;
t(1,3,2,2) = yyxz;
t(1,3,2,3) = xzyz;

t(1,3,3,1) = xzxz;
t(1,3,3,2) = xzyz;
t(1,3,3,3) = zzxz;

% 36
t(2,1,1,1) = xxxy;
t(2,1,1,2) = xyxy;
t(2,1,1,3) = xyxz;

t(2,1,2,1) = xyxy;
t(2,1,2,2) = yyxy;
t(2,1,2,3) = xyyz;

t(2,1,3,1) = xyxz;
t(2,1,3,2) = xyyz;
t(2,1,3,3) = zzxy;

% 45
t(2,2,1,1) = xxyy;
t(2,2,1,2) = yyxy;
t(2,2,1,3) = yyxz;

t(2,2,2,1) = yyxy;
t(2,2,2,2) = yyyy;
t(2,2,2,3) = yyyz;

t(2,2,3,1) = yyxz;
t(2,2,3,2) = yyyz;
t(2,2,3,3) = yyzz;

% 54
t(2,3,1,1) = xxyz;
t(2,3,1,2) = xyyz;
t(2,3,1,3) = xzyz;

t(2,3,2,1) = xyyz;
t(2,3,2,2) = yyyz;
t(2,3,2,3) = yzyz;

t(2,3,3,1) = xzyz;
t(2,3,3,2) = yzyz;
t(2,3,3,3) = zzyz;

% 63
t(3,1,1,1) = xxxz;
t(3,1,1,2) = xyxz;
t(3,1,1,3) = xzxz;

t(3,1,2,1) = xyxz;
t(3,1,2,2) = yyxz;
t(3,1,2,3) = xzyz;

t(3,1,3,1) = xzxz;
t(3,1,3,2) = xzyz;
t(3,1,3,3) = zzxz;

% 72
t(3,2,1,1) = xxyz;
t(3,2,1,2) = xyyz;
t(3,2,1,3) = xzyz;

t(3,2,2,1) = xyyz;
t(3,2,2,2) = yyyz;
t(3,2,2,3) = yzyz;

t(3,2,3,1) = xzyz;
t(3,2,3,2) = yzyz;
t(3,2,3,3) = zzyz;

% 81
t(3,3,1,1) = xxzz;
t(3,3,1,2) = zzxy;
t(3,3,1,3) = zzxz;

t(3,3,2,1) = zzxy;
t(3,3,2,2) = yyzz;
t(3,3,2,3) = zzyz;

t(3,3,3,1) = zzxz;
t(3,3,3,2) = zzyz;
t(3,3,3,3) = zzzz;



