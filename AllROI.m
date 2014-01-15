function roidata=AllROI(im)
version = '0.1.3';
timestamp = datestr(now,TimestampFormat);

cbparams=getappdata(0,'cbparams');

[nr,nc,~] = size(im);

roidata = struct;
roidata.cbdetectrois_version = version;
roidata.cbdetectrois_timestamp = timestamp;
roidata.isall=true;
roidata.isnew=true;
roidata.nrois = 1;
roidata.roibbs = [1,nc,1,nr];
roidata.inrois = {true(nr,nc)};
roidata.inrois_all = true(nr,nc);
roidata.idxroi=ones(nr,nc);
roidata.ignore=[];
roidata.rotateby=0;
roidata.scores=[];

cbparams.roidiameter_mm=NaN;
roidata.roidiameter_mm = cbparams.roidiameter_mm;
roidata.params=cbparams;

setappdata(0,'cbparams',cbparams)