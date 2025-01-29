// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Token {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) private balances;
    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply;
        balances[owner] = _initialSupply;
        emit Transfer(address(0), owner, _initialSupply);
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Neispravna ciljna adresa.");
        require(balances[msg.sender] >= amount, "Nedovoljno tokena.");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function mint(uint256 amount) public {
        require(msg.sender == owner, "Samo vlasnik moze kreirati nove tokene.");
        require(amount > 0, "Iznos mora biti veci od 0.");
        balances[owner] += amount;
        totalSupply += amount;
        emit Transfer(address(0), owner, amount);
    }

    function burn(uint256 amount) public {
        require(msg.sender == owner, "Samo vlasnik moze unistiti tokene.");
        require(balances[owner] >= amount, "Nedovoljno tokena.");
        balances[owner] -= amount;
        totalSupply -= amount;
        emit Transfer(owner, address(0), amount);
    }
}