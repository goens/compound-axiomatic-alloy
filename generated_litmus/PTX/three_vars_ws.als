// Litmus: three_vars_ws
module litmus
open ptx as ptx
pred generated_litmus_test {
  # ptx/Thread = 3
  # ptx/Read = 2
  # ptx/Write = 4
  # ptx/Fence = 3

  some
    t0 : ptx/Thread,
    t1 : ptx/Thread,
    t2 : ptx/Thread,
    r0 : ptx/Read - ptx/Acquire,
    r1 : ptx/Read - ptx/Acquire,
    w0 : ptx/Write - ptx/Release,
    w1 : ptx/Write - ptx/Release,
    w2 : ptx/Write - ptx/Release,
    w3 : ptx/Write - ptx/Release,
    f0 : ptx/FenceAcqRel,
    f1 : ptx/FenceAcqRel,
    f2 : ptx/FenceAcqRel |

    // Program Order
    t0.start = w0 and
    w0.po = f0 and
    f0.po = w1 and
    t0 != t1 and
    t1.start = w2 and
    w2.po = f1 and
    f1.po = w3 and
    t1 != t2 and
    t2.start = r0 and
    r0.po = f2 and
    f2.po = r1 and

    // Addresses 
    r1.address = w0.address and
    w1.address = w2.address and
    r0.address = w3.address and
    r1.address != w1.address and
    r0.address != w1.address and
    r0.address != r1.address and

    // Scopes 
    w0.scope = System and
    f0.scope = System and
    w1.scope = System and
    w2.scope = System and
    f1.scope = System and
    w3.scope = System and
    r0.scope = System and
    f2.scope = System and
    r1.scope = System and

    // Outcome 
    no r1.~rf and
    r0 in w3.rf  and

  ptx_mm

}
run generated_litmus_test for 10