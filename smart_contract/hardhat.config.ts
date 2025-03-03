require('@nomicfoundation/hardhat-toolbox');
require('@nomicfoundation/hardhat-verify');
require('dotenv').config();
require('solidity-docgen');

const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL || '';
const PK_BASE_SEPOLIA =
  process.env.PK_BASE_SEPOLIA || process.env.PK_BASE_SEPOLIA_TEST;

module.exports = {
  solidity: '0.8.20',
  networks: {
    base_sepolia: {
      url: SEPOLIA_RPC_URL,
      accounts: [`0x${PK_BASE_SEPOLIA}`],
      chainId: 84532,
    },
    localhost: {
      url: 'http://127.0.0.1:8545',
      chainId: 31337,
    },
  },
  etherscan: {
    apiKey: process.env.BASESCAN_API_KEY,
  },
  sourcify: {
    enabled: true,
  },
};
