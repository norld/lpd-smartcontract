require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-web3");

/** @type import('hardhat/config').HardhatUserConfig */
const config = {
  solidity: {
    version: "0.8.12",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    localhost: {
      url: "http://localhost:8545",
    },
    testnet: {
      url: "https://endpoints.omniatech.io/v1/bsc/testnet/b04acd98f5ee4f8d9a19fe2bdf262639",
      accounts: [
        `e35576866085d08f284772511aaba21f84fc92a831ae13cc0f3b97644df3e583`,
        `01526ca693def77ba68e5ca55bfc77634b121850bafc510f9b3aff3f828e61d7`,
        `321fd422e8f13e2f73dc428348ec01a8cc1c267ae76214405f4650ebe5b27d3f`,
      ],
      chainId: 97,
    },
    mumbai: {
      url: "https://polygon-testnet.public.blastapi.io",
      accounts: [
        `e35576866085d08f284772511aaba21f84fc92a831ae13cc0f3b97644df3e583`,
        `01526ca693def77ba68e5ca55bfc77634b121850bafc510f9b3aff3f828e61d7`,
        `321fd422e8f13e2f73dc428348ec01a8cc1c267ae76214405f4650ebe5b27d3f`,
      ],
      chainId: 80001,
    },
    bsc: {
      url: "https://bsctestapi.terminet.io/rpc",
      accounts: [
        `e35576866085d08f284772511aaba21f84fc92a831ae13cc0f3b97644df3e583`,
        `01526ca693def77ba68e5ca55bfc77634b121850bafc510f9b3aff3f828e61d7`,
        `321fd422e8f13e2f73dc428348ec01a8cc1c267ae76214405f4650ebe5b27d3f`,
      ],
      chainId: 97,
    },
    mainnet: {
      url: `https://poly-rpc.gateway.pokt.network`,
      accounts: [
        `e35576866085d08f284772511aaba21f84fc92a831ae13cc0f3b97644df3e583`,
        `01526ca693def77ba68e5ca55bfc77634b121850bafc510f9b3aff3f828e61d7`,
        `321fd422e8f13e2f73dc428348ec01a8cc1c267ae76214405f4650ebe5b27d3f`,
      ],
      chainId: 137,
    },
  },
  defaultNetwork: "hardhat",
  etherscan: {
    // apiKey: "HESBY8UDJMYMV6BWZ3JPTUDA2T8P6FBRIP", //plygonScan
    apiKey: "TKK24DX47RUPP23WM9SZS2IP7ZHT8I83NI", //bscScan
  },
};

module.exports = config;
