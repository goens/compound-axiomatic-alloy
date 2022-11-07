// Litmus: PTX_simpleRF
// Expected: ✓
module litmus
open cmm as cmm
pred generated_litmus_test {
  # cmm/Thread = 2
  # cmm/Read = 1
  # cmm/Write = 1
  # cmm/Fence = 0

  some
    t0 : cmm/Thread,
    t1 : cmm/Thread,
    r0 : cmm/ptxRead - cmm/Acquire,
    w0 : cmm/ptxWrite - cmm/Release |

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

  cmm_mm

}
run generated_litmus_test for 10