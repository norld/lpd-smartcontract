const hre = require("hardhat");

const main = async () => {
  await hre.run("verify:verify", {
    address: "0xAb2826EeaE98a37e7F03c75f3a62135a87db4aB3",
    constructorArguments: ["0xdEd1E1c245035d4777d6625ddb391a030a9af504"],
  });
  // await hre.run("verify:verify", {
  //   address: "0x6eCB3F60bC704d86512e5C2a031Ec322B64CE9F1",
  //   constructorArguments: [],
  // });
};

main().catch(console.error);
