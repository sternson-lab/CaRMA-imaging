function str_out = FilesepRep(str_in)
if(filesep == '\')
    str_out = strrep(str_in,'\','\\');
else
    str_out = str_in;
end