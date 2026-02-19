// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

contract OmoboiToken{
    string name = "OmoboiToken";
    string symbol ="OMO";
    uint8 decimals = 8;
    // Total supply
    uint256 public totalSupply;

    // balanceOf Function
    mapping(address => uint256) public balanceOf;

    // Allowance Function
    mapping(address => mapping(address=> uint256)) public allowance;

    // My Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // To create a token i need to mint initial supply
    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * (10 ** decimals);
        balanceOf[msg.sender] = totalSupply;
    }
    //  Move token from sender to receiver address
    function transfer(address _to, uint256 _value) public returns (bool){

        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        balanceOf[msg.sender] = balanceOf[msg.sender] - _value;

        balanceOf[_to] = balanceOf[_to] + _value;

        emit Transfer(msg.sender, _to, _value);
        return true;

    }
    // Allow someone else to spend tokens
    function approve(address _spender, uint256 _value) public returns (bool){
        allowance[msg.sender] [_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // 
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )public returns (bool){

        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >=_value, "Allowance exceeded");

        balanceOf[_from] = balanceOf[_from] - _value;
        balanceOf[_to] = balanceOf[_to] + _value;
        allowance[_from][msg.sender] = allowance[_from][msg.sender] - _value;

        emit Transfer(_from, _to, _value);
        return true;
    }


}