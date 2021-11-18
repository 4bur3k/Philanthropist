pragma solidity >=0.4.22 <0.9.0;

contract TokenERC20 {
    address token;

    string public constant token_name = "Charitoken";

    string public constant token_symbol = "CHRT";


    uint8 public constant token_decimals = 18;

    // Общее количество токенов
    uint256 private token_totalSupply = 1000000;

    // Маппинг балансов адресов
    mapping (address => uint) public balances;

    /* Первый ключ — адрес на снятие с которого предоставляется разрешение. 
    Второй ключ — пользователь, которому предоставляется разрешение. */
    mapping (address => mapping (address => uint)) allowed;

    // Проверям чтобы у пользователя хватало денег и значение _value не было отрицательным
    modifier notEnoughMoney(address _from, uint _value){
        require(
            _value >= 0,
            "Value is negative"
        );

        require(
            _value <= balanceOf(_from),
            "Your don't have enough money :("
        );
        _;
    }

    //Проверяем разрешение на перевод средств у кошельков
    modifier permission(address _from, address _to, uint256 _value) {
        require(
            allowed[_from][token] >= _value,
            "You don't have permission to use this function or value is too big"
        );
        _;
    }


    constructor() public {
        balances[msg.sender] = token_totalSupply;
        token = msg.sender;
    }

    // OPTIONAL - This method can be used to improve usability, but interfaces and other contracts MUST NOT expect these values to be present.
    function name() public view returns (string memory) {
        return token_name;
    }

    // OPTIONAL - This method can be used to improve usability, but interfaces and other contracts MUST NOT expect these values to be present.
    function symbol() public view returns (string memory) {
        return token_name;
    }

    // OPTIONAL - This method can be used to improve usability, but interfaces and other contracts MUST NOT expect these values to be present.
    function decimals() public view returns (uint8) {
        return token_decimals;
    }

    // Returns the total token supply.
    function totalSupply() public view returns (uint256) {
        return token_totalSupply;
    }

    // Returns the account balance of another account with address _owner.
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    // msg.sender отправляет _value токенов на адрес _to
    function transfer(address _to, uint256 _value) public notEnoughMoney(msg.sender, _value) returns (bool success) {
        balances[_to] += _value;
        balances[msg.sender] -= _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public notEnoughMoney(_from, _value) permission(_from, _to, _value) returns (bool success) {
        uint previousBalances = balanceOf(_from) + balanceOf(_to);
        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][token] -= _value;
        emit Transfer(_from, _to, _value);
        assert(previousBalances == balanceOf(_from) + balanceOf(_to));
        return true;
    }

    // Разрешает пользователю _spender снимать с вашего счета (точнее со счета вызвавшего функцию пользователя) средства не более чем _value.
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Возвращает сколько монет со своего счета разрешил снимать пользователь _owner пользователю _spender.
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint _value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);
}