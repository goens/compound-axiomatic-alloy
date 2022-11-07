// Litmus: tso_two_plus_two2
module litmus
open cmm as cmm
pred generated_litmus_test {
  # cmm/Thread = 2
  # cmm/Read = 2
  # cmm/Write = 4
  # cmm/Fence = 0

  some
    t0 : cmm/Thread,
    t1 : cmm/Thread,
    r0 : cmm/x86Read,
    r1 : cmm/x86Read,
    w0 : cmm/x86Write,
    w1 : cmm/x86Write,
    w2 : cmm/x86Write,
    w3 : cmm/x86Write |

    // Program Order
    t0.start = w0 and
    w0.po = w1 and
    w1.po = r0 and
    t0 != t1 and
    t1.start = w2 and
    w2.po = w3 and
    w3.po = r1 and

    // Addresses 
    r1.address = w0.address and
    r0.address = w1.address and
    r0.address = w2.address and
    r1.address = w3.address and
    r0.address != r1.address and

    // Scopes 
    w0.scope = System and
    w1.scope = System and
    r0.scope = System and
    w2.scope = System and
    w3.scope = System and
    r1.scope = System and

    // Outcome 
    r1 in w0.rf  and
    r0 in w2.rf  and

  cmm_mm

}
run generated_litmus_test for 10