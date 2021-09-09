function [n,par,perp,theta,phi] = dtd_nodes2par(dtd_nodes)

if ~isempty(dtd_nodes)
    n = dtd_nodes(1);    
    if n > 0
        m = numel(dtd_nodes(2:end))/n;
        dtd_nodes_array = reshape(dtd_nodes(2:end),[m n]);
        par = dtd_nodes_array(1,:)';
        perp = dtd_nodes_array(2,:)';
        theta = dtd_nodes_array(3,:)';
        phi = dtd_nodes_array(4,:)';
    else
        par = [];
        perp = [];
        theta = [];
        phi = [];        
    end
else
    n = 0;
    par = [];
    perp = [];
    theta = [];
    phi = [];
end
