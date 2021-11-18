pragma solidity >=0.4.25 < 0.9.0;
import  "../contracts/Philanthropist.sol";
import "../contracts/Token.sol";
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";


contract cnt_tests {
    function cnt_tests() public{
    TokenERC20 token = ERC20Token(DeployedAddresses.TokenERC20());

    uint expected = 1000000;

    Assert.equal(token.balanceOf(tx.origin), expected, "Owner should have 1000000 Coin initially");
    }

}
