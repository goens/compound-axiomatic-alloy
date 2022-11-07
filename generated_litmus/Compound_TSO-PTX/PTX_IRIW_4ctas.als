// Litmus: PTX_IRIW_4ctas
// Expected: ✓
module litmus
open cmm as cmm
pred generated_litmus_test {
  # cmm/Thread = 4
  # cmm/Read = 4
  # cmm/Write = 2
  # cmm/Fence = 2

  some
    t0 : cmm/Thread,
    t1 : cmm/Thread,
    t2 : cmm/Thread,
    t3 : cmm/Thread,
    r0 : cmm/ptxRead - cmm/Acquire,
    r1 : cmm/ptxRead - cmm/Acquire,
    r2 : cmm/ptxRead - cmm/Acquire,
    r3 : cmm/ptxRead - cmm/Acquire,
    w0 : cmm/ptxWrite - cmm/Release,
    w1 : cmm/ptxWrite - cmm/Release,
    f0 : cmm/ptxFenceSC,
    f1 : cmm/ptxFenceSC |

    // Program Order
    t0.start = w0 and
    t0 != t1 and
    t1.start = r0 and
    r0.po = f0 and
    f0.po = r1 and
    t1 != t2 and
    t2.start = r2 and
    r2.po = f1 and
    f1.po = r3 and
    t2 != t3 and
    t3.start = w1 and

    // Addresses 
    r1.address = r2.address and
    r0.address = r3.address and
    r0.address = w0.address and
    r1.address = w1.address and
    r0.address != r1.address and

    // Scopes 
    w0.scope = System and
    t0 not in r0.scope.*subscope and
    t1 in r0.scope.*subscope and
    t2 not in r0.scope.*subscope and
    t3 not in r0.scope.*subscope and
    f0.scope = System and
    t0 not in r1.scope.*subscope and
    t1 in r1.scope.*subscope and
    t2 not in r1.scope.*subscope and
    t3 not in r1.scope.*subscope and
    t0 not in r2.scope.*subscope and
    t1 not in r2.scope.*subscope and
    t2 in r2.scope.*subscope and
    t3 not in r2.scope.*subscope and
    f1.scope = System and
    r3.scope = System and
    w1.scope = System and

    // Outcome 
    no r3.~rf and
    r2 in w1.rf  and
    no r1.~rf and
    r0 in w0.rf  and

  cmm_mm

}
run generated_litmus_test for 10