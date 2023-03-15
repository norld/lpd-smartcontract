const { ethers } = require("hardhat");

const main = async () => {
  try {
    const ERC20 = await ethers.getContractFactory("ERC20Std");
    const erc20Args1 = {
      name_: "LPD Start",
      symbol_: "LPDS",
      decimals_: 18,
      totalSupply_: ethers.utils.parseEther("10000000"),
      version_: "1",
    };

    const erc20Args2 = {
      name_: "LPD Process",
      symbol_: "LPDP",
      decimals_: 18,
      totalSupply_: ethers.utils.parseEther("10000000"),
      version_: "1",
    };

    const erc20Args3 = {
      name_: "LPD End",
      symbol_: "LPDE",
      decimals_: 18,
      totalSupply_: ethers.utils.parseEther("10000000"),
      version_: "1",
    };

    const erc20Args4 = {
      name_: "LPD Test",
      symbol_: "LPDT",
      decimals_: 18,
      totalSupply_: ethers.utils.parseEther("10000000"),
      version_: "1",
    };

    const erc20ArgsBusd = {
      name_: "Binance USD",
      symbol_: "BUSD",
      decimals_: 18,
      totalSupply_: ethers.utils.parseEther("10000000000000000"),
      version_: "1",
    };

    const deployedErc20Start = await ERC20.deploy(...Object.values(erc20Args1));
    await deployedErc20Start.deployed();

    const deployedErc20Process = await ERC20.deploy(...Object.values(erc20Args2));
    await deployedErc20Process.deployed();

    const deployedErc20End = await ERC20.deploy(...Object.values(erc20Args3));
    await deployedErc20End.deployed();

    const deployedErc20Test = await ERC20.deploy(...Object.values(erc20Args4));
    await deployedErc20Test.deployed();

    const deployedErc20Busd = await ERC20.deploy(...Object.values(erc20ArgsBusd));
    await deployedErc20Busd.deployed();

    console.log({
      start: deployedErc20Start.address,
      process: deployedErc20Process.address,
      end: deployedErc20End.address,
      test: deployedErc20Test.address,
      busd: deployedErc20Busd.address,
    });
  } catch (error) {
    throw new Error(error);
  }
};

main().catch(console.error);
