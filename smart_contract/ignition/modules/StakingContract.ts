import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';

module.exports = buildModule('StakingContract', (m) => {
  const stakingToken: string = '0x1a056ee38fd77Bdd93Cd010b8bD278457f3aA636';
  const StakingContract = m.contract('StakingContract', [stakingToken]);

  return { StakingContract };
});
