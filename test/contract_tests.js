require("mocha")

const { assert, expect } = require('chai')

const Philanthropist = artifacts.require("Philanthropist");
const TokenERC20 = artifacts.require('TokenERC20')
const catchRevert = require("../exceptions.js").catchRevert;

contract("Philanthropist", (accounts) =>{
    let instance
    let instanceToken
    const adds = [accounts[1], accounts[2]]
    const donator = accounts[0]

    before(async () => {
        instance = await Philanthropist.deployed()
        instanceToken = await TokenERC20.deployed()
        instance.CreateNewCharityWallet('madhouse', adds[0])
        instance.CreateNewCharityWallet('homeless', adds[1])
    })

    describe("When contract deployed first time", async () => {
        it("assigns total suply to donator", async () => {
            const balance = await instanceToken.balanceOf(donator)
            assert.equal(balance.valueOf(), 1000000)
        })
    })

    describe("Getting addresses charities", () => {
        it("Returns address of madhouse", async () => {
            const add = await instance.getAddress('madhouse')
            assert.equal(add.valueOf(), adds[0])
        })

        it("Returns address of homeless", async () => {
            const add = await instance.getStreamerAddress('homeless')
            assert.equal(add.valueOf(), adds[1])
        })
    })

    describe("Donate amount of money to charities", () => {
        before(async () => {
            await instanceToken.approve(donator, 10000)
            await instance.CreateNewCharityWallet(donator, 'madhouse', 100)
            await instance.CreateNewCharityWallet(donator, 'homeless', 150)
        })

        it("Returns amount of money we've donated to madhouse", async () => {
            const donated = await instanceToken.balanceOf(adds[0])
            assert.equal(donated.valueOf(), 100)
        })

        it("Returns amount of money we've donated to homeless", async () => {
            const donated = await instanceToken.balanceOf(adds[1])
            assert.equal(donated.valueOf(), 150)
        })
    })

    describe("Variations of donate to madhouse", () => {
        before(async () => {
            instance.CreateNewCharityWallet('madhouse', adds[0])
            instance.CreateNewCharityWallet('homeless', adds[1])
        })

        context("When we approve spending money", () => {
            context("When we have enough money", ()=>{
                let balance;
                let madhouseDonated;

                before(async () => {
                    balance = await instanceToken.balanceOf(donator);
                    madhouseDonated = await instanceToken.balanceOf(adds[0])
                    await instanceToken.approve(donator, 30)
                    await instance.MakeCharity(donator, 'madhouse', 20)
                })

                it("Transfers money to madhouse", async () => {
                    const newBalance = await instanceToken.balanceOf(donator)
                    const newDon = await instanceToken.balanceOf(adds[0])
                    assert.equal(balance.valueOf(), parseInt(newBalance.valueOf()) + 20)
                    assert.equal(madhouseDonated.valueOf(), parseInt(newDon.valueOf()) - 20)
                })
            })

            context("When we don't have enough money", () => {
                let balance;
                let petCharity;

                before(async () => {
                    balance = await instanceToken.balanceOf(investor);
                    petCharity = await instanceToken.balanceOf(adds[0])
                    await instanceToken.approve(investor, 1000)
                })

                it("returns error", async () => {
                    catchRevert(instance.MakeCharity(donator, 'madhouse', 1000000))
                })
            })
        })

        context("When we don't approve spending money", () => {
            it("return error", async () => {
                catchRevert(instance.MakeCharity(donator, 'madhouse', 100))
            })
        })
    })
})