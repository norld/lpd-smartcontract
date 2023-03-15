// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const Pair = await hre.ethers.getContractFactory("LaunchpadInitializable");
  const pair = await Pair.deploy();
  await pair.deployed();
  console.log("LaunchpadInitiable deployed to:", pair.address);

  const Factory = await hre.ethers.getContractFactory("LaunchpadFactory");
  const factoryArgs = {
    base: pair.address,
  };
  const factory = await Factory.deploy(...Object.values(factoryArgs));
  await factory.deployed();
  console.log("LaunchpadFactory deployed to:", factory.address);

  if (hre.network.config.chainId !== undefined) {
    console.log("Waiting block confirm...");
    setTimeout(async () => {
      // console.log("Verifying Implementation Contract");
      // await hre.run("verify:verify", {
      //   address: pair.address,
      //   constructorArguments: [],
      // });

      console.log("Verifying Factory Contract");
      await hre.run("verify:verify", {
        address: factory.address,
        constructorArguments: [pair.address],
      });
    }, 50000);
  } else {
    console.log("Skip because local deploy");
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
