function t = tm_3x3_to_tpars(t3x3)
% function t = tm_3x3_to_tpars(t3x3)
%
% calculate derived tensor parameters

if (any(isnan(t3x3(:))) || any(isinf(t3x3(:))))
    t3x3 = zeros(3,3);
end

t.t1x6 = tm_3x3_to_1x6(t3x3);


[V,D] = eig(t3x3);
lambdas = diag(D);

t.trace = sum(lambdas);
t.iso   = t.trace/3;

[~,ind] = sort(lambdas,'descend');

t.lambda33    = lambdas(ind(1));                        
t.lambda22    = lambdas(ind(2));                       
t.lambda11    = lambdas(ind(3));  
t.lambda33vec = V(:,ind(1))';
t.lambda22vec = V(:,ind(2))';
t.lambda11vec = V(:,ind(3))';

Dlambdas = abs(lambdas-t.iso);
[~,ind] = sort(Dlambdas,'descend');
t.lambdazz = lambdas(ind(1));
t.lambdaxx = lambdas(ind(2));                        
t.lambdayy = lambdas(ind(3));
t.lambdazzvec = V(:,ind(1))';
t.lambdaxxvec = V(:,ind(2))';
t.lambdayyvec = V(:,ind(3))';

t.vlambda = 1/3*((t.lambda33 - t.iso).^2 + (t.lambda22 - t.iso).^2 + (t.lambda11 - t.iso).^2);
t.cm = t.vlambda./t.iso.^2;
t.cm(isnan(t.cm)) = 0;
t.delta = (t.lambdazz - (t.lambdayy+t.lambdaxx)/2)./(t.trace + eps);
t.eta = 3*(t.lambdayy - t.lambdaxx ) ./ (2*t.trace.*t.delta+eps);
t.l = t.lambda33 - t.lambda22;
t.p = 2*(t.lambda22 - t.lambda11);
t.s = 3*t.lambda11;


t.fa = sqrt(1/2)*sqrt((t.lambda33-t.lambda22).^2+(t.lambda33-t.lambda11).^2+(t.lambda22-t.lambda11).^2)...
                    ./sqrt(t.lambda33.^2+t.lambda22.^2+t.lambda11.^2);
t.fa(isnan(t.fa)) = 0;

t.cl = t.l./t.trace;
t.cl(isnan(t.cl)) = 0;
t.cp = t.p./t.trace;
t.cp(isnan(t.cp)) = 0;
t.cs = t.s./t.trace;
t.cs(isnan(t.cs)) = 0;

