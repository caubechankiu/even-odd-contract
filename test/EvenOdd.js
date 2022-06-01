const EvenOdd = artifacts.require("EvenOdd");

contract("EvenOdd", (accounts) => {
  //1. initialize `alice` and `bob`
  it("Bet", async () => { //2 & 3. Replace the first parameter and make the callback async
    const evenOdd = await EvenOdd.new();
    const door = Math.round(Math.random());
    const value = Math.floor(Math.random() * 10);
    const betResult = await evenOdd.bet(door, { from: accounts[0], value });
    console.log(betResult.logs);
    assert.equal(betResult.receipt.status, true);
    const totalBet = await evenOdd.getTotalBet();
    assert.equal(totalBet[door].words[0], value);
  })
})
