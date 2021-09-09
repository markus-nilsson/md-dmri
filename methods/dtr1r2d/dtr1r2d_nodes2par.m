function [n,par,perp,theta,phi,r1,r2] = dtr1r2d_nodes2par(dtr1r2d_nodes)

if ~isempty(dtr1r2d_nodes)
    n = dtr1r2d_nodes(1);
    if n > 0
        m = numel(dtr1r2d_nodes(2:end))/n;
        dtr1r2d_nodes_array = reshape(dtr1r2d_nodes(2:end),[m n]);
        par = dtr1r2d_nodes_array(1,:)';
        perp = dtr1r2d_nodes_array(2,:)';
        theta = dtr1r2d_nodes_array(3,:)';
        phi = dtr1r2d_nodes_array(4,:)';
        r1 = dtr1r2d_nodes_array(5,:)';
        r2 = dtr1r2d_nodes_array(6,:)';
    else
        n = 0;
        par = [];
        perp = [];
        theta = [];
        phi = [];
        r1 = [];        
        r2 = [];        
    end
else
    n = 0;
    par = [];
    perp = [];
    theta = [];
    phi = [];
    r1 = [];
    r2 = [];
end
