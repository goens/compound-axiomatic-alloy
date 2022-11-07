// Litmus: PTX_MP3_scoped
// Expected: ✓
module litmus
open cmm as cmm
pred generated_litmus_test {
  # cmm/Thread = 3
  # cmm/Read = 3
  # cmm/Write = 3
  # cmm/Fence = 0

  some
    t0 : cmm/Thread,
    t1 : cmm/Thread,
    t2 : cmm/Thread,
    r0 : cmm/Acquire,
    r1 : cmm/Acquire,
    r2 : cmm/Acquire,
    w0 : cmm/Release,
    w1 : cmm/Release,
    w2 : cmm/Release |

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

  cmm_mm

}
run generated_litmus_test for 10