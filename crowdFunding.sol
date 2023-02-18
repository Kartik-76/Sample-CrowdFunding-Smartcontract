// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract crowdFunding {
    mapping(address => uint256) public contributors;
    address public manager;
    uint256 public minimumContribution;
    uint256 public deadline;
    uint256 public target;
    uint256 public raisedAmount;
    uint256 public noOfContributors;

    struct Request {
        string desc;
        address payable recipient;
        uint256 value;
        bool complete;
        uint256 noOfVoters;
        mapping(address => bool) voters; //it will show votes of contributor
    }

    mapping(uint256 => Request) public requests; //mapping request with particular request
    uint public numRequests;

    constructor(uint256 _target, uint256 _deadline) {
        target = _target;
        deadline = block.timestamp + _deadline; //10sec + 3600sec
        minimumContribution = 100 wei;
        manager = msg.sender;
    }

    function sendEth() public payable {
        require(block.timestamp < deadline, "Deadline has Passed"); //checking whether smart contract is active or not
        require(
            msg.value >= minimumContribution,
            "Minimum contribution is not met"
        ); // checking whether user is sending minimum amoun
        if (contributors[msg.sender] == 0) {
            noOfContributors++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function refund() public {
        require(
            block.timestamp > deadline && raisedAmount < target,
            "You are not elegible for the refunds"
        );
        require(contributors[msg.sender] > 0);
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }

   modifier onlyManager(){
       require(msg.sender==manager,"Only Manager can call this fucntion");
       _;
   }

    function createRequests(string memory _desc, address payable _recipient,uint _value) public onlyManager{
        //pointing toward structure
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.desc = _desc;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.complete = false;
        newRequest.noOfVoters = 0;

    }

    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0,"You must be a contirbutor");
        Request storage thisRequests = requests[_requestNo];
        require(thisRequests.voters[msg.sender]==false,"You have already voted");
        thisRequests.voters[msg.sender] = true;
        thisRequests.noOfVoters++;
    }

    function makePayment(uint _requestNo) public onlyManager{
        require(raisedAmount>=target);
        Request storage thisRequests = requests[_requestNo];
        require(thisRequests.complete==false,"The request has been completed");
        require(thisRequests.noOfVoters > noOfContributors/2,"Mojority doesn't support");
        thisRequests.recipient.transfer(thisRequests.value);
        thisRequests.complete = true;
    }
}
