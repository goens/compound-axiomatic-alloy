// Litmus: dekkers_fence
module litmus
open tso as tso
pred generated_litmus_test {
  # tso/Thread = 2
  # tso/Read = 2
  # tso/Write = 2
  # tso/Fence = 2

  some
    t0 : tso/Thread,
    t1 : tso/Thread,
    r0 : tso/Read,
    r1 : tso/Read,
    w0 : tso/Write,
    w1 : tso/Write,
    f0 : tso/Fence,
    f1 : tso/Fence |

    // Program Order
    t0.start = w0 and
    w0.po = f0 and
    f0.po = r0 and
    t0 != t1 and
    t1.start = w1 and
    w1.po = f1 and
    f1.po = r1 and

    // Addresses 
    r1.address = w0.address and
    r0.address = w1.address and
    r0.address != r1.address and

    // Scopes 
    w0.scope = System and
    f0.scope = System and
    r0.scope = System and
    w1.scope = System and
    f1.scope = System and
    r1.scope = System and

    // Outcome 
    no r1.~rf and
    no r0.~rf and

  tso_mm

}
run generated_litmus_test for 10