function expnams = mdm_bruker_dir2expnams(data_path)% function expnams = mdm_bruker_dir2expnams(data_path)% DirList = dir(data_path);[DirSize1,DirSize2] = size(DirList);expnams = {};DirCount = 0;for ndir = 1:DirSize1    expnamstest = getfield(DirList,{ndir,1},'name');    if strcmp(expnamstest(1),'.') == 0        if getfield(DirList,{ndir,1},'isdir')            DirCount = DirCount+1;            expnams{DirCount} = expnamstest;        end    endend