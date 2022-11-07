// Litmus: ISA2_middle_ptx_acq_fence
// Expected: 𐄂
module litmus
open cmm as cmm
pred generated_litmus_test {
  # cmm/Thread = 3
  # cmm/Read = 3
  # cmm/Write = 3
  # cmm/Fence = 1

  some
    t0 : cmm/Thread,
    t1 : cmm/Thread,
    t2 : cmm/Thread,
    r0 : cmm/ptxRead - cmm/Acquire,
    r1 : cmm/x86Read,
    r2 : cmm/x86Read,
    w0 : cmm/x86Write,
    w1 : cmm/x86Write,
    w2 : cmm/ptxWrite - cmm/Release,
    f0 : cmm/ptxFenceAcq |

    // Program Order
    t0.start = w0 and
    w0.po = w1 and
    t0 != t1 and
    t1.start = r0 and
    r0.po = f0 and
    f0.po = w2 and
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
    w0.scope = System and
    w1.scope = System and
    r0.scope = System and
    f0.scope = System and
    w2.scope = System and
    r1.scope = System and
    r2.scope = System and

    // Outcome 
    no r2.~rf and
    r1 in w2.rf  and
    r0 in w1.rf  and

  cmm_mm

}
run generated_litmus_test for 10