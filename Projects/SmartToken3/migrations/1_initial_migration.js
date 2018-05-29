var Migrations = artifacts.require("./Migrations.sol");
var EnergyManager = artifacts.require("./EnergyManager3.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(EnergyManager);
};
