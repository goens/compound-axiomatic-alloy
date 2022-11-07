// Litmus: PTX_co_two_thread
// Expected: 𐄂
module litmus
open cmm as cmm
pred generated_litmus_test {
  # cmm/Thread = 2
  # cmm/Read = 2
  # cmm/Write = 2
  # cmm/Fence = 0

  some
    t0 : cmm/Thread,
    t1 : cmm/Thread,
    r0 : cmm/ptxRead - cmm/Acquire,
    r1 : cmm/ptxRead - cmm/Acquire,
    w0 : cmm/ptxWrite - cmm/Release,
    w1 : cmm/ptxWrite - cmm/Release |

    // Program Order
    t0.start = w0 and
    w0.po = r0 and
    t0 != t1 and
    t1.start = w1 and
    w1.po = r1 and

    // Addresses 
    r0.address = r1.address and
    r0.address = w0.address and
    r0.address = w1.address and

    // Scopes 
    w0.scope = System and
    r0.scope = System and
    w1.scope = System and
    r1.scope = System and

    // Outcome 
    r1 in w0.rf  and
    r0 in w1.rf  and

  cmm_mm

}
run generated_litmus_test for 10