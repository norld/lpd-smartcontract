const hre = require("hardhat");

const main = async () => {
  await hre.run("verify:verify", {
    address: "0x0e934C782D450655f28d314026Be81297A39658E",
    constructorArguments: ["Binance USD", "BUSD", 18, ethers.utils.parseEther("10000000000000000"), "1"],
  });
  await hre.run("verify:verify", {
    address: "0xC6A2c41DBB2245D6E6c8C23951A2683Ba9bF31F0",
    constructorArguments: [],
  });
};

main().catch(console.error);
