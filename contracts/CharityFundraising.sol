// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CharityFundraising {
    struct Campaign {
        string title;
        string description;
        uint targetAmount;
        uint amountRaised;
        address payable creator;
        bool fundsWithdrawn;
    }

    Campaign[] public campaigns;
    mapping(uint => mapping(address => uint)) public donations;

    function createCampaign(string memory _title, string memory _description, uint _targetAmount) public {
        require(_targetAmount > 0, "Target amount must be greater than zero.");

        campaigns.push(Campaign({
            title: _title,
            description: _description,
            targetAmount: _targetAmount,
            amountRaised: 0,
            creator: payable(msg.sender),
            fundsWithdrawn: false
        }));
    }

    function donate(uint _campaignId) public payable {
        require(_campaignId < campaigns.length, "Invalid campaign ID.");
        require(msg.value > 0, "Donation must be greater than zero.");

        Campaign storage campaign = campaigns[_campaignId];
        campaign.amountRaised += msg.value;
        donations[_campaignId][msg.sender] += msg.value;
    }

    function getCampaign(uint _campaignId) public view returns (string memory, string memory, uint, uint, address, bool) {
        require(_campaignId < campaigns.length, "Invalid campaign ID.");
        Campaign storage campaign = campaigns[_campaignId];
        return (campaign.title, campaign.description, campaign.targetAmount, campaign.amountRaised, campaign.creator, campaign.fundsWithdrawn);
    }

    function withdrawFunds(uint _campaignId) public {
        require(_campaignId < campaigns.length, "Invalid campaign ID.");
        Campaign storage campaign = campaigns[_campaignId];
        require(msg.sender == campaign.creator, "Only the campaign creator can withdraw funds.");
        require(campaign.amountRaised >= campaign.targetAmount, "Target amount not reached.");
        require(!campaign.fundsWithdrawn, "Funds already withdrawn.");

        campaign.fundsWithdrawn = true;
        campaign.creator.transfer(campaign.amountRaised);
    }
}

