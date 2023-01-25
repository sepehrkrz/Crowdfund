const Crowdfund = artifacts.require("Crowdfund");

contract("Crowdfund", accounts => {
    let crowdfund;
    let owner = accounts[0];
    let contributor1 = accounts[1];
    let totalSupply = 100;
    let fundingGoal = 30;
    let contribution1 = 20;
    let contribution2 = 30;

    beforeEach(async () => {
        crowdfund = await Crowdfund.new("Test Token", "TST", 18, totalSupply, fundingGoal, {from: owner});
        await crowdfund.transfer(contributor1, 35, {from: owner});
    });
    
    it("should set the funding goal correctly", async () => {
        let goal = await crowdfund.fundingGoal();
        assert.equal(goal.toNumber(), fundingGoal, "Funding goal is not set correctly");
    });
    
    it("should allow a contributor to contribute and transfer tokens", async () => {
        await crowdfund.contribute({from: contributor1, value: contribution1});
        let balance = await crowdfund.balanceOf(contributor1);
        assert.equal(balance.toNumber(), 15, "Contribution not transferred to contributor1");
    });
    
    it("should start the refund period when the funding goal is not reached", async () => {
        let refundPeriod = await crowdfund.refundPeriod();
        assert.isFalse(refundPeriod, "Refund period has already started");
        await crowdfund.contribute({from: contributor1, value: contribution1});
        await crowdfund.startRefundPeriod({from: owner});
        refundPeriod = await crowdfund.refundPeriod();
        assert.isTrue(refundPeriod, "Refund period not started");
    });
    

    it("should refund a contributor when the refund period has started", async () => {
        let refundPeriod = await crowdfund.refundPeriod();
        assert.isFalse(refundPeriod, "Refund period has already started");
        await crowdfund.contribute({from: contributor1, value: contribution1});
        await crowdfund.startRefundPeriod({from: owner});
        let refund = await crowdfund.refund(contributor1, {from: contributor1});
        let balance = await crowdfund.balanceOf(contributor1);
        assert.equal(balance.toNumber(), 0, "Contribution not refunded to contributor1");
        try {
        await crowdfund.refund(contributor1, {from: accounts[3]});
        assert.fail("Refund can be made by non-contributor");
        } catch (e) {
        assert.include(e.message, "revert");
        }
        try {
        await crowdfund.refund(contributor1, {from: contributor1});
        assert.fail("Refund can be made twice");
        } catch (e) {
        assert.include(e.message, "revert");
        }
        });
        });
