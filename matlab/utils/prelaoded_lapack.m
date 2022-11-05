function tf = preloaded_lapack
% Check whether LAPACK has been preloaded

tf = ismac || contains(getenv('LD_PRELOAD'), 'liblapack.so');

end
