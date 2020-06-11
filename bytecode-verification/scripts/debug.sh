  date

  export K_OPTS=-Xmx24g

  KPROVE_OPTS=

# KPROVE_OPTS+=" --branching-allowed 0"
# KPROVE_OPTS+=" --branching-allowed 1"
# KPROVE_OPTS+=" --boundary-cells k,pc"
# KPROVE_OPTS+=" --boundary-cells k"
# KPROVE_OPTS+=" --boundary-cells pc"
  KPROVE_OPTS+=" --log"
# KPROVE_OPTS+=" --log-basic"
# KPROVE_OPTS+=" --log-rules"
  KPROVE_OPTS+=" --log-success"
  KPROVE_OPTS+=" --log-success-pc-diff"
# KPROVE_OPTS+=" --log-func-eval"
  KPROVE_OPTS+=" --log-cells k"
  KPROVE_OPTS+=",pc"
  KPROVE_OPTS+=",wordStack"
# KPROVE_OPTS+=",localMem"
  KPROVE_OPTS+=",output"
  KPROVE_OPTS+=",gas"
  KPROVE_OPTS+=",callGas"
  KPROVE_OPTS+=",memoryUsed"
  KPROVE_OPTS+=",statusCode"
  KPROVE_OPTS+=",callData"
  KPROVE_OPTS+=",log"
  KPROVE_OPTS+=",refund"
# KPROVE_OPTS+=",accounts"
  KPROVE_OPTS+=",#pc,#result"
# KPROVE_OPTS+=" --debug-z3-queries"

# KPROVE_OPTS+=" --log-rules"
# KPROVE_OPTS+=" --debug-z3-queries"

# export KPROVE_OPTS

  make clean
  make specs
  make verify

  date
