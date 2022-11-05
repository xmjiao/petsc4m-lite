function varargout = crs_createFromSparse(sp, m)
%crs_createFromSparse  Convert built-in sparse format to CRS
%
%    A = crs_createFromAIJ(sp [, nrows]);
%    [row_ptr, col_ind, val] = crs_createFromAIJ(sp[, nrows]);
%
% A is a struct with fields row_ptr, col_ind, val, nrows, and ncols.
%
% See also crs_matrix, crs_createFromAIJ

[is, js, vs] = find(sp);

if nargin > 1
    nrows = int32(m);
else
    nrows = int32(size(sp, 1));
end

% Note: In Octave, find returns row vectors instead of column vectors
A = crs_createFromAIJ(int32(is(:)), int32(js(:)), vs(:), ...
    nrows, int32(size(sp, 2)));

if nargout <= 1
    varargout{1} = A;
else
    varargout{1} = A.row_ptr;
    varargout{2} = A.col_ind;
    varargout{3} = A.val;
end
