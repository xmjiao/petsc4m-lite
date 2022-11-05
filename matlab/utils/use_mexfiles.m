function tf = use_mexfiles
% Check whether it is safe to use MEX files

tf = exist('OCTAVE_VERSION', 'builtin') || \
    ~usejava('desktop') && (ismac || contains(getenv('LD_PRELOAD'), 'liblapack.so'));

end
