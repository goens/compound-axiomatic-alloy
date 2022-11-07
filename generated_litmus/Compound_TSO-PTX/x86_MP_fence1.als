// Litmus: x86_MP_fence1
// Expected: 𐄂
module litmus
open cmm as cmm
pred generated_litmus_test {
  # cmm/Thread = 2
  # cmm/Read = 2
  # cmm/Write = 2
  # cmm/Fence = 1

  some
    t0 : cmm/Thread,
    t1 : cmm/Thread,
    r0 : cmm/x86Read,
    r1 : cmm/x86Read,
    w0 : cmm/x86Write,
    w1 : cmm/x86Write,
    f0 : cmm/mFence |

    // Program Order
    t0.start = w0 and
    w0.po = f0 and
    f0.po = w1 and
    t0 != t1 and
    t1.start = r0 and
    r0.po = r1 and

    // Addresses 
    r1.address = w0.address and
    r0.address = w1.address and
    r0.address != r1.address and

    // Scopes 
    w0.scope = System and
    f0.scope = System and
    w1.scope = System and
    r0.scope = System and
    r1.scope = System and

    // Outcome 
    no r1.~rf and
    r0 in w1.rf  and

  cmm_mm

}
run generated_litmus_test for 10