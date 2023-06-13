const { ethers } = require("hardhat");
const { expect } = require("chai");
let shamir;
describe("Threshold cryptography smart contract", function () {

  beforeEach(async function () {
    const Shamirx = await ethers.getContractFactory("Shamir");
    shamir = await Shamirx.deploy();
    await shamir.deployed();
  });


  it("should calculate Y correctly", async function () {
    const x = 2;
    const poly = [1, 2, 3, 4]; // Sample polynomial coefficients
    const expectedY = 49;

    const result = await shamir.calculateY(x, poly);
    expect(result).to.equal(expectedY);
  });

  it("should generate shares correctly", async function () {
    const S = 65; // Secret value
    const N = 8; // Number of points
    const K = 5; // Degree of polynomial

    const result = await shamir.generateShares(S, N, K);
    console.log("Shares generated: ");
    for(let i=0;i<N;i++)
    {
      console.log(result[i].x, result[i].y);
    }
  });

  it("should reconstruct secret correctly", async function () {
    
    const S = 8878244378; // Secret value
    const N = 50; // Number of points
    const K = 34; // Threshold

    const result = await shamir.generateShares(S, N, K);
    const t1=[];
    const t2=[];
    
    for(let i=0;i<K;i++)  //providing first K shares to the reconstruct function
    {
        t1[i]=result[i].x;
        t2[i]=result[i].y;
    }
    const sz=t1.length;
    const reconstructedSecret = await shamir.reconstructSecret(t1,t2,sz,K);
    expect(reconstructedSecret).to.equal(S);

  });


  it("should compute gcd correctly", async function () {
    const a = 24;
    const b = 36;
    const expectedGCD = 12;

    const result = await shamir.gcd(a, b);
    expect(result).to.equal(expectedGCD);
  });

  it("should add fractions correctly", async function () {
    const f1 = { num: 3, den: 4 };
    const f2 = { num: 2, den: 5 };
    const expectedResult = { num: 3 * 5 + 4 * 2, den: 4 * 5 };

    const result = await shamir.add(f1, f2);
    expect(result.num).to.equal(expectedResult.num);
    expect(result.den).to.equal(expectedResult.den);
  });

  it("should reduce fractions correctly", async function () {
    const f = { num: 8, den: 12 };
    const expectedReduced = { num: 2, den: 3 };

    const result = await shamir.reduceFraction(f);
    expect(result.num).to.equal(expectedReduced.num);
    expect(result.den).to.equal(expectedReduced.den);
  });
});