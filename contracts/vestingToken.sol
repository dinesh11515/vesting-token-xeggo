// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract vestingToken is ERC20, Ownable {

    uint256 public constant TOTAL_SUPPLY = 100000000 * 10**18;//100 million
    uint256 public constant AMOUNT_PER_MINUTE = TOTAL_SUPPLY / 518400;// amount per 1 min for 1 year

    uint8 private constant SPOTS = 10;
    uint8 public filled;
    uint256 public startTime; //start time of the stream
    uint256 public endTime;//end time of the stream

    address[] selectedAddress;

    struct Vesting {
        uint256 amount;
        uint256 lastClaimed;
        bool selected;
    }

    mapping (address => Vesting) public vesting;

    constructor() ERC20("vestingToken", "VEST") {
        startTime = block.timestamp;
        endTime = startTime + 365 days;
        addAddress(msg.sender);
    }

    function addAddress(address _address) public onlyOwner {
        require(endTime > block.timestamp, "Stream has ended");
        require(filled < SPOTS, "No more spots");
        require(!vesting[_address].selected, "Already selected");
        if(filled > 0){
            for(uint8 i = 0; i < selectedAddress.length;){
                // don't need to worry about overflow because the amount will unlock in 1 year checking end time was fine
                uint256 amount = (((block.timestamp - vesting[selectedAddress[i]].lastClaimed) / 60) * AMOUNT_PER_MINUTE) / filled;
                _mint(selectedAddress[i], amount);
                vesting[selectedAddress[i]].amount += amount;
                vesting[selectedAddress[i]].lastClaimed = block.timestamp;
                unchecked {
                    i++;
                }
            }
        }
        selectedAddress.push(_address);
        vesting[_address].selected = true;
        vesting[_address].lastClaimed = block.timestamp;
        unchecked{
            filled++;
        }
    }

    function claim() external {
        require(vesting[msg.sender].selected, "Not selected");
        uint256 amount = ((( block.timestamp - vesting[msg.sender].lastClaimed ) / 60) * AMOUNT_PER_MINUTE) / filled;
        _mint(msg.sender, amount);
        vesting[msg.sender].amount += amount;
        vesting[msg.sender].lastClaimed = block.timestamp;
    }


    function claimableBalance() external view returns(uint256){
        require(vesting[msg.sender].selected, "Not selected");
        return ((( block.timestamp -vesting[msg.sender].lastClaimed ) / 60) * AMOUNT_PER_MINUTE) / filled;
    }

}

