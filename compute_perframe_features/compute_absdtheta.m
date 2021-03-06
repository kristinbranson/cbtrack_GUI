% absolute change in body orientation
function [data,units] = compute_absdtheta(trx,n)

flies = trx.exp2flies{n};
nflies = numel(flies);
data = cell(1,nflies);
for i = 1:nflies,
  fly = flies(i);
  data{i} = abs(trx(fly).dtheta);
end
units = parseunits('rad/s');

