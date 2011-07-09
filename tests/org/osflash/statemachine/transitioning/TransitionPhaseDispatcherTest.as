package org.osflash.statemachine.transitioning {

import org.hamcrest.assertThat;
import org.hamcrest.core.allOf;
import org.hamcrest.core.throws;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.hasPropertyWithValue;
import org.hamcrest.object.instanceOf;
import org.osflash.statemachine.errors.ErrorCodes;
import org.osflash.statemachine.errors.StateTransitionError;
import org.osflash.statemachine.errors.getErrorMessage;
import org.osflash.statemachine.supporting.IResultsRegistry;
import org.osflash.statemachine.supporting.injectThis;
import org.osflash.statemachine.transitioning.supporting.GrumpyPhase;
import org.osflash.statemachine.transitioning.supporting.HappyPhase;
import org.osflash.statemachine.transitioning.supporting.MockPhaseModel;

public class TransitionPhaseDispatcherTest implements IResultsRegistry {

    private var _stateTransition:TransitionPhaseDispatcher;
    private var _results:Array;
    private var _logCode:int;

    [Before]
    public function before():void {
        _logCode = 0;
        _stateTransition = new TransitionPhaseDispatcher( new MockPhaseModel(), _logCode );
        _results = [];
    }

    [After]
    public function tearDown():void {
        _stateTransition = null;
        _results = null
    }

    [Test]
    public function successful_transition_processes_all_phases_in_correct_order():void {
        var expectedResults:String = "[1]HP:M:LC(${logCode}),[2]HP:M:LC(${logCode}),[3]HP:M:LC(${logCode})," +
                                     "[4]HP:M:LC(${logCode}),[5]HP:M:LC(${logCode})";
        expectedResults = injectThis( expectedResults ).finallyWith( "logCode", _logCode );
        setFiveHappyPhasesAndDispatch();
        assertThat( got, equalTo( expectedResults ) );
    }

    [Test]
    public function cancelled_transition_aborts_all_phases_after_cancellation():void {
        var expectedResults:String = "[1]HP:M:LC(${logCode}),[2]HP:M:LC(${logCode}),[3]GP:M:LC(${logCode})";
        expectedResults = injectThis( expectedResults ).finallyWith( "logCode", _logCode );
        setFiveHappyPhasesPlusOneGrumpyPhaseAndDispatch();
        assertThat( got, equalTo( expectedResults ) );
    }

    [Test]
    public function when_no_phases_pushed_throws_StateTransitionError():void {
        var expectedMessage:String = getErrorMessage( ErrorCodes.NO_PHASES_HAVE_BEEN_PUSHED_TO_STATE_TRANSITION );
        const throwFunction:Function = function ():void { _stateTransition.dispatchPhases(); };
        assertThat( throwFunction, throws( allOf( instanceOf( StateTransitionError ), hasPropertyWithValue( "message", expectedMessage ) ) ) );

    }

    public function setFiveHappyPhasesAndDispatch():void {
        _stateTransition.pushTransitionPhase( new HappyPhase( this, 1 ) );
        _stateTransition.pushTransitionPhase( new HappyPhase( this, 2 ) );
        _stateTransition.pushTransitionPhase( new HappyPhase( this, 3 ) );
        _stateTransition.pushTransitionPhase( new HappyPhase( this, 4 ) );
        _stateTransition.pushTransitionPhase( new HappyPhase( this, 5 ) );
        _stateTransition.dispatchPhases();
    }

    public function setFiveHappyPhasesPlusOneGrumpyPhaseAndDispatch():void {
        _stateTransition.pushTransitionPhase( new HappyPhase( this, 1 ) );
        _stateTransition.pushTransitionPhase( new HappyPhase( this, 2 ) );
        _stateTransition.pushTransitionPhase( new GrumpyPhase( this, 3 ) );
        _stateTransition.pushTransitionPhase( new HappyPhase( this, 4 ) );
        _stateTransition.pushTransitionPhase( new HappyPhase( this, 5 ) );
        _stateTransition.pushTransitionPhase( new HappyPhase( this, 6 ) );
        _stateTransition.dispatchPhases();
    }

    public function pushResult( result:Object ):void {
        _results.push( result );
    }

    public function get got():String {
        return _results.join( "," );
    }
}
}
