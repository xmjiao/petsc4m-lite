function b = contains(s, pat)
%CONTAINS True if pattern is found in text.
%   TF = CONTAINS(S,PATTERN) returns true if CONTAINS finds PATTERN in any
%   element of string array S. TF is the same size as S.
%
%   S can be a string array, a character vector, or a cell array of
%   character vectors. So can PATTERN. PATTERN and S need not be the same
%   size. If PATTERN is nonscalar, CONTAINS returns true if it finds any
%   element of PATTERN in S.

b = ~isempty(strfind(s, pat));
