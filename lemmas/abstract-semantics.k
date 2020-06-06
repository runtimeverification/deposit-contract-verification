requires "verification.k"

module ABSTRACT-SEMANTICS
  imports VERIFICATION

  // to avoid unnecessary case analyses
  rule <k> LT W0 W1 => bool2Word(W0  <Int W1) ~> #push ... </k> [trusted]
  rule <k> GT W0 W1 => bool2Word(W0  >Int W1) ~> #push ... </k> [trusted]
  rule <k> EQ W0 W1 => bool2Word(W0 ==Int W1) ~> #push ... </k> [trusted]
  rule <k> ISZERO W => bool2Word(W  ==Int 0 ) ~> #push ... </k> [trusted]

  rule <k> SHA256 => #end EVMC_SUCCESS ... </k>
       <callData> DATA </callData>
       <output> _ => #buf(32, #sha256(DATA)) </output>
    requires notBool #isConcrete(DATA)
    [trusted]

  // gas abstraction

  // see also lemmas.k

  rule <k> G':Int ~> #deductGas => . ... </k>
       <gas> G => G -Gas G' </gas>
       requires #getKLabelString(G) ==String "#symGas"
        andBool #isInf(G)
      [trusted]

  rule <k> GCALL:Int ~> #allocateCallGas => . ... </k>
       <callGas> _ => #symGas(SCHED, GCALL, 0, 0, 0, #symMem(0)) </callGas>
       <schedule> SCHED </schedule>
      [trusted]

  rule <k> #refund G:Int => . ... </k>
       <gas> GAVAIL => GAVAIL +Gas G </gas>
      [trusted]

/* NOTE:
   These abstractions are over-approximation, except that out-of-gas exceptions are ignored.
   The out-of-gas exception is not harmful when it comes to safety properties, and it can be avoided by simply providing enough gas.
   The only problematic case is to call sub-functions with a specific amount of gas (instead of all available gas at that point).
   In this case, additional analyses need to be made to ensure that the specific amount of gas is sufficient, for liveness properties.
   Note that the above #deductGas abstract rule is applied only when the full gas is passed to sub-function calls.
*/

endmodule
