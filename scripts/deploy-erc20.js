const { ethers } = require("hardhat");

const main = async () => {
  try {
    const ERC20 = await ethers.getContractFactory("ERC20Std");
    const erc20Args3 = {
      name_: "NVP UCUP",
      symbol_: "NVPU",
      decimals_: 18,
      totalSupply_: ethers.utils.parseEther("10000000"),
      version_: "1",
    };

    const deployedErc20 = await ERC20.deploy(...Object.values(erc20Args3));
    await deployedErc20.deployed();

    console.log({
      ucup: deployedErc20.address,
    });
  } catch (error) {
    throw new Error(error);
  }
};

main().catch(console.error);
