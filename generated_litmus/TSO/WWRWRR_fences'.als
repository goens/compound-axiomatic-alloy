// Litmus: WWRWRR_fences'
// Expected: 𐄂
module litmus
open tso as tso
pred generated_litmus_test {
  # tso/Thread = 3
  # tso/Read = 3
  # tso/Write = 3
  # tso/Fence = 3

  some
    t0 : tso/Thread,
    t1 : tso/Thread,
    t2 : tso/Thread,
    r0 : tso/Read,
    r1 : tso/Read,
    r2 : tso/Read,
    w0 : tso/Write,
    w1 : tso/Write,
    w2 : tso/Write,
    f0 : tso/Fence,
    f1 : tso/Fence,
    f2 : tso/Fence |

    // Program Order
    t0.start = w0 and
    w0.po = f0 and
    f0.po = w1 and
    t0 != t1 and
    t1.start = r0 and
    r0.po = f1 and
    f1.po = w2 and
    t1 != t2 and
    t2.start = r1 and
    r1.po = f2 and
    f2.po = r2 and

    // Addresses 
    r2.address = w0.address and
    r0.address = w1.address and
    r1.address = w2.address and
    r1.address != r2.address and
    r0.address != r2.address and
    r0.address != r1.address and

    // Scopes 
    w0.scope = System and
    f0.scope = System and
    w1.scope = System and
    r0.scope = System and
    f1.scope = System and
    w2.scope = System and
    r1.scope = System and
    f2.scope = System and
    r2.scope = System and

    // Outcome 
    no r2.~rf and
    r1 in w2.rf  and
    r0 in w1.rf  and

  tso_mm

}
run generated_litmus_test for 10