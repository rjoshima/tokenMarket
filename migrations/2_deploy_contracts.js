var createToken = artifacts.require("./createToken.sol");

module.exports = function(deployer) {
  deployer.deploy(createToken, "TokenMarket", "TM", {gas: 4600000})
};