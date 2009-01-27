% script for Plugin_Initialize.m

% cd('..');
% cd('Output Files');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FileName='NetwkLog_LBCB.txt';
if exist(FileName)~=0
	delete ('NetwkLog_LBCB.txt');
end
FileName='NetwkLog_SimCor.txt';
if exist(FileName)~=0
	delete ('NetwkLog_SimCor.txt');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RawData
fname ='Raw.txt';
DisComp={'Model_Dx(in)','Model_Dy(in)','Model_Dz(in)','Model_Rx(rad)','Model_Ry(rad)','Model_Rz(rad)'};
ForComp={'Model_Fx(kip)','Model_Fy(kip)','Model_Fz(kip)','Model_Mx(kip-in)','Model_My(kip-in)','Model_Mz(kip-in)'};
LBCBComp={'LBCB_Dx(in)','LBCB_Dy(in)','LBCB_Dz(in)','LBCB_Rx(rad)','LBCB_Ry(rad)','LBCB_Rz(rad)'};
fid = fopen(fname,'w'); % If file exist, this will rewrite the file.
fprintf (fid,'%%Step ME_LC_1X ME_LC_1Y ME_LC_2X ME_LC_2Y ME_Lt_SP ME_Rt_SP ');
for i=1:6
	fprintf (fid,'%-12s	',ForComp{i});
end
for i=1:6
	fprintf (fid,'%-12s	',DisComp{i});
end
for i=1:6
	fprintf (fid,'%-12s	',LBCBComp{i});
end
fprintf(fid,'\r\n');
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RunLog
fname ='RunLog.txt';
fid = fopen(fname,'w'); % If file exist, this will rewrite the file.
fprintf (fid,'This file contains data to check the control algorithm');
fprintf(fid,'\r\n');
fprintf(fid,'Step_Number  TGT_DX TGT_DY TGT_FZ TGT_RX TGT_MY TGT_RZ TGTlast_DX TGTlast_DY TGTlast_FZ TGTlast_RX TGTlast_MY TGTlast_RZ Graph_Step_Number ');
fprintf(fid,'M_Meas_DX M_Meas_DY M_Meas_DZ M_Meas_RX M_Meas_RY M_Meas_RZ M_Meas_FX M_Meas_FY M_Meas_FZ M_Meas_MX M_Meas_MY M_Meas_MZ ');
fprintf(fid,'Command_DX Command_DY Command_FZ Command_RX Command_MY Command_RZ CrntState_DX CrntState_DY CrntState_FZ CrntState_RX CrntState_MY CrntState_RZ ');
fprintf(fid,'Adjusted_Command_DX Adjusted_Command_DY Adjusted_Command_DZ Adjusted_Command_RX Adjusted_Command_RY Adjusted_Command_RZ ');
fprintf(fid,'LBCB_Command_DX LBCB_Command_DY LBCB_Command_DZ LBCB_Command_RX LBCB_Command_RY LBCB_Command_RZ ');
fprintf(fid,'\r\n');
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fname ='TriggerLog.txt';
fid = fopen(fname,'w'); % If file exist, this will rewrite the file.
fprintf(fid,'Step_Number Substep Graph_Step PicCount SbStpPerPic DAQ_Trigger? CAM_Trigger?');
fprintf(fid,'\r\n');
fclose(fid);


% cd('..');
% cd('Support Files');

