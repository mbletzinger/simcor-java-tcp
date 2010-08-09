classdef OneDofStepPlot < handle
    properties
        plot = {};
        cmdData = [];
        corData = [];
        tgtData = [];
        rspData = [];
        isLbcb1 = 1;
        haveData = 0;
        dof
        lbl = { 'Dx','Dy', 'Dz', 'Rx','Ry', 'Rz','cmd','Fy', 'Fz', 'Mx','My', 'Mz' }; 
        dat
    end
    methods
        function me = OneDofStepPlot(isLbcb1,dat, dof)
            me.dof = dof;
            me.dat = dat;
            me.plot = TargetPlot(sprintf('LBCB %d  %s Steps',1 + (isLbcb1 == false),me.lbl{dof}),...
                {'command','correct target', 'target','response'});
            me.isLbcb1 = isLbcb1;
            me.plot.figNum = 1 + (isLbcb1 == false);
        end
        function displayMe(me)
                me.plot.displayMe(me.lbl{me.dof});
        end
        function undisplayMe(me)
                me.plot.undisplayMe();
        end
        function update(me)
            stepNum = me.dat.curStepData.stepNum;
            if stepNum.step == 0
                return; %initial position no commands
            end
            cpsidx = 2;
            if me.isLbcb1
                cpsidx = 1;
            end
            cmdS = me.dat.curStepData;
            corS = me.dat.correctionTarget;
            tgtS = me.dat.curTarget;

            d = me.dof;
            isForce = false;
            
            if d > 6
                d = d - 6;
                isForce = true;
            end
            
            if isForce
                cmd = cmdS.lbcbCps{cpsidx}.command.force(d);
                rsp = cmdS.lbcbCps{cpsidx}.response.force(d);
                cor = corS.lbcbCps{cpsidx}.command.force(d);
                tgt = tgtS.lbcbCps{cpsidx}.command.force(d);
            else
                cmd = cmdS.lbcbCps{cpsidx}.command.disp(d);
                rsp = cmdS.lbcbCps{cpsidx}.response.disp(d);
                cor = corS.lbcbCps{cpsidx}.command.disp(d);
                tgt = tgtS.lbcbCps{cpsidx}.command.disp(d);
            end
            
            if(me.haveData)
                me.cmdData = cat(1, me.cmdData,cmd);
                me.corData = cat(1, me.corData,cor);
                me.tgtData = cat(1, me.tgtData,tgt);
                me.rspData = cat(1, me.rspData,rsp);
            else
                me.haveData = 1;
                me.cmdData = cmd;
                me.corData = cor;
                me.tgtData = tgt;
                me.rspData = rsp;
            end
            me.plot.update(me.cmdData,1);
            me.plot.update(me.corData,2);
            me.plot.update(me.tgtData,3);
            me.plot.update(me.rspData,4);
        end
    end
end
