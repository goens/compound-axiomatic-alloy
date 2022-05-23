open util
module tso

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// =Shortcuts=

fun com : MemoryEvent->MemoryEvent { rf + ^co + fr }
fun rfi : MemoryEvent->MemoryEvent { same_thread[rf] }
fun rfe : MemoryEvent->MemoryEvent { rf - rfi }

fun same_thread [rel: Event->Event] : Event->Event { rel & (iden + ^po + ~^po) }
fun location[rel: Event->Event] : Event->Event { rel & (address.~address) }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// =Model of memory=

sig Address { } { #(address :> this) > 1 and #(Write <: address :> this) > 0 }

sig Scope { subscope: set Scope }
fun System : Scope { Scope - Scope.subscope }
fact one_system { one System }
fact unscoped_system { System.subscope in Thread }
sig Thread extends Scope { start: one Event }

abstract sig Event {
  po: lone Event,
  scope: one Scope
}
abstract sig Fence extends Event { } { some (Scope-Thread) => scope not in Thread }
abstract sig MemoryEvent extends Event {
  address: one Address,
  //observation: set MemoryEvent,
}
sig Read extends MemoryEvent {
  // rmw: lone Write, // relevant in TSO?
  dep: set Event
}
sig Write extends MemoryEvent {
  rf: set Read,
  co: set Write,
}

//address
fact com_addr { co + rf + fr in address.~address }

//po
fact po_acyclic { acyclic[po] }
fact some_thread { all e: Event | one t: Thread | t->e in start.*po }
fun po_loc : Event->Event { ^po & address.~address }


//ppo
fun ppo : MemoryEvent->MemoryEvent { (Read->Read + Write->Write + Read->Write) & po }

//reads
fact lone_source_write { rf.~rf in iden }
fun fr : Read->Write {
  ~rf.^co
  +
  // also include reads that read from the initial state
  ((Read - (Write.rf)) <: (address.~address) :> Write)
}

//dep // AG: I don't understand this one
fact dep_facts { dep in ^po }
//rmws
//fact rmw_facts { rmw in po & dep & address.~address & scope.~scope }
//scope
fact inv_subscope { subscope.~subscope in iden }
fact thread_subscope { no Thread.subscope }
fact subscope_acyclic { acyclic[subscope] }
fact events_system_scope { Event.scope = System }

//fence
fun mfence : MemoryEvent->MemoryEvent { (po & MemoryEvent->Fence).po }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// =TSO=

pred location_sc { acyclic[rf + co + fr + po_loc] }
pred causality   { acyclic[rfe + co + fr + ppo + mfence] }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// =Auxiliaries=

//fact obs_in_rf_rmw { observation in ^(strong[rf] + rmw) }
// fact rf_obs { strong[rf] in observation }
// fact rmw_obs { observation.rmw.observation in observation }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

fun typed[rel: Event->Event, type: Event] : Event->Event {
  type <: rel :> type
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

pred emptypred {}
run emptypred for 4
