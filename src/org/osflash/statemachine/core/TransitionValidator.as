package org.osflash.statemachine.core {

public interface TransitionValidator {

    function validate( model:IFSMProperties ):Boolean
}
}