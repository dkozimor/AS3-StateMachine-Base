package org.osflash.statemachine.errors {

public class ErrorCodes {

    public static const NULL_FSM_DATA_ERROR:int = 0;
    public static const DUPLICATE_STATES_DECLARED:int = 1;
    public static const DUPLICATE_TRANSITION_DECLARED:int = 2;
    public static const INITIAL_STATE_ATTRIBUTE_NOT_DECLARED:int = 3;
    public static const INITIAL_STATE_NOT_DECLARED:int = 4;
    public static const STATE_NAME_ATTRIBUTE_NOT_DECLARED:int = 5;
    public static const TRANSITION_NAME_ATTRIBUTE_NOT_DECLARED:int = 6;
    public static const TRANSITION_TARGET_ATTRIBUTE_NOT_DECLARED:int = 7;

    public static const NO_INITIAL_STATE_DECLARED:int = 8;
    public static const TARGET_DECLARATION_MISMATCH:int = 9;
    public static const TRANSITION_NOT_DECLARED_IN_STATE:int = 10;
    public static const STATE_REQUESTED_IS_NOT_REGISTERED:int = 11;

    public static const NULL_CANCELLATION_REASON:int = 12;
    public static const INVALID_TRANSITION:int = 13;
    public static const INVALID_CANCEL:int = 14;
    public static const NO_PHASES_HAVE_BEEN_PUSHED_TO_STATE_TRANSITION:int = 15;
    public static const TRANSITION_UNDEFINED_IN_CURRENT_STATE:int = 16;

    public static const NON_UNIQUE_IDENTIFIER:int = 17;

    public static var errorsBindings:Vector.<Binding>;

    public static function getError( code:int ):BaseStateError {
        if ( errorsBindings == null )createBindings();
        return errorsBindings[code].getError();
    }

    public static function getErrorMessage( code:int ):String {
        if ( errorsBindings == null )createBindings();
        return errorsBindings[code].getMessage();
    }

    private static function createBindings():void {

        errorsBindings = new <Binding>[
            new Binding( StateDecodingError, "No FSM data has been defined, or the value passed is  null" ),
            new Binding( StateDecodingError, "A state with the name [${state}] has already been declared" ),
            new Binding( StateDecodingError, "A transition with the name [${transition}] has already been declared" ),
            new Binding( StateDecodingError, "The initial state attribute has not been declared" ),
            new Binding( StateDecodingError, "The initial state attribute refers to a state that is not declared" ),
            new Binding( StateDecodingError, "The name attribute for ${quantity} state element(s) have not been declared" ),
            new Binding( StateDecodingError, "The name attribute for ${quantity} transition element(s) have not been declared" ),
            new Binding( StateDecodingError, "The target attribute for ${quantity} transition element(s) have not been declared" ),

            new Binding( StateModelError, "No initial state declared" ),
            new Binding( StateModelError, "the target state [${target}] does not exist for [${transition}] in state [${state}]" ),
            new Binding( StateModelError, "the transition [${transition}] is not declared in state [${state}]" ),
            new Binding( StateModelError, "the state [${state}] is not registered" ),

            new Binding( StateTransitionCancellationError, "A null CancellationReasonUID was passed during [${transition}] in state[${state}]" ),

            new Binding( StateTransitionError, "A transition can not be invoked from the [${phase}] phase" ),
            new Binding( StateTransitionError, "A transition can not be cancelled from the [${phase}] phase" ),
            new Binding( StateTransitionError, "No ITransitionPhase have been pushed to the TransitionPhaseDispatcher" ),
            new Binding( StateTransitionError, "The transition[${transition}] is not defined in the current state [${state}]" ),

            new Binding( UIDError, "This uid [${identifier}] is not unique" )
        ];

    }


}
}

import org.osflash.statemachine.errors.BaseStateError;

internal class Binding {

    private var _msg:String;
    private var _errorClass:Class;

    public function Binding( errorClass:Class, msg:String ) {
        _errorClass = errorClass;
        _msg = msg;
    }

    public function getMessage():String {
        return _msg;
    }

    public function getError():BaseStateError {
        return new _errorClass( _msg );
    }
}