pragma solidity ^0.8.11;
//SPDX-License-Identifier: Unlicensed

abstract contract ReentrancyGuard {
   
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED);
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

library SafeMath {
	function add(uint256 a, uint256 b) internal pure returns (uint256) {uint256 c = a + b; require(c >= a, "SafeMath: addition overflow"); return c;}	
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {return sub(a, b, "SafeMath: subtraction overflow");}
	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {require(b <= a, errorMessage);uint256 c = a - b;return c;}
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {if (a == 0) {return 0;}uint256 c = a * b;require(c / a == b, "SafeMath: multiplication overflow");return c;}
	function div(uint256 a, uint256 b) internal pure returns (uint256) {return div(a, b, "SafeMath: division by zero");}
	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {require(b > 0, errorMessage);uint256 c = a / b;return c;}
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {return mod(a, b, "SafeMath: modulo by zero");}
	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {require(b != 0, errorMessage);return a % b;}
}

interface IERC20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);  
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface LockERC20 {
function LockLPDefi(
        IERC20 _lp, 
        address _token, 
        address _pair, 
        address _beneficiary, 
        uint256 _startTime, 
        uint256 _endTime,  
        string memory _logo
    ) external;
}

contract PresaleGem is ReentrancyGuard {
    using SafeMath for uint256;
    
    mapping (address => uint256) internal _contributions;
    mapping (address => bool) internal whitelist;
    mapping (address => uint256) internal _TokensReserved;
    mapping (address => uint256) internal _tokensClaimed;
    mapping (address => bool) public Claimed;
    mapping (address => bool) public enteredPresale;

    IERC20 public _token;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2pair;
    address private tokenAddress;
    
    address public admin;
    address private owner;
    address public locker;
    uint256 private decimals;

    bool public active;
    bool public state;

    uint256 public _weiRaised;
    uint256 public _reservedTokens;
    uint256 public weiLiquidity;
    uint256 public tokenLiquidity;
    uint256 public liquidityPercent;
    uint256 private multiplier;
    string public status;

    uint256 public saleRate;
    uint256 public dexRate;    

    uint256 public startSALE;
    uint256 public endSALE;
    uint256 public liquidityUnlock;

    uint public minPurchase;
    uint public maxPurchase;

    uint public hardCap;
    uint public softCap;

    uint256 private taxSale;
    uint public availableTokensSALE;
    bool public PresaleSuccess = false;
    bool public initSale = false;
    bool public startRefund = false;
    bool public vestSet = false;
    string private logo;

    uint256 public vestTime;
    uint256 public totalPeriods;
    uint256 public timePerPeriod;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;    
    }

    modifier onlyAdmin() {
        require(msg.sender == admin,"Caller is not the owner");
        _;    
    }    

    event TokensPurchased(address indexed beneficiary, uint256 value, uint256 amount);
    event Refund(address recipient, uint256 amount);
    event Claim(address recipient, uint256 amount);

    constructor (address owner_, address token_, address router, address _admin, address _locker, uint start, uint end, uint _liquidityUnlock, uint256 _liquidityPercent) payable {
    owner = owner_;
    admin = _admin;
    liquidityPercent = _liquidityPercent;
    _token = IERC20(token_);
    decimals = _token.decimals();
    multiplier = 10**decimals;
    tokenAddress = token_;
    locker = _locker;
    liquidityUnlock = _liquidityUnlock;
    startSALE = start;
    endSALE = end;

    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
    uniswapV2Router = _uniswapV2Router;
    thisPair();
    }

    receive () external payable {
        buyTokens();
    }
    function addtoWhitelist(address[] memory _addresses) external onlyAdmin {
        require(_addresses.length != 0);
        for (uint256 i = 0; i < _addresses.length; i++) {
            require(_addresses[i] != address(0));
            whitelist[_addresses[i]] = true;
        }
    }      
    function removefromWhitelist(address[] memory _addresses) external onlyAdmin {
        require(_addresses.length != 0);
        for (uint256 i = 0; i < _addresses.length; i++) {  
            require(_addresses[i] != address(0));      
            delete whitelist[_addresses[i]];
        }
    }
    function checkWhitelist(address _address) public view returns (bool){
        return whitelist[_address];
    }
    function setWhitelist() external onlyAdmin {
        active = !active;
    }
    function addVesting() external onlyAdmin {
        require(block.timestamp < startSALE);
        state = !state;
    }
    function setVestings(uint256 _totalPeriods,uint256 _timePerPeriod) external onlyAdmin {
        require(state && !vestSet);
        totalPeriods = _totalPeriods;
        timePerPeriod = _timePerPeriod;
        vestSet = true;
    }
    function emergencyStop() external onlyOwner {
        endSALE = 0;
        startRefund = true;
    }        
    function setSALE(uint _minPurchase, uint _maxPurchase, uint _softCap, uint _hardCap, uint256 _saleRate, uint256 _dexRate, string memory _logo, uint256 _taxSale) external {
        require(!initSale);
        saleRate = _saleRate.mul(multiplier);
        dexRate = _dexRate.mul(multiplier); 
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        softCap = _softCap;
        hardCap = _hardCap;
        _weiRaised = 0;
        logo = _logo;
        taxSale = _taxSale;
        initSale = true;
    }
    function emergencyCancel() external SALENotActive {
        require(enteredPresale[msg.sender] == true, "Not entered in presale");
        require(PresaleSuccess == false && endSALE > 0);        
        require(block.timestamp > endSALE.add(86400), "Wait 24 hours after endtime");
        endSALE = 0;
        startRefund = true;
    }
    function cancelPresale() external onlyAdmin {
        require(endSALE > 0 && startRefund == false);
        endSALE = 0;
        startRefund = true;
    }
    function takeToken() external onlyAdmin SALENotActive {
        require(startRefund == true);
        uint256 tokenAmt = _token.balanceOf(address(this));
        require(tokenAmt > 0);
        _token.transfer(admin, tokenAmt);
    }      
    function finalizePresale() external onlyAdmin {
        require(startRefund == false);       
        if(_weiRaised >= softCap) {    
            endSALE = 0;
            vestTime = block.timestamp;       
            processFinalize();           
            PresaleSuccess = true;                   
        }
        else {
            endSALE = 0;
            startRefund = true;
        }
    }
    function processFinalize() private {
            uint256 totalToken = _token.balanceOf(address(this));
            weiLiquidity = _weiRaised.mul(liquidityPercent).div(10**2);
            tokenLiquidity = dexRate.mul(_weiRaised).mul(liquidityPercent).div(10**20);
            uint256 saleToken = tokenLiquidity.add(_reservedTokens);
            uint256 tokenBurn = totalToken.sub(saleToken);
            if (totalToken > saleToken) {
            burnTokens(tokenBurn);                                     
            }
            addLiquidity(tokenLiquidity, weiLiquidity);
            lockLiquidity();
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(_token, address(uniswapV2Router), tokenAmount);   

        uniswapV2Router.addLiquidityETH{ value: ethAmount }(
            tokenAddress,
            tokenAmount,
            0, 
            0, 
            locker,
            block.timestamp.add(1800)
        );         
            if (taxSale > 0) {
                uint256 weiTransferTax = _weiRaised.mul(taxSale).div(10**2);
                uint256 weiTransferAdmin = _weiRaised.sub(weiLiquidity).sub(weiTransferTax);
                payable(owner).transfer(weiTransferTax);
                payable(admin).transfer(weiTransferAdmin);     
            } else {
                uint256 weiTransfer = _weiRaised.sub(weiLiquidity);
                payable(admin).transfer(weiTransfer);
            }
                
    }
    function _approve(IERC20 _address, address address_, uint256 amount) private {
        _address.approve(address_, amount);
    }
    function lockLiquidity() private {
        IERC20 _lp = IERC20(uniswapV2pair);
        address _pairWETH = uniswapV2Router.WETH();
        address _beneficiary = admin;
        uint256 _startTime = block.timestamp;
        uint256 _endTime = liquidityUnlock;    
        LockERC20(locker).LockLPDefi(_lp,tokenAddress,_pairWETH,_beneficiary,_startTime, _endTime,logo);
    }
    function thisPair() public returns (address) {
        uniswapV2pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(tokenAddress, uniswapV2Router.WETH());
        if (uniswapV2pair == address(0)) {
                uniswapV2pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(tokenAddress, uniswapV2Router.WETH());
            }
        return uniswapV2pair;
    } 
    function burnTokens(uint256 _tokenBurn) private {
        _token.transfer(address(0xdead), _tokenBurn);
    }   
    function buyTokens() public nonReentrant SALEActive payable {
        uint256 weiAmount = msg.value;
        address beneficiary = msg.sender;
        _preValidatePurchase(beneficiary, weiAmount);
        availableTokensSALE = _token.balanceOf(address(this));
        uint256 tokens = _getTokenAmount(weiAmount);
        _weiRaised = _weiRaised.add(weiAmount);
        _reservedTokens = _reservedTokens.add(tokens);
        _contributions[beneficiary] = _contributions[beneficiary].add(weiAmount);
        _TokensReserved[beneficiary] = _TokensReserved[beneficiary].add(tokens);
        enteredPresale[beneficiary] = true;
        emit TokensPurchased(beneficiary, weiAmount, tokens);
    }
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        if(active) {require(checkWhitelist(beneficiary) == true, "Not whitelisted");}
        require(_token.balanceOf(address(this)) > 0, "No tokens available");      
        require(weiAmount >= minPurchase, "Have to send at least: minPurchase");
        require(_contributions[beneficiary].add(weiAmount) <= maxPurchase, "Cant buy more than maxPurchase");
        require(_weiRaised.add(weiAmount) <= hardCap, "Hard Cap reached");
        this; 
    }
    function claimTokens() external nonReentrant SALENotActive {
        require(endSALE == 0 && PresaleSuccess == true);
        address beneficiary = msg.sender;
        if(state && vestSet) {
            _preValidateVesting(beneficiary);
            _vestingClaim(beneficiary);      
        } else {
            _preValidateClaim(beneficiary);
            _deliverTokens(beneficiary); }
    }  
    function _preValidateVesting(address beneficiary) internal view {
        require(enteredPresale[beneficiary] == true);
        require(_TokensReserved[beneficiary] > 0, "No tokens available!");
        require(startRefund == false);
        this;
    }   
    function _vestingClaim(address beneficiary) internal {
        uint256 value = _contributions[beneficiary];
        uint256 tokenAmount = _getTokenAmount(value);
        uint256 claimedVesting = _tokensClaimed[beneficiary];
        uint256 timePassed = block.timestamp.sub(vestTime);
        if (block.timestamp >= vestTime.add(timePerPeriod.mul(totalPeriods))) {
            uint256 sendRemaining = _TokensReserved[beneficiary];
           _token.transfer(beneficiary, sendRemaining);
           _tokensClaimed[beneficiary] = _tokensClaimed[beneficiary].add(sendRemaining);
           _TokensReserved[beneficiary] = 0;
           emit Claim(beneficiary, sendRemaining);
        } else {    
        uint256 tokensToClaim = tokenAmount.div(totalPeriods).mul(timePassed.div(timePerPeriod)).sub(claimedVesting);
        require(tokensToClaim > 0, "Tokens not vested yet");            
        _tokensClaimed[beneficiary] = _tokensClaimed[beneficiary].add(tokensToClaim);                                                           
        _TokensReserved[beneficiary] = _TokensReserved[beneficiary].sub(tokensToClaim); 
        _token.transfer(beneficiary, tokensToClaim);
        emit Claim(beneficiary, tokensToClaim);
        }
    }
    function _preValidateClaim(address beneficiary) internal view {
        uint256 value = _contributions[beneficiary];
        require(startRefund == false);
        require(Claimed[beneficiary] == false, "Tokens already claimed!");
        require(enteredPresale[beneficiary] == true, "Not entered in presale");
        require(_TokensReserved[beneficiary] == _getTokenAmount(value));
        this;
    }    
    function _deliverTokens(address beneficiary) internal {
        uint256 tokenAmount = _TokensReserved[beneficiary];
         Claimed[beneficiary] = true;
        _TokensReserved[beneficiary] = 0;       
        _token.transfer(beneficiary, tokenAmount);
        emit Claim(beneficiary, tokenAmount);
    }
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(saleRate).div(10**18);
    }
    function refundMe() external nonReentrant SALENotActive {
        require(enteredPresale[msg.sender] == true, "Not entered in presale");
        uint amount = _contributions[msg.sender];
        require(startRefund == true, "No refund available");   
        require(amount > 0 && address(this).balance >= amount);     
        _contributions[msg.sender] = 0;     
        _TokensReserved[msg.sender] = 0;        
	    payable(msg.sender).transfer(amount);
	    emit Refund(msg.sender, amount);
    }
    function emergencyWhithdraw() external nonReentrant SALEActive {
        require(enteredPresale[msg.sender] == true, "Not entered in presale");
        uint256 amount = _contributions[msg.sender];
        require(amount > 0 && address(this).balance >= amount, "No refund available");         
        _weiRaised = _weiRaised.sub(amount);
        _reservedTokens = _reservedTokens.sub(_TokensReserved[msg.sender]);           
        _contributions[msg.sender] = 0;
        _TokensReserved[msg.sender] = 0;               
        uint256 taxamount = amount.mul(20).div(10**2);
        uint256 tosend = amount.sub(taxamount);
        payable(owner).transfer(taxamount);
	    payable(msg.sender).transfer(tosend);
	    emit Refund(msg.sender, tosend);
    }    
    function checkTokens(address _address) public view returns(uint256) {
        return _TokensReserved[_address];
    }
    function checkStatus() public returns(string memory) {
        if (endSALE == 0 && startRefund == true) {status = "FAILED";}
        if (endSALE == 0 && startRefund == false && PresaleSuccess == true) {status = "SUCCESS";}
        if (block.timestamp > endSALE && endSALE != 0) {status = "ENDED";}
        if (_token.balanceOf(address(this)) == 0 && block.timestamp < endSALE) {status = "INACTIVE"; }
        if (block.timestamp < startSALE && _token.balanceOf(address(this)) > 0) {status = "UPCOMING"; }
        if (block.timestamp > startSALE && block.timestamp < endSALE && _token.balanceOf(address(this)) > 0) {status = "LIVE";}
        return status;
    }
    function checkContribution(address _address) public view returns(uint256) {
        return _contributions[_address];
    }   
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }
    function totalTokens() public view returns (uint256) {
        return _token.balanceOf(address(this));
    }          
    modifier SALEActive() {
        require(block.timestamp >= startSALE && block.timestamp <= endSALE && _token.balanceOf(address(this)) > 0, "Presale must be active");
        _;
    }
    modifier SALENotActive() {
        require(block.timestamp > endSALE, "Presale should not be active");
        _;
    }
    function disengageTok(address _address) external onlyOwner {
        uint256 balance = IERC20(_address).balanceOf(address(this));
        IERC20(_address).transfer(msg.sender, balance);
    }    
    function disengageWei() external onlyOwner {
         payable(owner).transfer(address(this).balance);    
    } 
    
}

interface GemERC20 {
    function setSALE(
      uint256 bmin,
      uint256 bmax,
      uint256 scap,
      uint256 hcap,
      uint256 srate,
      uint256 brate,
      string memory logo,
      uint256 taxSale
    ) external;
}

contract factoryPresale {
    
    using SafeMath for uint256;
    
    uint256 public DeployTax;
    uint256 public UpdateTax;
    uint256 public taxSale;
    address private owner;
    address public locker;
    uint256 public saleCount = 0;

    mapping(address => DeploySale) public deploysales;
    mapping(address => ExternAudit) public auditextern;
    mapping(address => Doxxed) public kyc;
    mapping (address => bool) public aud;
    mapping (address => bool) public dox;            
    mapping(uint => SaleStat) public salestats;
    mapping(uint => SaleDate) public saledates;
    mapping(address => bool) public Deployer;
    mapping(IERC20 => uint[]) public filters;

    struct DeploySale {
        uint256 id;
        address token;
        address admin;
        address acontract;
    }
    struct SaleStat {
        uint256 id;
        address token;
        string name;
        string symbol;
        uint256 decimals;       
        address admin;
        address acontract;        
        uint256 minbuy;
        uint256 maxbuy;
        uint256 softcap;
        uint256 hardcap;
        uint256 salerate;
        uint256 dexrate;          
    }
    struct SaleDate {
        uint start;
        uint end;
        uint unlock;
        uint256 saletokens;
        uint256 dextokens;
        uint256 liquidityper;
        string description;
        string logo;
        string website;
        string telegram;
        string twitter;
        string reddit;       
    }
    struct ExternAudit {
        string auditlink;
        bool audit;
    }
    struct Doxxed {
        address owner;
        string kyclink;
        bool dox;
    }   
    
    function setTax(uint256 _DeployTax, uint256 _UpdateTax, uint256 _taxSale) external onlyOwner {
        DeployTax = _DeployTax;
        UpdateTax = _UpdateTax;
        taxSale = _taxSale;
    }
    function changeLocker(address _address) external onlyOwner {
        locker = _address;
    }    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;    
    }
    constructor (address _locker, uint256 _dtax, uint256 _utax, uint _txs) {
        owner = msg.sender;
        DeployTax = _dtax;
        UpdateTax = _utax;
        taxSale = _txs;
        locker = _locker;
    }
    function createSale(address token_, address router, uint256[] memory liquidity, uint[] memory date, uint256[] memory stats, string[] memory info) external payable {
         require(msg.value == DeployTax);
         require(Deployer[msg.sender] == false);
         address _admin = msg.sender;          
         saleCount = saleCount.add(1);
         PresaleGem gemsale = new PresaleGem(owner, token_, router, _admin, locker, date[0], date[1], date[2], liquidity[1]);         
         initSale(token_, _admin, address(gemsale), stats[0], stats[1], stats[2], stats[3], stats[4], stats[5], info[1]); 
         dateSale(date[0], date[1], date[2], liquidity[2], liquidity[0], liquidity[1], info[0], info[1], info[2], info[3], info[4], info[5]);                  
         if (msg.value > 0) {
            payable(owner).transfer(msg.value);
         } 
    }
    function dateSale(uint _start, uint _end, uint _unlock, uint256 _saletokens, uint256 _dextokens, uint256 _liquidityper, string memory _description, string memory _logo, string memory _website, string memory _telegram, string memory _twitter, string memory _reddit) internal {
        saledates[saleCount] = SaleDate({
            start: _start,
            end: _end,
            unlock: _unlock,
            saletokens: _saletokens,
            dextokens: _dextokens,
            liquidityper: _liquidityper,
            description: _description,
            logo: _logo,
            website: _website,
            telegram: _telegram,
            twitter: _twitter,
            reddit: _reddit            
        });
    }
    function initSale(address token_, address _admin, address _gemsale, uint256 bmin, uint256 bmax, uint256 scap, uint256 hcap, uint256 srate, uint256 drate, string memory _logo) internal {
        deploysales[_admin] = DeploySale({
            id: saleCount,
            token: token_,
            admin: _admin,
            acontract: _gemsale
        });
         IERC20 _token = IERC20(token_);
         uint256 decimals = _token.decimals();
         string memory name = _token.name();
         string memory symbol = _token.symbol();         
         filters[_token].push(saleCount);

        salestats[saleCount] = SaleStat ({
            id: saleCount,
            token: token_,
            name: name,
            symbol: symbol,
            decimals: decimals,            
            admin: _admin,
            acontract: _gemsale,            
            minbuy: bmin,
            maxbuy: bmax,
            softcap: scap,
            hardcap: hcap,
            salerate: srate,
            dexrate: drate        
        });
        Deployer[msg.sender] = true;           
        GemERC20(_gemsale).setSALE(bmin, bmax, scap, hcap, srate, drate, _logo, taxSale);        
    }
    function updateInfo(string memory description_, string memory logo_, string memory website_, string memory telegram_, string memory twitter_, string memory reddit_) external payable  {
        require(Deployer[msg.sender] == true); 
        require(msg.value == UpdateTax);
        uint256 idair = deploysales[msg.sender].id;
        saledates[idair].description = description_;
        saledates[idair].logo = logo_;
        saledates[idair].website = website_;
        saledates[idair].telegram = telegram_;
        saledates[idair].twitter = twitter_;
        saledates[idair].reddit = reddit_;
    }
    function enableAudit(address _address) external onlyOwner {
        aud[_address] = true;
    }
    function enableKyc(address _address) external onlyOwner {
        dox[_address] = true;
    }   
    function auditExt(address _address, string memory _link) external payable {
        require(aud[msg.sender]);
        require(msg.value == UpdateTax); 
        auditextern[_address] = ExternAudit(_link,true);
        aud[msg.sender] = false;
    }
    function kycExt(address _address, string memory _link) external payable {
        require(dox[msg.sender]);
        require(msg.value == UpdateTax); 
        kyc[_address] = Doxxed(msg.sender,_link,true);
        dox[msg.sender] = false;
    }       
    function filterLength(IERC20 _address) public view returns (uint) {
        return filters[_address].length;
    }   
    function filterSale(IERC20 _address, uint index) public view returns (uint) {
        return filters[_address][index];
    }    
    function disengageTok(IERC20 _token) external onlyOwner {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender, balance);
    }      
    function disengageWei() external onlyOwner {
         payable(owner).transfer(address(this).balance);    
    }   

}    
