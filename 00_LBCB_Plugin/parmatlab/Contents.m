% Author:  Lucio Andrade
% Name:    parmatlab   v1.7 Beta 10/01
% Summary: This toolbox distributes processes over matlab workers available over the
%          intranet/internet. This toolbox implements a SPMD parallel architecture 
%          model.
%
% NEW IN v1.7: ---> Real CROSS-PLATAFORMS, CROSS-OS and CROSS-Matlab versions !, 
%                   tested with Solarisv, linux, win98, winNT, win200, matlab 5.3 & matlab 6
%              ---> Error handling capabilities, you can debug the workspace of a worker if 
%                   it had an error and without stopping the other workers or the majordomo
%              ---> Improved demo which explains how to use basic functions to implement also
%                   a MPMD parallel architecture model  
%              ---> Capability of re-use data which was already transmitted to the workers 
%                   worspace
%   
% New in v1.05: --> Better explained demo files to introduce faster the user to the tool
%
% Important note: I have received lots of e-mail with ideas to improve this toolbox, I'll
%                 appreciate if you send me an e-mail explaining your application, to plan
%                 future improvments.
%    
%   Description:
%       This toolbox distributes processes over matlab workers available over the
%       intranet/internet. These workers must be running a matlab daemon to be accessed. 
%
%       This tool is very useful for corsely granular parallelization problems and in the
%       precesence of a distributed and heterogeneus computer enviroment. You can operate 
%       the toolbox in twomodes:
% 
%       [MPMD mode] Multiple program-Multiple Data parallel model; the user has the control 
%       to send different matlab tasks to remote machines simultaneusly and retraive results
%       later.  
%
%       [SPMD mode] Single program-Multiple Data parallel model; parallelization and managment 
%       of remote workers is done automatically. Input data must be regularly ordered in
%       matlab hyperblocks. 
%
%       1) You DO NOT need a common file system, all communications between tasks (tx of
%       commands/data) are througth tcpip connections. 
%       2) The parallel virtual machine does not need to know which workers are available,
%       it'll will be listening until workers report ready. New workers can be added even if 
%       the process has been started. 
%       3) Parallelization can be done over different dimensions (up to 5) at the same time
%       and using contiguous, overlapping or constant hyper-blocks. Indexes can also vary for
%       different input variables, the only restriction is that the total number of parallel
%       elements should be the same. 
%       4) Tcpip TOOLBOX 1.2.3 by Peter Rydesater is used for communications, but some 
%       improvments have been done to avoid file writing to serialize data before tx. 
%       Instead, serialization of data is achieved with a low-level MEX file. Serial data to 
%       Matlab variables is also done with a MEX file. The latest version of the Tcpip toolbox 
%       is not available in the Mathworks site, I included  version 1.2.3 in this 
%       distribution, but you should visit http://petrydpc.itm.mh.se/tools and check
%       if there is a newer version available.
%
%       Note 1: Please refer to the demos to understand how the tool is used 
%       Note 2: Timeout utilities  will be added in a future version. 
%       Note 3: Capability to manipulate data in remote workers will be added in a future
%               version. But it is not clear for me yet if it is really needed.
%
%
%       This program is free software; you can redistribute it and/or modify it under the
%       terms of the GNU General Public License as published by the Free Software Foundation;
%       either version 2 of the License, or (at your option) any later version. 
%
%       This program is distributed in the hope that it will be useful, but WITHOUT ANY 
%       WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
%       PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
%=======================================================================
%  I'll be very glad if you let me know that this toolbox is useful for
%  you, please let me know any comment (landrade@ece.neu.edu). 
%
%  Postcards or voluntary monetary contributions to: 
%      78 S. Huntington Av. 12
%      Boston MA,02130 USA
%=======================================================================
%
%
%  Main implementation:             
%  ===================
%
%  Lucio Andrade               
%  CETYS University, Mexico                    
%  e-mail:lucio@cetys.mx 
%  
%
%  Contents         This help file.
%
%    THESE ARE THE FILES THAT A NORMAL USER SHOULD USE
%
%  initmajordomo.m  Initializes communication ports
%  closemajordomo.m Closes comm ports and realeses workers
%  parallelize.m    Parallel implementation of a function
%  worker.m         Deamon for matlab workers
%  sendtask.m       Send a function (with variables) to a matlab worker
%  receivetask.m    Receive results of a function finished by a matlab worker 
%  distm_demo_1.m   Basic demo
%  distm_demo_2.m   Demo with functions from the Image toolbox
%
%    SOME UTILITY FILES THAT THE USER MIGHT USE
%
%  sendvar.m        Send a var with tcpip (No file flushing for doubles and chars)
%  getvar.m         Get a var that was sent with sendvar.m
%  getmyip.m        Obtains the IP address of local machine
%
%    SOME OTHER TOOLS NEEDED BY THE TOOLBOX
%
%  mvar2str.m       Converts a matlab var to a string
%  str2mvar.m       Reverses mvar2str.m
%  msub2ind.m       Modyfied version of sub2ind.m, uses a vector of subindexes instead
%  mind2sub.m       Modyfied version of ind2sub.m, uses a vector of subindexes instead
%  serial2double.c  C-Source for Mex file for data conversion tool
%  double2serial.c  C-Source for Mex file for data conversion tool
%
%    ADDITIONAL FILES FROM THE TCPIP TOOLBOX by Peter Rydes�ter (not all used and some modifyed)
%
%  tcpip_close      Closes an open tcpip connection.
%  tcpip_open       Opens a new tcpip connection.
%  tcpip_read       Reads an array of bytes from pipe.
%  tcpip_readln     Reads a line of chars (bytes) if their is a complete.
%  tcpip_sendfile   Sends a file throw connection to receiving "tcpip_getfile"
%  tcpip_getfile    Receives a data from sending "tcpip_sendfile" and saves to file.
%  tcpip_sendvar    Send matlab variable.
%  tcpip_getvar     Get matlab variable.
%  tcpip_servopen   OLD! Only for compatibility. Blocking wait for connetion!
%  tcpip_servsocket Creates a socket binded to a port, waiting for connections!
%  tcpip_listen     Checks/Gets connection connected to tcpip_servsocket
%  tcpip_status     Returns status of open connection. Detects broken connections.
%  tcpip_viewbuff   Returns whats in receiving buffer but will not empty it.
%  tcpip_write      Sends an array of bytes to connection.
%  tcpipmex.c       C-source for the mex file that is core of this toolbox.
