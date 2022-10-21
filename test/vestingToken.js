const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("vesting token test", function(){
    let vestContract;
    let admin;
    let user;

    before( async() => {
        let accounts = await ethers.getSigners()
        admin = accounts[0]
        user = accounts[1]

        let VestContract = await ethers.getContractFactory("vestingToken");
        vestContract = await VestContract.deploy();

        console.log("vest token address",vestContract.address);
    })

    it("add address", async() => {
        await network.provider.send("evm_increaseTime", [61]); // fast forward chain by 1 min 
        await network.provider.send("evm_mine");
        let claimBalance = await vestContract.claimableBalance();
        console.log("claimBalance",claimBalance.toString());
        let tx = await vestContract.addAddress(user.address);
        await tx.wait();
        let balance = await vestContract.balanceOf(admin.address);
        console.log("balance",balance.toString());
        expect(balance.toString()).to.equal(claimBalance.toString());
    })

    it("claim", async() => {
        await network.provider.send("evm_increaseTime", [121]); // fast forward chain by 2 min 
        await network.provider.send("evm_mine");
        let claimBalance = await vestContract.claimableBalance();
        console.log("claimBalance",claimBalance.toString());
        let initialBal = await vestContract.balanceOf(admin.address);
        console.log("initial Balance",initialBal.toString());
        let tx = await vestContract.claim();
        await tx.wait();
        let balance = await vestContract.balanceOf(admin.address);
        console.log("balance",balance.toString());
        expect(balance.toString()).to.equal(initialBal.add(claimBalance).toString());
    }
    )
})