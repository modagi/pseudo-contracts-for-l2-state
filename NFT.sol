contract NFT is ERC721 {
    uint256 public day;
    uint256 public lastIncreasedTime;
    
    address public l1_requestableDayCounter;
    mapping(uint256 => mapping(uint256 => bool)) public isMade;
    
    uint256 public requestedTime;
    
    function isValidNFT() public view returns(bool) {
        if (requestedTime == 0)
            return false;
            
        if (requestedTime + disputePeriod > block.timestamp) {
            return false;
        }
        
        return true;
    }
    
    function makeFastWithdrawal(uint256 batchIndex, uint256 leafIndex) external {
        require(
            !isMade[batchIndex][leafIndex],
            "already made"
        );
    
        // verify inputs are valid
        require(
            verifyExitRequest(batchIndex, leafIndex),
            "invalid tx in CanonicalTransactionChain"
        );
        
        // get L2 day value through CanonicalTransactionChain
        day = parseL2DayValue(batchIndex, leafIndex);
        requestedTime = parseRequestedTime(batchIndex, leafIndex);
        
        lastIncreasedTime = block.timestamp;
        
        isMade[batchIndex][leafIndex] = true;
    }
    
    function increaseDay() external {
        require(
            isValidNFT(),
            "invalid NFT"
        );
        require(
            isOnL2,
            "not entered"
        );
        require(
            lastIncreasedTime + 1 days >= block.timestamp,
            "too early"
        );
        
        day++
        
        lastIncreasedTime = block.timestamp;
    }
}