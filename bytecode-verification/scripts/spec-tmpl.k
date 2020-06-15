// {RULENAME} {COMMENT}
rule
<kevm>
  <k> {K} </k>
  <mode> NORMAL </mode>
  <schedule> {SCHEDULE} </schedule>
  <ethereum>
    <evm>
      <output> {OUTPUT} </output>
      <statusCode> {STATUS_CODE} </statusCode>
      <endPC> _ => ?_ </endPC>
      <touchedAccounts> _ => ?_ </touchedAccounts>
      <callState>
        <program> #parseByteStack({CODE}) </program>
        <jumpDests> #computeValidJumpDests(#parseByteStack({CODE})) </jumpDests>
        <id> {THIS} </id> // this
        <caller> {MSG_SENDER} </caller> // msg.sender
        <callData> {CALL_DATA} </callData> // msg.data
        <callValue> {CALL_VALUE} </callValue> // msg.value
        <wordStack> {WORD_STACK} </wordStack>
        <localMem> {LOCAL_MEM} </localMem>
        <pc> {PC} </pc>
        <gas> {GAS} </gas>
        <memoryUsed> {MEMORY_USED} </memoryUsed>
        <callGas> _ => ?_ </callGas>
        <static> false </static> // NOTE: non-static call
        <callDepth> {CALL_DEPTH} </callDepth>
      </callState>
      <substate>
        <log> {LOG} </log>
        <refund> {REFUND} </refund>
        ...
      </substate>
      ...
    </evm>
    <network>
      <activeAccounts> {ACTIVE_ACCOUNTS} SetItem({THIS}) SetItem(2) _:Set </activeAccounts>
      <accounts>
        <account>
          <acctID> {THIS} </acctID>
          <balance> {BALANCE} </balance>
          <code> #parseByteStack({CODE}) </code>
          <storage> {STORAGE} </storage>
          <origStorage> {ORIG_STORAGE} </origStorage>
          <nonce> {NONCE} </nonce>
        </account>
        <account>
          // precompiled account for SHA256
          <acctID> 2 </acctID>
          <balance> PRECOMPILED_SHA256_BALANCE </balance>
          <code> .WordStack </code>
          <storage> .Map </storage>
          <origStorage> .Map </origStorage>
          <nonce> 0 </nonce>
        </account>
        {ACCOUNTS}
        ...
      </accounts>
      ...
    </network>
  </ethereum>
  ...
</kevm>
requires true
andBool #rangeUInt(256, PRECOMPILED_SHA256_BALANCE)
{REQUIRES}
ensures true
{ENSURES}
{ATTRIBUTE}
