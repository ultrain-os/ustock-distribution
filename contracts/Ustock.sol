pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';


contract Ustock is StandardToken, Ownable {
    string public name = "UGas";
    string public symbol = "UGS";
    uint256 public decimals = 18;
    uint256 public INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));                     // total supply
    uint256 public MINING_RESERVE = 1000000000 * 0.5 * (10 ** uint256(decimals));               // amount reserved for mining

    mapping(address => string) public  keys;                                                    // map<eth address,  ultrain keys>
    bool public closed = false;                                                                 // whether close contract

    event Close();
    event Open();

    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[0xb1] = MINING_RESERVE;
        balances[msg.sender] = INITIAL_SUPPLY - MINING_RESERVE;

        emit Transfer(0x0, 0xb1, MINING_RESERVE);
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY - MINING_RESERVE);
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function() public payable {
        revert();
    }

    function transfer(address _to, uint _value) whenOpen public returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) whenOpen public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    // public key generated by ultrain
    function register(string key) whenOpen {
        assert(bytes(key).length <= 64);
        keys[msg.sender] = key;
    }

    function close() onlyOwner whenOpen public {
        closed = true;
        emit Close();
    }

    function open() onlyOwner whenClosed public {
        closed = false;
        emit Open();
    }

    modifier whenOpen() {
        require(!closed);
        _;
    }

    modifier whenClosed() {
        require(closed);
        _;
    }

}
