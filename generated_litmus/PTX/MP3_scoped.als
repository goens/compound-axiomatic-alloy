// Litmus: MP3_scoped
// Expected: ✓
module litmus
open ptx as ptx
pred generated_litmus_test {
  # ptx/Thread = 3
  # ptx/Read = 3
  # ptx/Write = 3
  # ptx/Fence = 0

  some
    t0 : ptx/Thread,
    t1 : ptx/Thread,
    t2 : ptx/Thread,
    r0 : ptx/Acquire,
    r1 : ptx/Acquire,
    r2 : ptx/Acquire,
    w0 : ptx/Release,
    w1 : ptx/Release,
    w2 : ptx/Release |

    // Program Order
    t0.start = w0 and
    w0.po = w1 and
    t0 != t1 and
    t1.start = r0 and
    r0.po = w2 and
    t1 != t2 and
    t2.start = r1 and
    r1.po = r2 and

    // Addresses 
    r2.address = w0.address and
    r0.address = w1.address and
    r1.address = w2.address and
    r1.address != r2.address and
    r0.address != r2.address and
    r0.address != r1.address and

    // Scopes 
    t0 in w0.scope.*subscope and
    t1 not in w0.scope.*subscope and
    t2 not in w0.scope.*subscope and
    t0 in w1.scope.*subscope and
    t1 not in w1.scope.*subscope and
    t2 not in w1.scope.*subscope and
    t0 not in r0.scope.*subscope and
    t1 in r0.scope.*subscope and
    t2 in r0.scope.*subscope and
    t0 not in w2.scope.*subscope and
    t1 in w2.scope.*subscope and
    t2 in w2.scope.*subscope and
    t0 not in r1.scope.*subscope and
    t1 in r1.scope.*subscope and
    t2 in r1.scope.*subscope and
    t0 not in r2.scope.*subscope and
    t1 in r2.scope.*subscope and
    t2 in r2.scope.*subscope and

    // Outcome 
    no r2.~rf and
    r1 in w2.rf  and
    r0 in w1.rf  and

  ptx_mm

}
run generated_litmus_test for 10