function dispmsg(str)
% =====================================================================================================================
% Private function to display string message
%
% Written by    7/21/2006 2:20AM OSK
% Last updated  7/21/2006 2:43AM OSK
% =====================================================================================================================

msgbegin = 'MDL_AUX Msg. --------------------------------------------------------------------';
%msgend  = '--------------------------------------------------------------------------------';
msgend   = '';
disp(sprintf('%s\n%s\n%s',msgbegin,str,msgend));