const hre = require("hardhat");

const main = async () => {
  await hre.run("verify:verify", {
    address: "0x577987e20cd8AE19fe1FbA2aC9a34F638AAf8F41",
    constructorArguments: ["0x6eCB3F60bC704d86512e5C2a031Ec322B64CE9F1", 34614698, "47", "5"],
  });
  await hre.run("verify:verify", {
    address: "0x6eCB3F60bC704d86512e5C2a031Ec322B64CE9F1",
    constructorArguments: [],
  });
};

main().catch(console.error);
