const Philanthropist = artifacts.require("Philanthropist");
const TokenERC20 = artifacts.require("TokenERC20");

module.exports = function (deployer) {
    deployer.deploy(TokenERC20)
        .then((Token) =>{
            return deployer.deploy(Philanthropist, Token.address);
        });
};