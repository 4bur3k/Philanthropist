pragma solidity >=0.4.22 <0.9.0;
import "./Token.sol";

contract Philanthropist {
    TokenERC20 public token;
    //address philanthropist = msg.sender;
    // Логично было бы оставить один адресс кошелька, адресс вызывающего, но для возмрожности брат адресса из Ganache закоментим
    mapping (string => address) public CharityWallet;


    constructor(address _address) public{
        token = TokenERC20(_address);
    }

    function myBalance(address _address) public returns(uint){
        emit Balance("Philanthropist Balance is", token.balOf(_address));
       return token.balOf(_address);
    }

    function getAddress(string memory name) public view returns(address){
        return CharityWallet[name];
    }

    function CreateNewCharityWallet(string memory name, address _address) public{
        CharityWallet[name] = _address;
    }

    function MakeCharity(address philanthropist, string memory name, uint value) public{
        token.transferFrom(philanthropist, CharityWallet[name], value);
        emit NewCharity("Complete!", value);
    }

    event Balance(string line, uint balance);
    event NewCharity(string line, uint value);
}
