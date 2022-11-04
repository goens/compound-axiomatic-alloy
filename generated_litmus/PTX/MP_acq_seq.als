// Litmus: MP_acq_seq
module litmus
open ptx as ptx
pred generated_litmus_test {
  # ptx/Thread = 2
  # ptx/Read = 3
  # ptx/Write = 2
  # ptx/Fence = 0

  some
    t0 : ptx/Thread,
    t1 : ptx/Thread,
    r0 : ptx/Read - ptx/Acquire,
    r1 : ptx/Acquire,
    r2 : ptx/Read - ptx/Acquire,
    w0 : ptx/Write - ptx/Release,
    w1 : ptx/Release |

    // Program Order
    t0.start = w0 and
    w0.po = w1 and
    t0 != t1 and
    t1.start = r0 and
    r0.po = r1 and
    r1.po = r2 and

    // Addresses 
    r0.address = r1.address and
    r2.address = w0.address and
    r0.address = w1.address and
    r0.address != r2.address and

    // Scopes 
    w0.scope = System and
    w1.scope = System and
    r0.scope = System and
    r1.scope = System and
    r2.scope = System and

    // Outcome 
    no r2.~rf and
    r0 in w1.rf  and

  ptx_mm

}
run generated_litmus_test for 10