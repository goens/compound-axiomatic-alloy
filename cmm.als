open util
module cmm

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
sig EvType {evtyp: set EvType} // x86 or PTX
fun System : Scope { Scope - Scope.subscope }
fact one_system { one System }
sig Thread extends Scope { start: one Event }

abstract sig Event {
  po: lone Event, 
  scope: one Scope
}
abstract sig Fence extends Event { } { some (Scope-Thread) => scope not in Thread }
abstract sig MemoryEvent extends Event {
  address: one Address,
  observation: set MemoryEvent,
}
sig Read extends MemoryEvent {
  rmw: lone Write 
}
sig Write extends MemoryEvent {
  rf: set Read,
  co: set Write,
}

sig x86Read extends Read { 
  gsc_x86Read : set Event,
}

fun ppo : MemoryEvent->MemoryEvent { (x86Read->x86Read + x86Write->x86Write + x86Read->x86Write) & po }

sig x86Write extends Write { }

sig ptxRead extends Read {
 dep: set Event
}

sig ptxWrite extends Write { }

sig mFence extends Fence { 
  gsc_mfence : set Event,   
} 

sig ptxFence extends Fence { 
 gsc_ptxFence : set Event, 
}


//address
fact com_addr { co + rf + fr in address.~address }

//po
fact po_acyclic { acyclic[po] }
fact some_thread { all e: Event | one t: Thread | t->e in start.*po }
fun po_loc : Event->Event { ^po & address.~address }

//reads
fact lone_source_write { rf.~rf in iden }
fun fr : Read->Write {
  ~rf.^co
  +
  // also include reads that read from the initial state
  ((Read - (Write.rf)) <: (address.~address) :> Write)
}

//dep
fact dep_facts { dep in ^po }

//ppo
fact ppo_facts { ppo in ^po }

//rmws
fact rmw_facts { rmw in po & dep & address.~address & scope.~scope }
//scope
fact inv_subscope { subscope.~subscope in iden }
fact thread_subscope { no Thread.subscope }
fact subscope_acyclic { acyclic[subscope] }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// =PTX=

pred coherence   { location[Write <: cord :> Write] in ^co }
pred fenceSC { acyclic[gsc + cord] }
pred causality   { irreflexive[optional[fr + rf].cord] }
pred atomicity   { no strong[fr].(strong[co]) & rmw }
pred sc_per_sc { acyclic[strong[com] + po_loc] }
pred no_thin_air { acyclic[rf + dep + ppo] }
pred cordECO { irreflexive[cord.(Event <: optional[eco]:> Event)] }


pred cmm_mm {
  no_thin_air and sc_per_sc and atomicity and coherence
  and causality and fenceSC and cordECO
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// =Auxiliaries=

fact obs_in_rf_rmw { observation in ^(strong[rf] + rmw) }
fact rf_obs { strong[rf] in observation }
fact rmw_obs { observation.rmw.observation in observation }

fun prefix : Event->Event      { (Release <: optional[po_loc] :> Write) + (FenceRels <: ^po :> Write) }
fun suffix : Event->Event      { (Read <: optional[po_loc] :> Acquire) + (Read <: ^po :> FenceAcqs) }

fun x86MemoryEvent : set Event { x86Read + x86Write }
fun x86Event : set Event {x86MemoryEvent + mFence} 

fun ptxMemoryEvent : set Event { ptxRead + ptxWrite }
fun ptxEvent : set Event { ptxMemoryEvent + ptxFence } 

fun gprel : Event->Event      { prefix + (x86Event <: optional[^po] :> x86Write) }
fun gpacq : Event->Event      { suffix + (x86Read <: optional[^po] :> x86Event) }


fun Releasers : Event          { Release + FenceRels + (FenceRels.po.rmw)}
fun Acquirers : Event          { Acquire + FenceAcqs }

fun xgReleasers : Event          { Releasers + x86Write + mFence}  // may be mFence is not required here
fun xgAcquirers : Event          { Acquirers + x86Read + mFence } // may be mFence is not required here


fun xgsync[head: Event, tail: Event] : Event->Event {
  head <: strong[gprel.^observation.gpacq] :> tail
}
fun xg_cause_base : Event->Event  {
  ^(*po.(gsc + xgsync[xgReleasers,xgAcquirers]).*po)
}
fun xgcause : Event->Event {
  xg_cause_base + (observation.(po_loc + xg_cause_base))
}



//fun implid : Event-> Event { (typed[po, x86MemoryEvent]).(dom(rmw)+codom(rmw)+mFence) & x86MemoryEvent->mFence).typed[po, x86MemoryEvent] }

fun implid : Event-> Event { x86Event <:po:> (dom[rmw]+codom[rmw]+mFence) +  (dom[rmw]+codom[rmw]+mFence) <:po:> x86Event }


fun xhb : Event -> Event { typed[^(rfe + co + fr + ppo + implid), x86Event] }

fun gxhb : Event -> Event { (ptxWrite <: optional[rfe] :> x86Read).xhb }

fun cord : Event -> Event { typed[^(gxhb + xgcause), Event]}

fun eco : Event -> Event { ^com }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

fun typed[rel: Event->Event, type: Event] : Event->Event {
  type <: rel :> type
}
fun inside[s: Scope] : Event {
  s.*subscope.start.*po
}
fun scoped[s: Scope] : Event {
  s.*~subscope.~scope
}
fun strong_r : Event->Event {
  symmetric[scope.*subscope.start.*po]
}
fun weak[r: Event->Event]: Event->Event {
  r - strong_r
}
fun strong[r: Event->Event]: Event->Event {
  r & strong_r
}
pred is_strong[r: Event->Event] {
  r in strong_r
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

sig ptxFenceAcq extends ptxFence { }
sig ptxFenceRel extends ptxFence { }
sig ptxFenceAcqRel extends ptxFence { }

sig ptxFenceSC extends ptxFenceAcqRel {
   sc: set ptxFenceSC,
}

fun SCLike : set Event { mFence + x86Read + ptxFenceSC }

fun gsc : Event -> Event { (gsc_x86Read + gsc_mfence + gsc_ptxFence) - (x86MemoryEvent -> x86MemoryEvent)}




fun FenceRels : Fence { ptxFenceAcqRel + ptxFenceRel + BarrierWait }
fun FenceAcqs : Fence { ptxFenceAcqRel + ptxFenceAcq + BarrierWait }

sig Acquire extends ptxRead { } { scope not in Thread }
sig Release extends ptxWrite { } { scope not in Thread }

//writes
fact co_per_scope {
  all a: Address | all s: Scope |
    total[co, scoped[s] & inside[s] & (a.~address & Write)]
}
abstract sig Barrier extends Event {} { }
sig BarrierArrive extends Barrier { synchronizes: set BarrierWait }
sig BarrierWait extends Barrier {}

//scope
fact scope_inclusion { scope in *~po.~start.*~subscope }

//barrier
// no isolated barrier pieces
fact { all b: BarrierArrive | some b.synchronizes }
fact { all b: BarrierWait | some b.~synchronizes }
// bar.sync = BarrierArrive; po; BarrierWait
fact { BarrierWait in BarrierArrive.(po & synchronizes) }
// transitivity
fact { synchronizes.~synchronizes.synchronizes in synchronizes }
fact { ~synchronizes.synchronizes.~synchronizes in ~synchronizes }
// Prevents two BarrierArrives in the same thread synchronizing with the same Barrier
fact { no ^po & synchronizes.~synchronizes }
// Prevents one BarrierArrive from synchronizing with two BarrierSyncs in the same thread
fact { no ^po & ~synchronizes.synchronizes }
// synchronizes is morally strong: i.e., you can only synchronize within the same block
fact { is_strong[synchronizes] }

//fence
fact wf_gsc {
  //all s: Scope | total[sc, scoped[s] & inside[s] & FenceSC]
  all disj f1, f2 : SCLike | f1->f2 in strong_r  => (f1->f2 in gsc or f2->f1 in gsc or f1->f2 in x86MemoryEvent -> x86MemoryEvent)
  gsc in typed[strong_r, SCLike]
  acyclic[gsc]
  gsc = SCLike <: gsc :> SCLike
}

fact threads_one_type { po = ( x86Event <: po :> x86Event) + (ptxEvent <: po :> ptxEvent) }
