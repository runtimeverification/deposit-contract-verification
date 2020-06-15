requires "edsl.md"
requires "lemmas.k"

module VERIFICATION-L1
    imports VERIFICATION

  //rule #node(0, _, _) => 0
    rule #node(I +Int 1, N, M) => #if 1 &Int #size(I, N) ==Int 1
                                  #then #sha256(#buf(32, select(M, I)) ++ #buf(32, #node(I, N, M)))
                                  #else #sha256(#buf(32, #node(I, N, M)) ++ #buf(32, select(M, 33 +Int I)))
                                  #fi
    requires 0 <=Int I andBool I <Int 32

  //rule #size(0, N) => N
    rule #size(I +Int 1, N) => #size(I, N) /Int 2
    requires 0 <=Int I andBool I <Int 32

endmodule

module VERIFICATION
    imports EVM
    imports EDSL
    imports LEMMAS

    rule #sizeByteArray(WS) => #sizeWordStack(WS)

    // function signature extraction

    rule #asWord(B1 : B2 : B3 : B4 : WS) >>Int 224 => #asWord(B1 : B2 : B3 : B4 : .WordStack)
    requires #sizeWordStack(WS) ==Int 28

    // for to_little_endian_64()

    syntax WordStack ::= #toLittleEndian64(Int) [function]
    rule #toLittleEndian64(N)
      =>    N           modInt 256  /* bytesValue[7] == (chop(N <<Int 192) >>Int 192) modInt 256 */
         : (N >>Int  8) modInt 256  /* bytesValue[6] == (chop(N <<Int 192) >>Int 200) modInt 256 */
         : (N >>Int 16) modInt 256  /* bytesValue[5] == (chop(N <<Int 192) >>Int 208) modInt 256 */
         : (N >>Int 24) modInt 256  /* bytesValue[4] == (chop(N <<Int 192) >>Int 216) modInt 256 */
         : (N >>Int 32) modInt 256  /* bytesValue[3] == (chop(N <<Int 192) >>Int 224) modInt 256 */
         : (N >>Int 40) modInt 256  /* bytesValue[2] == (chop(N <<Int 192) >>Int 232) modInt 256 */
         : (N >>Int 48) modInt 256  /* bytesValue[1] == (chop(N <<Int 192) >>Int 240) modInt 256 */
         : (N >>Int 56) modInt 256  /* bytesValue[0] == (chop(N <<Int 192) >>Int 248) modInt 256 */
         : .WordStack

    // redundant extra bit operation: ((115339776388732929035197660848497720713218148788040405586178452820382218977280 /* 0xff000...000 */ &Int chop(DEPOSIT_COUNT_i <<Int 248)) >>Int 248) modInt 256

    // masking first 8 bits
    rule 115339776388732929035197660848497720713218148788040405586178452820382218977280 &Int
         chop(X <<Int 248)
      => chop(X <<Int 248)
    requires X >=Int 0

    // masking first 64 bits
    rule 115792089237316195417293883273301227089434195242432897623355228563449095127040 &Int
         #asWord(V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : WS)
      => #asWord(V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : WS)
    requires WS ==K #buf(24, 0)
     andBool #rangeUInt(8, V0)
     andBool #rangeUInt(8, V1)
     andBool #rangeUInt(8, V2)
     andBool #rangeUInt(8, V3)
     andBool #rangeUInt(8, V4)
     andBool #rangeUInt(8, V5)
     andBool #rangeUInt(8, V6)
     andBool #rangeUInt(8, V7)

    rule (chop(X <<Int 248) >>Int 248) modInt 256 => X
    requires #rangeUInt(8, X)

    rule (chop(X <<Int 192) >>Int 192) modInt 256 =>  X           modInt 256 requires X >=Int 0
    rule (chop(X <<Int 192) >>Int 200) modInt 256 => (X >>Int  8) modInt 256 requires X >=Int 0
    rule (chop(X <<Int 192) >>Int 208) modInt 256 => (X >>Int 16) modInt 256 requires X >=Int 0
    rule (chop(X <<Int 192) >>Int 216) modInt 256 => (X >>Int 24) modInt 256 requires X >=Int 0
    rule (chop(X <<Int 192) >>Int 224) modInt 256 => (X >>Int 32) modInt 256 requires X >=Int 0
    rule (chop(X <<Int 192) >>Int 232) modInt 256 => (X >>Int 40) modInt 256 requires X >=Int 0
    rule (chop(X <<Int 192) >>Int 240) modInt 256 => (X >>Int 48) modInt 256 requires X >=Int 0
    rule (chop(X <<Int 192) >>Int 248) modInt 256 => (X >>Int 56) modInt 256 requires X >=Int 0

    rule
    selectRange(
        store(store(store(store(store(store(store(store(M,
            X0, V0),
            X1, V1),
            X2, V2),
            X3, V3),
            X4, V4),
            X5, V5),
            X6, V6),
            X7, V7),
        START, WIDTH)
    =>
    V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : selectRange(M, START +Int 8, WIDTH -Int 8)
    requires WIDTH >=Int 8
     andBool X0 ==Int START
     andBool X1 ==Int START +Int 1
     andBool X2 ==Int START +Int 2
     andBool X3 ==Int START +Int 3
     andBool X4 ==Int START +Int 4
     andBool X5 ==Int START +Int 5
     andBool X6 ==Int START +Int 6
     andBool X7 ==Int START +Int 7
     andBool #rangeUInt(8, V0)
     andBool #rangeUInt(8, V1)
     andBool #rangeUInt(8, V2)
     andBool #rangeUInt(8, V3)
     andBool #rangeUInt(8, V4)
     andBool #rangeUInt(8, V5)
     andBool #rangeUInt(8, V6)
     andBool #rangeUInt(8, V7)

    // for get_deposit_root

    rule (X +Int I) -Int X => I requires notBool #isConcrete(X) andBool #isConcrete(I)

    rule (X +Int I1) -Int (X +Int I2) => I1 -Int I2 requires notBool #isConcrete(X) andBool #isConcrete(I1) andBool #isConcrete(I2)

    rule X |Int Y => Y requires X ==Int 0

    rule #bufSeg(V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : _, 0, 8) => V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : .WordStack

    // masking first 64 bits
    rule #asWord(V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : WS) &Int 115792089237316195417293883273301227089434195242432897623355228563449095127040
      => #asWord(V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : #buf(24, 0))
    requires #sizeWordStack(WS) ==Int 24
     andBool #rangeUInt(8, V0)
     andBool #rangeUInt(8, V1)
     andBool #rangeUInt(8, V2)
     andBool #rangeUInt(8, V3)
     andBool #rangeUInt(8, V4)
     andBool #rangeUInt(8, V5)
     andBool #rangeUInt(8, V6)
     andBool #rangeUInt(8, V7)

    syntax Int ::= #node(Int, Int, Map) [function, smtlib(nodeD)]
    rule #node(0, _, _) => 0
  //rule #node(I +Int 1, N, M) => #if 1 &Int #size(I, N) ==Int 1
  //                              #then #sha256(#buf(32, select(M, I)) ++ #buf(32, #node(I, N, M)))
  //                              #else #sha256(#buf(32, #node(I, N, M)) ++ #buf(32, select(M, 33 +Int I)))
  //                              #fi
  //requires 0 <=Int I andBool I <Int 32
  //see module VERIFICATION-L1

    rule 0 <=Int #node(_, _, _)             => true
    rule         #node(_, _, _) <Int pow256 => true

    syntax Int ::= #size(Int, Int) [function, smtlib(sizeD)]
    rule #size(0, N) => N
  //rule #size(I +Int 1, N) => #size(I, N) /Int 2
  //requires 0 <=Int I andBool I <Int 32
  //see module VERIFICATION-L1

    rule 0 <=Int #size(_, _)             => true
    rule         #size(_, _) <Int pow256 => true

    // to_little_endian_64

    syntax Map ::= ".IMap" [function, smtlib(emptyIMap), smt-prelude]
    rule select(.IMap, _) => 0
    rule selectRange(.IMap, _, W) => #buf(W, 0) requires W >=Int 0

    // deposit

    // masking last 24 bytes
    rule #bufSeg(#buf(32, #asWord(V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : WS) |Int (X &Int 6277101735386680763835789423207666416102355444464034512895)), 0, 8)
      => V0 : V1 : V2 : V3 : V4 : V5 : V6 : V7 : .WordStack
    requires WS ==K #buf(24, 0) // relaxed: #sizeWordStack(WS) ==Int 24
     andBool #rangeUInt(256, X)

    rule 1 &Int X => X modInt 2 [concrete, smt-lemma]

    rule isStorage(store(M, _, _)) => true
    requires isStorage(M)

    // for revert-invalid_function_identifier-ge_4

    rule #take(4, #takeAux(32, WS, .WordStack))
      => #take(4, WS)

    // for deposit-calldata-decoding

    rule #asWord(WS) >>Int 224
      => #asWord(#take(4, WS))
    requires #sizeWordStack(WS) ==Int 32

    // for supportsInterface

    syntax TypedArg ::= #bytes4 ( Int )

    rule #typeName(   #bytes4( _ )) => "bytes4"
    rule #lenOfHead(  #bytes4( _ )) => 32
    rule #isStaticType(  #bytes4( _ )) => true
    rule #enc(#bytes4( DATA )) => #buf(4, #getValue(#bytes4( DATA ))) ++ #buf(28, 0)
    rule #getValue(#bytes4( DATA )) => DATA requires #rangeUInt(32, DATA)

    syntax Int ::= "minUInt32"
                 | "maxUInt32"

    rule minUInt32 => 0          [macro]
    rule maxUInt32 => 4294967295 [macro]

    rule #rangeUInt(32, X) => #range(minUInt32 <= X <= maxUInt32) [macro]

    // masking first 32 bits
    rule 115792089210356248756420345214020892766250353992003419616917011526809519390720 &Int #asWord(WS)
      => #asWord(WS [ 0 .. 4 ] ++ #buf(28, 0))
    requires #sizeWordStack(WS) ==Int 32

    rule #asWord(WS) &Int 115792089210356248756420345214020892766250353992003419616917011526809519390720
      => #asWord(WS [ 0 .. 4 ] ++ #buf(28, 0))
    requires #sizeWordStack(WS) ==Int 32

    rule N ==K #asWord(WS ++ ZP)
      => N /Int (2 ^Int (#sizeWordStack(ZP) *Int 8)) ==K #asWord(WS)
    requires N %Int (2 ^Int (#sizeWordStack(ZP) *Int 8)) ==Int 0
     andBool ZP ==K #buf(#sizeWordStack(ZP), 0)
     andBool #sizeWordStack(WS ++ ZP) ==Int 32
     andBool #rangeUInt(256, N)
     andBool #isConcrete(N)

    rule bool2Word(B) => #if B #then 1 #else 0 #fi

    // translation of the lemmas over bool2Word

    rule #if A #then 1 #else 0 #fi |Int #if B #then 1 #else 0 #fi => #if A  orBool B #then 1 #else 0 #fi
    rule #if A #then 1 #else 0 #fi &Int #if B #then 1 #else 0 #fi => #if A andBool B #then 1 #else 0 #fi

    rule 1 |Int #if B #then 1 #else 0 #fi => 1
    rule 1 &Int #if B #then 1 #else 0 #fi => #if B #then 1 #else 0 #fi

    rule #if B #then 1 #else 0 #fi |Int 1 => 1
    rule #if B #then 1 #else 0 #fi &Int 1 => #if B #then 1 #else 0 #fi

    rule #if A #then 1 #else 0 #fi  ==K 0 => notBool(A)
    rule #if A #then 1 #else 0 #fi  ==K 1 => A
    rule #if A #then 1 #else 0 #fi =/=K 0 => A
    rule #if A #then 1 #else 0 #fi =/=K 1 => notBool(A)



    // for [revert-invalid_function_identifier-0_4]

    rule #bufSeg(#buf(N, 0), 0, M) => #buf(M, 0) requires 0 <Int M andBool M <Int N

    // for [deposit-init-calldata]

    rule #take(X, #take(Y, WS)) => #take(X, WS)
      requires X <=Int Y

    // for addition overflow check

    rule X +Int Y <Int X => false requires X >=Int 0 andBool Y >=Int 0 // #range(0 <= (X +Int Y) < pow256)

    rule 0 <=Int X /Int Y             => true requires #range(0 <= X < pow256) andBool #range(0 <= Y < pow256)
    rule         X /Int Y <Int pow256 => true requires #range(0 <= X < pow256) andBool #range(0 <= Y < pow256)

endmodule
