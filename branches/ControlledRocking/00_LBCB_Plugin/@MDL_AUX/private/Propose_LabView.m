function TransID = Propose_LabView1(obj)
% =====================================================================================================================
% Propose target displacement to remote site using LabView protocol
%
%   obj     : A MDL_RF object representing remote sites
%
% Written by    7/21/2006 2:20AM OSK
% Last updated  7/21/2006 8:40PM OSK
% =====================================================================================================================

TransID  = sprintf('trans%4d%02d%02d%02d%02d%4.2f',clock);       % Create transaction ID
obj.CPname = 'MDL-AUX';
send_str = sprintf('propose\t%s\t%s\t',TransID,obj.CPname);
tmpstr = '';
for i=1:length(obj.Command)
	tmpstr = [tmpstr sprintf('%s\t',num2str(obj.Command{i}))];
end
send_str = [send_str tmpstr(1:end-1)];
Sendvar_LabView(obj,send_str);                                   % Send proposing command
%Getvar_LabView(obj,obj.CMD.ACKNOWLEDGE);                         % Receive acknowledgement