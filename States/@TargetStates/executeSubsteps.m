function executeSubsteps(me)
if me.stpEx.isDone() == false
    return;
end
if me.stpEx.hasErrors()
%    me.ocOm.connectionError();
    me.statusErrored();
    me.currentAction.setState('DONE');
    return;
end
me.dat.collectTargetResponse();
me.gui.ddisp.update();
me.currentAction.setState('SEND TARGET RESPONSE');
if me.targetSource.isState('UI SIMCOR')
    me.tgtRsp.respond();
end
end
