const vendingMachine = artifacts.require("VendingMachine");

module.exports = function (deployer) {
  deployer.deploy(vendingMachine);
};
