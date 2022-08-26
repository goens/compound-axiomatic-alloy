module litmus
open util as util
open ptx as ptx
// open src11[ptx/Event,ptx/Address,ptx/Scope] as src11
// open compile_src11_ptx

pred IRIW {
	# ptx/Thread = 4
   # ptx/Read = 4
   # ptx/Write = 2
   // # ptx/Fence = 2
	all e : Event | e.scope = System
	some t0 : ptx/Thread, t1 : ptx/Thread, t2 : ptx/Thread, t3 : ptx/Thread,
	   w0 : ptx/Write, w1 : ptx/Write, r0 : ptx/Read, r1 : ptx/Read,
	   r2 : ptx/Read, r3 : ptx/Read |
		t0.start = w0 and
 	   t1.start = r0 and r0.po = r1 and
      t2.start = w1 and
	   t3.start = r2 and r2.po = r3 and
	   r0.address = w0.address and r1.address = w1.address and
	  r2.address = w1.address and r3.address = w0.address and
	w0.address != w1.address and
		w0.rf = r0 and w1.rf = r2
}

run IRIW for 10


pred IRIW_fences_sys {
	# ptx/Scope = 5
	# ptx/Thread = 4
   # ptx/Read = 4
   # ptx/Write = 4
   # ptx/Fence = 2
	all e : Event | e.scope = System
	some t0 : ptx/Thread, t1 : ptx/Thread, t2 : ptx/Thread, t3 : ptx/Thread,
	w00 : ptx/Write, w01 : ptx/Write,
	w0 : ptx/Write, w1 : ptx/Write,
	r0 : ptx/Read, r1 : ptx/Read,
	r2 : ptx/Read, r3 : ptx/Read, f0 : ptx/FenceSC, f1 : ptx/FenceSC |
	t0.start = w00 and w00.po = w0 and
	t1.start = r0 and r0.po = f0 and f0.po = r1 and
	t2.start = w01 and w01.po = w1 and
	t3.start = r2 and r2.po = f1 and f1.po = r3 and
	r0.address = w0.address and r1.address = w1.address and
	r2.address = w1.address and r3.address = w0.address and
	w0.address != w1.address and
	w0.rf = r0 and w1.rf = r2 and
	w00.address = w0.address and
	w01.address = w1.address and
	w00.rf = r3 and w01.rf = r1 and
	f0.scope = f1.scope and
	t0 in f0.scope.*subscope and
	t2 in f0.scope.*subscope and
	t1 in f0.scope.*subscope and
	t3 in f0.scope.*subscope and

	// explicitly add FensceSC axiom:
	irreflexive[sc.cause]

}
run IRIW_fences_sys for 10

pred IRIW_fences_cta {
	# ptx/Thread = 4
	# ptx/Scope = 7
   # ptx/Read = 4
   # ptx/Write = 2
   # ptx/Fence = 2
	all e : Event - ptx/Fence | e.scope = System
	some t0 : ptx/Thread, t1 : ptx/Thread, t2 : ptx/Thread, t3 : ptx/Thread,
	w0 : ptx/Write, w1 : ptx/Write, r0 : ptx/Read, r1 : ptx/Read,
	r2 : ptx/Read, r3 : ptx/Read, f0 : ptx/Fence, f1 : ptx/Fence |
	t0.start = w0 and
	t1.start = r0 and r0.po = f0 and f0.po = r1 and
	t2.start = w1 and
	t3.start = r2 and r2.po = f1 and f1.po = r3 and
	r0.address = w0.address and r1.address = w1.address and
	r2.address = w1.address and r3.address = w0.address and
	w0.address != w1.address and
	w0.rf = r0 and w1.rf = r2 and
	t0 not in f0.scope.*subscope and
	t3 not in f0.scope.*subscope and
	t1 in f0.scope.*subscope and
	t2 in f0.scope.*subscope and
	t0 in f1.scope.*subscope and
	t3 in f1.scope.*subscope and
	t1 not in f1.scope.*subscope and
	t2 not in f1.scope.*subscope
}

run IRIW_fences_cta for 10
