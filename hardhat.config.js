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
      url: "https://bsc-testnet.public.blastapi.io",
      accounts: [
        `8a8891ceaa14be0921b4dca62e270c1cf8a1e9f82081dde0477bbdf3405bc16c`,
        `01526ca693def77ba68e5ca55bfc77634b121850bafc510f9b3aff3f828e61d7`,
        `321fd422e8f13e2f73dc428348ec01a8cc1c267ae76214405f4650ebe5b27d3f`,
      ],
      chainId: 97,
    },
    mumbai: {
      url: "https://polygon-testnet.public.blastapi.io",
      accounts: [
        `8a8891ceaa14be0921b4dca62e270c1cf8a1e9f82081dde0477bbdf3405bc16c`,
        `01526ca693def77ba68e5ca55bfc77634b121850bafc510f9b3aff3f828e61d7`,
        `321fd422e8f13e2f73dc428348ec01a8cc1c267ae76214405f4650ebe5b27d3f`,
      ],
      chainId: 80001,
    },
    bsc: {
      url: "https://bsctestapi.terminet.io/rpc",
      accounts: [
        `8a8891ceaa14be0921b4dca62e270c1cf8a1e9f82081dde0477bbdf3405bc16c`,
        `01526ca693def77ba68e5ca55bfc77634b121850bafc510f9b3aff3f828e61d7`,
        `321fd422e8f13e2f73dc428348ec01a8cc1c267ae76214405f4650ebe5b27d3f`,
      ],
      chainId: 97,
    },
    mainnet: {
      url: `https://poly-rpc.gateway.pokt.network`,
      accounts: [
        `8a8891ceaa14be0921b4dca62e270c1cf8a1e9f82081dde0477bbdf3405bc16c`,
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

1678868176;
1000;
