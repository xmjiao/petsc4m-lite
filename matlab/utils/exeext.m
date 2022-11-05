function exeext_ = exeext
%EXEEXT  Obtains the extension of executable

exeext_ = strrep(mexext, 'mex', 'exe');

end
