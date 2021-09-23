const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Kekw", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Kekw = await ethers.getContractFactory("Kekw");
    const kekw = await Kekw.deploy("KEKW", "kek");
    await kekw.deployed();

    //expect(await kekw.greet()).to.equal("Hello, world!");

    const setBaseURI = await kekw.setBaseURI("this_test_URI");

    // wait until the transaction is mined
    await setBaseURI.wait();

    console.log(await kekw.getBaseURI());
    expect(await kekw.getBaseURI()).to.equal("this_test_URI");
  });
});
