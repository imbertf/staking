const { buildModule } = require('@nomicfoundation/hardhat-ignition/modules');

module.exports = buildModule('PPOTokenContract', (m) => {
  const PPOTokenContract = m.contract('PPOTokenContract');

  return { PPOTokenContract };
});
