function parval = getparampulsespel(Param, parstr)

pulsespelvars = Param.PlsSPELGlbTxt;
idx = strfind(pulsespelvars, parstr);
temp = strsplit(pulsespelvars(idx:end), ';');
temp2 = strsplit(temp{1}, '=');
parval = str2double(temp2{2});

end

