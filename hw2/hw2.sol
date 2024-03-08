// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract hzh is ERC20 {
    address public censor;
    address public master;
    mapping (address => bool) public blacklist;

    // initial function
    constructor() ERC20("312551117", "HZH") {
        censor = msg.sender;
        master = msg.sender;
        _mint(msg.sender, 100000000 * 10 ** uint(decimals())); //initialize the money of contract creator
    }
    // only master can use
    modifier onlyMaster() {
        require(master == msg.sender, "Only master can call this function");
        _;
    }
    //only censor can use
    modifier onlyCensor() {
        require(censor == msg.sender, "Only censor can call this function");
        _;
    }

    // if the address is in the blacklist, then revert
    modifier notBlacklisted(address _target) {
        if(blacklist[_target]){
            revert();
        }
        _;
    }

    //use modifier function to set the permission 
    function changeMaster(address newMaster) onlyMaster external {
        master = newMaster;
    }
    function changeCensor(address newCensor) onlyCensor external {
        censor = newCensor;
    }
    // because i don't want to set a extra modifier for master and censor, i used require and two condition
    function setBlacklist(address target, bool blacklisted) external {
        require(msg.sender == censor || msg.sender == master, "Only censor or master can call this function");
        blacklist[target] = blacklisted;
    }
    // if the address is in blacklist, then revert
    function transfer(address to, uint256 amount) public override notBlacklisted(to) returns (bool) {
        return super.transfer(to, amount);
    }
    // if the address is in blacklist, then revert
    function transferFrom(address from, address to, uint256 amount) public override notBlacklisted(from) notBlacklisted(to) returns (bool) {
        return super.transferFrom(from, to, amount);
    }
    // only master
    function clawBack(address target, uint256 amount) external onlyMaster {
        _transfer(target, master, amount);
    }
    function mint(address target, uint256 amount) external onlyMaster {
        _mint(target, amount);
    }
    function burn(address target, uint256 amount) external onlyMaster {
        _burn(target, amount);
    }
}

