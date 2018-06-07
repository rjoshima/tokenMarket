const HDWalletProvider = require("truffle-hdwallet-provider");
const mnemonic = process.env.ROPSTEN_MNEMONIC;
const accessToken = process.env.INFURA_ACCESS_TOKEN;

// below word is truffle mnemonic, and you use it once you eneter "trrufle develop"(this mode work on localhost:9545)
// candy maple cake sugar pudding cream honey rich smooth crumble sweet treat
module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // match any network
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(
          mnemonic,
          "https://ropsten.infura.io/" + accessToken
        );
      },
      network_id: 3,
      gas: 4612388
    }
  }
};
// module.exports = {
//     networks: {
//       development: {
//         host: "localhost",
//         port: 8545,
//         network_id: "*" // Match any network id
//       }
//     }
//   };

