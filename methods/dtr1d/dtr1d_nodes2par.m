function [n,par,perp,theta,phi,r1] = dtr1d_nodes2par(dtr1d_nodes)

if ~isempty(dtr1d_nodes)
    n = dtr1d_nodes(1);
    if n > 0
        m = numel(dtr1d_nodes(2:end))/n;
        dtr1d_nodes_array = reshape(dtr1d_nodes(2:end),[m n]);
        par = dtr1d_nodes_array(1,:)';
        perp = dtr1d_nodes_array(2,:)';
        theta = dtr1d_nodes_array(3,:)';
        phi = dtr1d_nodes_array(4,:)';
        r1 = dtr1d_nodes_array(5,:)';
    else
        n = 0;
        par = [];
        perp = [];
        theta = [];
        phi = [];
        r1 = [];        
    end
else
    n = 0;
    par = [];
    perp = [];
    theta = [];
    phi = [];
    r1 = [];
end
