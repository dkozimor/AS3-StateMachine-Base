package org.osflash.statemachine.decoding.validators {

import org.osflash.statemachine.decoding.IDataValidator;
import org.osflash.statemachine.errors.ErrorCodes;
import org.osflash.statemachine.errors.ErrorMap;

public class StateHasNoIncomingTransitions implements IDataValidator {

    private var _data:XML;

    public function validate():Object {
        const states:XMLList = _data.state.@name;
        for each ( var state:XML in states ) {
            const duplicateList:int = retrieveNumberOfTransitionElementsWithTarget( state );
            if ( duplicateList == 0 && _data.@initial.toString() != state.toString())
                throw new ErrorMap().getError( ErrorCodes.STATE_HAS_NO_INCOMING_TRANSITION ).injectMsgWith( state, "state" );
        }
        return _data;
    }

    private function retrieveNumberOfTransitionElementsWithTarget( id:String ):int {
        return _data..transition.( hasOwnProperty( "@target" ) && @target == id ).length();
    }

    public function set data( value:Object ):void {
        _data = XML( value );
    }
}
}
