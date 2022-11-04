// Litmus: WRC
module litmus
open tso as tso
pred generated_litmus_test {
  # tso/Thread = 3
  # tso/Read = 3
  # tso/Write = 2
  # tso/Fence = 0

  some
    t0 : tso/Thread,
    t1 : tso/Thread,
    t2 : tso/Thread,
    r0 : tso/Read,
    r1 : tso/Read,
    r2 : tso/Read,
    w0 : tso/Write,
    w1 : tso/Write |

    // Program Order
    t0.start = w0 and
    t0 != t1 and
    t1.start = r0 and
    r0.po = w1 and
    t1 != t2 and
    t2.start = r1 and
    r1.po = r2 and
    r1.dep = r2 and

    // Addresses 
    r0.address = r2.address and
    r0.address = w0.address and
    r1.address = w1.address and
    r0.address != r1.address and

    // Scopes 
    w0.scope = System and
    r0.scope = System and
    w1.scope = System and
    r1.scope = System and
    r2.scope = System and

    // Outcome 
    no r2.~rf and
    r1 in w1.rf  and
    r0 in w0.rf  and

  tso_mm

}
run generated_litmus_test for 10