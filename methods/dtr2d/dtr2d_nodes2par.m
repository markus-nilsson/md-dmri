function [n,par,perp,theta,phi,r2] = dtr2d_nodes2par(dtr2d_nodes)

if ~isempty(dtr2d_nodes)
    n = dtr2d_nodes(1);
    if n > 0
        m = numel(dtr2d_nodes(2:end))/n;
        dtr2d_nodes_array = reshape(dtr2d_nodes(2:end),[m n]);
        par = dtr2d_nodes_array(1,:)';
        perp = dtr2d_nodes_array(2,:)';
        theta = dtr2d_nodes_array(3,:)';
        phi = dtr2d_nodes_array(4,:)';
        r2 = dtr2d_nodes_array(5,:)';
    else
        n = 0;
        par = [];
        perp = [];
        theta = [];
        phi = [];
        r2 = [];        
    end
else
    n = 0;
    par = [];
    perp = [];
    theta = [];
    phi = [];
    r2 = [];
end
