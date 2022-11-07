// Litmus: IRIW_fences
// Expected: 𐄂
module litmus
open tso as tso
pred generated_litmus_test {
  # tso/Thread = 4
  # tso/Read = 4
  # tso/Write = 2
  # tso/Fence = 2

  some
    t0 : tso/Thread,
    t1 : tso/Thread,
    t2 : tso/Thread,
    t3 : tso/Thread,
    r0 : tso/Read,
    r1 : tso/Read,
    r2 : tso/Read,
    r3 : tso/Read,
    w0 : tso/Write,
    w1 : tso/Write,
    f0 : tso/Fence,
    f1 : tso/Fence |

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
    r0.scope = System and
    f0.scope = System and
    r1.scope = System and
    r2.scope = System and
    f1.scope = System and
    r3.scope = System and
    w1.scope = System and

    // Outcome 
    no r3.~rf and
    r2 in w1.rf  and
    no r1.~rf and
    r0 in w0.rf  and

  tso_mm

}
run generated_litmus_test for 10