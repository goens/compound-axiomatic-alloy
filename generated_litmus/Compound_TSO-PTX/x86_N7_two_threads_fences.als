// Litmus: x86_N7_two_threads_fences
// Expected: 𐄂
module litmus
open cmm as cmm
pred generated_litmus_test {
  # cmm/Thread = 2
  # cmm/Read = 4
  # cmm/Write = 2
  # cmm/Fence = 2

  some
    t0 : cmm/Thread,
    t1 : cmm/Thread,
    r0 : cmm/x86Read,
    r1 : cmm/x86Read,
    r2 : cmm/x86Read,
    r3 : cmm/x86Read,
    w0 : cmm/x86Write,
    w1 : cmm/x86Write,
    f0 : cmm/mFence,
    f1 : cmm/mFence |

    // Program Order
    t0.start = w0 and
    w0.po = f0 and
    f0.po = r0 and
    r0.po = r1 and
    t0 != t1 and
    t1.start = w1 and
    w1.po = f1 and
    f1.po = r2 and
    r2.po = r3 and

    // Addresses 
    r1.address = r2.address and
    r0.address = r3.address and
    r0.address = w0.address and
    r1.address = w1.address and
    r0.address != r1.address and

    // Scopes 
    w0.scope = System and
    f0.scope = System and
    r0.scope = System and
    r1.scope = System and
    w1.scope = System and
    f1.scope = System and
    r2.scope = System and
    r3.scope = System and

    // Outcome 
    no r3.~rf and
    r2 in w1.rf  and
    no r1.~rf and
    r0 in w0.rf  and

  cmm_mm

}
run generated_litmus_test for 10