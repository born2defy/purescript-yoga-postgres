export const poisonRollbackImpl = (transaction) => {
  const reserved = transaction._reserved;
  const rollbackFailure = () => {
    throw new Error("rollback finalizer failed");
  };
  rollbackFailure.release = () => reserved.release();
  transaction._reserved = rollbackFailure;
};
