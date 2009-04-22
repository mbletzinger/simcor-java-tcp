classdef proposeExecute < handle
    properties
        factory = {};
        link = {};
        targets = cell(2,1);
        readings = cell(2,1);
        stepExecuteState = stateEnum({...
            'Send Target LBCB1',...
            'Send Target LBCB2',...
            'Send Execute',...
            'Get Control Point LBCB1',...
            'Get Control Point LBCB2',...
            'Get Control Point External Transducers',...
            });
   end
    methods
        function me = stepExecute(factory,linkState)
            me.factory = factory;
            me.link = linkState;
        end
        function status = setTarget(me,lbcb1,lbcb2)
            msg = me.factory.createCommand('propose',targetL1.createMsg(),'LBCB1',1);
            status = sender.send(msg.msg);
        end
            if(status.isState('NONE') == false)
                return;
            end
            msg = me.factory.createCommand('propose',targetL2.createMsg(),'LBCB2',1);
            status = sender.send(msg.msg);
            if(status.isState('NONE') == false)
                return;
            end
            msg = me.factory.createCommand('execute','',0,1);
            status = sender.send(msg.msg);
            if(status.isState('NONE') == false)
                return;
            end
            msg = me.factory.createCommand('get-control-point','dummy','LBCB1',0);
            status = sender.send(msg.msg);
            if(status.isState('NONE') == false)
                return;
            end
           me.lbcb1ControlPoint.parse(sender.response.getContent());
            msg = me.factory.createCommand('get-control-point','dummy','LBCB2',0);
            status = sender.send(msg.msg);
            if(status.isState('NONE') == false)
                return;
            end
           me.lbcb2ControlPoint.parse(sender.response.getContent());
            msg = me.factory.createCommand('get-control-point','dummy','ExternalSensors',0);
            status = sender.send(msg.msg);
            if(status.isState('NONE') == false)
                return;
            end
           values = parseExternalTransducersMsg(me.exTrans.names,sender.response.getContent());
           me.extTransControlPoint.update(values);
           lengths = me.lbcb1EdState.geometry.sensorValuesSubset(me.extTrans.currentLengths);
           me.lbcb1ControlPoint.ed.disp = ExtTrans2Cartesian(me.lbcb1EdState,me.extTransParams,lengths);

           lengths = me.lbcb2EdState.geometry.sensorValuesSubset(me.extTrans.currentLengths);
           me.lbcb2ControlPoint.ed.disp = ExtTrans2Cartesian(me.lbcb2EdState,me.extTransParams,lengths);
        end
    end
end