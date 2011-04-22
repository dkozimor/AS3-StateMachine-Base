package org.osflash.statemachine.base {
import org.osflash.statemachine.core.IFSMController;
import org.osflash.statemachine.core.IPayload;
import org.osflash.statemachine.core.IState;
import org.osflash.statemachine.core.IStateLogger;
import org.osflash.statemachine.core.IStateModelOwner;
import org.osflash.statemachine.core.ITransitionPhase;
import org.osflash.statemachine.errors.StateTransitionError;

/**
 * Abstract class for creating custom state transitions
 */
public class BaseStateMachine implements IFSMController, IStateLogger {

    /**
     * @private
     */
    protected var currentState:IState;

    /**
     * @private
     */
    protected var currentTransitionPhase:ITransitionPhase;

    /**
     * @private
     */
    private const ILLEGAL_TRANSITION_ERROR:String = "A transition can not be invoked from this phase: ";

    private const INVOKE_TRANSITION_LATER_ALREADY_SCHEDULED:String = "A transition has already been scheduled for later";

    /**
     * @private
     */
    private const ILLEGAL_CANCEL_ERROR:String = "A transition can not be cancelled from this phase: ";

    /**
     * @private
     */
    private var _cachedInfo:String;

    /**
     * @private
     */
    private var _cachedPayload:IPayload;

    /**
     * @private
     */
    private var _canceled:Boolean;

    /**
     * @private
     */
    private var _isTransitioning:Boolean;

    /**
     * @private
     */
    private var _logger:IStateLogger;
    /**
     * @private
     */
    private var _model:IStateModelOwner;
    private var _invokeLaterScheduled:Boolean;

    public function BaseStateMachine( model:IStateModelOwner, logger:IStateLogger = null ) {
        _model = model;
        _logger = logger;
    }

    public final function get currentStateName():String {
        return (currentState == null) ? null : currentState.name;
    }

    /**
     * @inheritDoc
     */
    public final function get isTransitioning():Boolean {
        return _isTransitioning;
    }

    public final function get referringTransitionName():String {
        return (currentState == null) ? null : currentState.referringTransitionName;
    }

    public final function get transitionPhase():ITransitionPhase {
        return currentTransitionPhase;
    }

    public final function transition( transitionName:String, payload:Object = null ):void {

        _cachedInfo = transitionName;
        _cachedPayload = wrapPayload( payload );

        if ( !isTransitionLegal )
            throw new StateTransitionError( ILLEGAL_TRANSITION_ERROR + ( transitionPhase == null ) ? "[undefined]" : transitionPhase.name );

        else if ( isTransitioning && _invokeLaterScheduled )
            throw new StateTransitionError( INVOKE_TRANSITION_LATER_ALREADY_SCHEDULED );

        else if ( isTransitioning ) {
            _invokeLaterScheduled = true;
            listenForStateChangeOnce( invokeTransitionLater );
        }

        else
            invokeTransition( _cachedInfo, _cachedPayload );
    }

    public final function cancelStateTransition( reason:String, payloadBody:Object = null ):void {
        if ( isCancellationLegal ) {
            _canceled = true;
            _cachedInfo = reason;
            _cachedPayload = wrapPayload( payloadBody );
        } else
            throw new StateTransitionError( ILLEGAL_CANCEL_ERROR + ( transitionPhase == null ) ? "[undefined]" : transitionPhase.name );

    }

    /**
     * @inheritDoc
     */
    public function transitionToInitialState():void {
        if ( _model.initialState )
            transitionToState( _model.initialState, null );
    }

    /**
     * @private
     */
    private function invokeTransition( transitionName:String, payload:IPayload ):void {
        const targetState:IState = _model.getTargetState( transitionName, currentState );
        if ( targetState == null )
            log( "Transition: " + transitionName + " is not defined in state: " + currentStateName );
        else transitionToState( targetState, payload );
    }

    /**
     * @private
     */
    protected final function invokeTransitionLater( stateName:String ):void {
        invokeTransition( _cachedInfo, _cachedPayload );
        _cachedInfo = null;
        _cachedPayload = null;
        _invokeLaterScheduled = false;
    }

    /**
     * Determines whether the transition has been marked for cancellation.
     */
    protected final function get isCanceled():Boolean {
        return _canceled;
    }

    /**
     * The reason given for cancelling the transition.
     */
    protected final function get cachedInfo():String {
        return _cachedInfo;
    }

    /**
     * The data payload from the cancel notification.
     */
    protected final function get cachedPayload():IPayload {
        return _cachedPayload;
    }


    protected function transitionToState( target:IState, payload:IPayload ):void {
        _isTransitioning = true;
        onTransition( target, payload );
        _isTransitioning = false;
        if ( isCanceled )
            handleCancelledTransition();
        else
            dispatchGeneralStateChanged();
        reset();
    }

    private function handleCancelledTransition():void {
        _canceled = false;
        log( "the current transition has been cancelled" );
        dispatchTransitionCancelled();
    }

    /**
     * @inheritDoc
     */
    public final function log( msg:String ):void {
        if ( _logger != null )
            _logger.log( msg );
    }

     /**
     * @inheritDoc
     */
    public final function logPhase( phase:ITransitionPhase, state:IState ):void {
        if ( _logger != null )
            _logger.logPhase( phase, state );
    }

    /**
     * @inheritDoc
     */
    public function destroy():void {
        reset();
        currentState = null;
        currentTransitionPhase = null;
        _logger = null;
        _model = null;

    }

    /**
     * Resets any properties needed after each transition.
     * This can be extended, but does not need to be called from a sub-class.
     */
    protected function reset():void {
        _cachedInfo = null;
        _cachedPayload = null;
    }


    /**
     * Do not call this in sub-classes for testing purposes only
     * @param value
     */
    protected final function setIsTransitioning( value:Boolean ):void {
        _isTransitioning = value;
    }


    protected function get isTransitionLegal():Boolean {
        return false;
    }

    protected function get isCancellationLegal():Boolean {
        return false;
    }

    public function listenForStateChange( listener:Function ):* {
        return null;
    }

    public function listenForStateChangeOnce( listener:Function ):* {
        return null;
    }

    public function stopListeningForStateChange( listener:Function ):* {
        return null;
    }

    /**
     * Override to define the state transition.
     * @param target the IState which to transition to.
     * @param payload the data payload from the action notification.
     */
    protected function onTransition( target:IState, payload:Object ):void {
    }

    /**
     * Override to notify interested framework actors that the
     * state has changed.
     */
    protected function dispatchGeneralStateChanged():void {
    }

    /**
     * Override to notify interested framework actors that the
     * state transition has been cancelled.
     */
    protected function dispatchTransitionCancelled():void {
    }

    protected function wrapPayload( body:Object ):IPayload {
        return ( body is IPayload) ? IPayload(body) : new Payload( body );
    }
}
}