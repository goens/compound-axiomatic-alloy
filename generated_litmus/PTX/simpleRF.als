// Litmus: simpleRF
// Expected: ✓
module litmus
open ptx as ptx
pred generated_litmus_test {
  # ptx/Thread = 2
  # ptx/Read = 1
  # ptx/Write = 1
  # ptx/Fence = 0

  some
    t0 : ptx/Thread,
    t1 : ptx/Thread,
    r0 : ptx/Read - ptx/Acquire,
    w0 : ptx/Write - ptx/Release |

    // Program Order
    t0.start = w0 and
    t0 != t1 and
    t1.start = r0 and

    // Addresses 
    r0.address = w0.address and

    // Scopes 
    t0 in w0.scope.*subscope and
    t1 not in w0.scope.*subscope and
    t0 not in r0.scope.*subscope and
    t1 in r0.scope.*subscope and

    // Outcome 
    r0 in w0.rf  and

  ptx_mm

}
run generated_litmus_test for 10