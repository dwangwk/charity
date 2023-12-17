// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;

    }

    mapping(uint256 => Campaign) public campaigns;

    uint256 public numberOfCampaigns = 0;

    function createCampaign(
        address _owner,
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        string memory _image
    ) public returns (uint256) {
        Campaign storage campaign = campaigns[numberOfCampaigns];
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.image = _image;
        campaign.amountCollected = 0;
        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    function donate(uint256 _campaignId) public payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(
            campaign.deadline > block.timestamp,
            "Campaign is already closed"
        );
        require(
            campaign.amountCollected + msg.value <= campaign.target,
            "Campaign target reached"
        );
        campaign.donators.push(msg.sender);
        campaign.donations.push(msg.value);

        (bool success, ) = campaign.owner.call{value: msg.value}("");
        require(success, "Transfer failed.");
        if (success){
            campaign.amountCollected += msg.value;
        }
    }

    function getDonators(uint256 _campaignId)
        public
        view
        returns (address[] memory, uint256[] memory)
    {
        Campaign memory campaign = campaigns[_campaignId];
        return (campaign.donators, campaign.donations);
    }

    function getCampaign(uint256 campaignId)
        public
        view
        returns (
            address,
            string memory,
            string memory,
            uint256,
            uint256,
            uint256,
            string memory,
            address[] memory,
            uint256[] memory
        )
    {
        Campaign memory campaign = campaigns[campaignId];
        return (
            campaign.owner,
            campaign.title,
            campaign.description,
            campaign.target,
            campaign.deadline,
            campaign.amountCollected,
            campaign.image,
            campaign.donators,
            campaign.donations
        );
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory _campaigns = new Campaign[](numberOfCampaigns);
        for (uint256 i = 0; i < numberOfCampaigns; i++) {
            _campaigns[i] = campaigns[i];
        }
        return _campaigns;
    }

}