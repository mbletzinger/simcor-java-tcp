classdef TargetStates < SimStates
    properties
        currentTargetAction = StateEnum({...
            'WAIT FOR TARGET',...
            'GET TARGET',...
            'TRANSFORM TARGET',...
            'SPLIT TARGET',...
            'EXECUTE SUBSTEPS',...
            'EXECUTE TARGET',...
            'SEND TARGET RESPONSE',...
            'DONE'
            });
        state = StateEnum({...
            'BUSY',...
            'COMPLETED',...
            'ERRORS EXIST'...
            });
        targetSource = StateEnum({...
            'INPUT FILE',...
            'UI SIMCOR',...
            });
        stpEx = [];
        inF = [];
    end
    methods
        function start(me)
            me.currentAction.setState('WAIT FOR TARGET');
        end
        function done = isDone(me)
            switch me.currentAction.getState()
                case 'WAIT FOR TARGET'
                case 'GET TARGET'
                case 'CONVERT TARGET'
                case 'SPLIT TARGET'
                case 'EXECUTE SUBSTEPS'
                case 'EXECUTE TARGET'
                case 'SEND TARGET RESPONSE'
                case 'DONE'
                otherwise
                    me.log.error(dbstack,sprintf('%s action not recognized',action));
            end
        end
    end
end