let saleDeploy;
let remainingSales, currentBatch, previousRemaining, previousBatch;

async function loadSale() {
    try {
        filterSale = true;

        // Adding event listeners for sale-related UI elements
        get("saleloadmore").addEventListener("click", preSale);
        get("salesearch").addEventListener("click", clearSaleSearch);
        get("saleview").addEventListener("click", saleSearch);

        // Handling click events on sale filter elements
        $('.sale-filter').on('click', function () {
            $('.sale-filter').removeClass('selected');
            $(this).addClass('selected');
        });
    } catch (error) {
        console.error("Error setting up event listeners: ", error);
    }

    try {
        // Showing the waiting sale indicator, hiding the load sale button and no sale list
        $("#waitingsale").show();
        $("#loadsale").hide();
        $("#nosalelist").hide();

        // Checking if a selected account exists
        if (selectedAccount !== null) {
            // Removing the gempresale element, resetting remainingSales, and calling preSale
            $("#gempresale").remove();
            remainingSales = null;
            await preSale();
        } else {
            // If no selected account, try loading sales again after 2 seconds
            setTimeout(loadSale, 2000);
        }
    } catch (error) {
        console.error("Error loading sales: ", error);
    }
}

async function preSale() {
    if (selectedAccount) {
        try {
            // Getting the current chain ID
            const chainId = await web3.eth.getChainId();
            
            // Setting saleDeploy based on the chain ID
            switch (chainId) {
                case 97:
                    saleDeploy = "0x18BbD41a2AB12638624cd87C41dfF9202Dd56307";
                    break;
                case 56:
                    saleDeploy = "bsc";
                    break;
                case 1:
                    saleDeploy = "eth";
                    break;
                case 5:
                    saleDeploy = "0x731b359d0f2fca6506097Bb6EbE8f43EB9404d0f";
                    break;
                case 137:
                    saleDeploy = "matic";
                    break;
                case 250:
                    saleDeploy = "ftm";
                    break;
                case 43114:
                    saleDeploy = "avax";
                    break;
                default:
                    throw new Error("Unsupported chain ID");
            }
            
            console.log(remainingSales);

            // Creating a new contract instance
            const contract = new web3.eth.Contract(saleabi, saleDeploy);
            
            // Getting the sale count from the contract
            const saleCount = await contract.methods.saleCount().call({ from: selectedAccount });

            // Determine the remaining sales and current batch to process
            if (remainingSales === null) {
                if (saleCount < 4) {
                    remainingSales = saleCount;
                    currentBatch = 0;
                } else {
                    remainingSales = saleCount;
                    currentBatch = saleCount - 4;
                }
            } else {
                if (currentBatch > 4) {
                    remainingSales -= 4;
                    currentBatch -= 4;
                } else if (currentBatch > 0) {
                    remainingSales -= 4;
                    currentBatch = 0;
                } else {
                    get("saleloadmore").disabled = true;
                    return;
                }
            }
            
            // Call allSales with the determined values
            allSales(remainingSales, currentBatch);

        } catch (error) {
            console.error("Error during presale: ", error);

            try {
                console.log('No presale events');
                $("#gemlist").hide();
                $("#loadsale").hide();
                $("#waitingsale").hide();
                $("#nosalelist").show();
            } catch (innerError) {
                console.error("Error hiding sale elements: ", innerError);
            }
        }
    } else {
        // If no selected account, retry loading sales after 2 seconds
        setTimeout(loadSale, 2000);
    }
}

async function allSales(remainingSales, currentBatch) {
    if (remainingSales === 0) {
        console.log('No presale events');
        $("#gemlist").hide();
        $("#loadsale").hide();
        $("#waitingsale").hide();
        $("#nosalelist").show();
        return;
    }

    try {
        // Hide "No sale" message and disable "Load more" button
        $("#nosalelist").hide();
        get("saleloadmore").disabled = true;
        console.log('Loading presale events');
        $("#filterlist").hide();
        $("#searchsale").hide();

        // Fetch chain data and currency symbol
        const chainId = await web3.eth.getChainId();
        const chainData = evmChains.getChain(chainId);
        const symbol = chainData.nativeCurrency.symbol;

        // Determine chain code based on chain ID
        const chainCode = chainId === 97 ? "tBSC" : chainId === 3 ? "tETH" : chainData.chain;

        // Initialize contract
        const saleContract = new web3.eth.Contract(saleabi, saleDeploy);

        // Create container for presale elements if not exists
        if (!$('#gempresale').length) {
            const presaleContainer = document.createElement("div");
            presaleContainer.className = "presale";
            presaleContainer.id = "gempresale";
            get("gemlist").append(presaleContainer);
        }

        for (let i = remainingSales; i > currentBatch; i--) {
            try {
                // Fetch sale details
                const saleStats = await saleContract.methods.salestats(i).call({ from: selectedAccount });
                const saleDates = await saleContract.methods.saledates(i).call({ from: selectedAccount });
                const auditStatus = await saleContract.methods.auditextern(saleStats.token).call({ from: selectedAccount });
                const kycStatus = await saleContract.methods.kyc(saleStats.token).call({ from: selectedAccount });
                const currentTime = Math.floor(Date.now() / 1000);

                // Generate sale link
                const saleLink = `https://gemsale.app/?chain=${chainCode}&sale=${saleStats.id}&tk=${saleStats.name}#defi-presale`;

                // Check if logo image exists
                const logoImage = await checkImage(saleDates.logo);

                // Create contract instance for sale
                const refundContract = new web3.eth.Contract(csaleabi, saleStats.acontract);

                // Fetch raised amount and status
                const raisedAmount = await refundContract.methods.weiRaised().call({ from: selectedAccount });
                const saleStatus = await refundContract.methods.checkStatus().call({ from: selectedAccount });

                // Check for GemMint deployment
                let isGemMint = false;
                try {
                    const auditContract = new web3.eth.Contract(tokabi, saleStats.token);
                    isGemMint = await auditContract.methods.GemMintDeploy().call({ from: selectedAccount });
                } catch (error) {
                    // Handle error silently
                }

                // Determine audit and KYC colors
                const auditColor = auditStatus.audit ? "#008cba" : "#9393931f";
                const kycColor = kycStatus.dox ? "#009688" : "#9393931f";

                // Convert and format values
                const softCap = parseFloat(web3.utils.fromWei(saleStats.softcap, 'ether')).toFixed(1);
                const hardCap = parseFloat(web3.utils.fromWei(saleStats.hardcap, 'ether')).toFixed(1);
                const raisedEther = parseFloat(web3.utils.fromWei(raisedAmount, 'ether')).toFixed(2);
                const progress = parseFloat((Number(raisedAmount) / Number(saleStats.hardcap)) * 100).toFixed(0);

                // Determine audit content and class
                const auditContent = auditStatus.audit ? "Audited Contract" : isGemMint ? "GemMint Contract" : "Unaudited Contract";
                const auditClass = auditStatus.audit ? "audit external" : isGemMint ? "audit gemmint" : "audit";

                // Calculate days until unlock
                const daysUntilUnlock = Math.round((saleDates.unlock - saleDates.start) / 86400);

                // Determine status content and class
                let statusContent, statusClass, timeText, timeClass;
                switch (saleStatus) {
                    case "FAILED":
                        statusContent = "✕ FAILED";
                        statusClass = "status inactive";
                        timeText = "Presale: Failed";
                        timeClass = "time time-inactive";
                        break;
                    case "SUCCESS":
                        statusContent = "✓ SUCCESS";
                        statusClass = "status success";
                        timeText = "Presale: Success";
                        timeClass = "time time-success";
                        break;
                    case "ENDED":
                        statusContent = "⦾ ENDED";
                        statusClass = "status end";
                        timeText = "Presale: Ended";
                        timeClass = "time time-ended";
                        break;
                    case "INACTIVE":
                        statusContent = "✕ INACTIVE";
                        statusClass = "status inactive";
                        timeText = "Presale: Inactive";
                        timeClass = "time time-inactive";
                        break;
                    case "UPCOMING":
                        statusContent = "△ UPCOMING";
                        statusClass = "status upcoming";
                        timeText = "Presale: Upcoming";
                        timeClass = "time time-upcoming";
                        break;
                    case "LIVE":
                        statusContent = "⦿ LIVE";
                        statusClass = "status live";
                        timeText = "Presale: Live";
                        timeClass = "time time-ongoing";
                        break;
                    default:
                        statusContent = "UNKNOWN";
                        statusClass = "status unknown";
                        timeText = "Presale: Unknown";
                        timeClass = "time time-unknown";
                }

                // Create presale card element
                const presaleCard = document.createElement('div');
                presaleCard.id = `presale${saleStats.id}`;
                presaleCard.className = 'pre-sale new-sale';
                presaleCard.innerHTML = `
<div class="sale-card" data-link="${saleLink}">
   <div class="sale_header">
      <img class="logo lozad" data-src="${logoImage}" src="/static/images/imgloads.gif">
      <p id="status" class="${statusClass}">${statusContent}</p>
      <h3 class="name">${saleStats.name}</h3>
      <div class="price rate">
         <p>1 ${symbol} = ${saleStats.salerate} ${saleStats.symbol}</p>
      </div>
      <hr>
   </div>
   <div class="card-click">
      <i id="audit-card" style="color: ${auditColor};" class="fas fa-file-certificate gem-xlarge"></i><i id="kyc-card" style="color: ${kycColor};" class="fas fa-id-card-alt gem-xlarge"></i>
      <div class="soft-hard-cap">
         <p>Soft / Hard Cap:</p>
         <h5>${softCap} ${symbol} - ${hardCap} ${symbol}</h5>
      </div>
      <div class="buy-meter" id="buyt${saleStats.id}" role="progressbar" style="--value:${progress}"></div>
      <div class="airdrop-stats"><span class="raisedhardcap">Raised: ${raisedEther} ${symbol}</span><span>Hard Cap: ${hardCap} ${symbol}</span></div>
      <div class="audits">
         <p class="${auditClass}">${auditContent}</p>
      </div>
      <div class="liquidity"><span class="liq">Liquidity: ${saleDates.liquidityper}%</span></div>
      <div class="unlock"><span>Unlocks in: ${daysUntilUnlock} Days</span></div>
   </div>
   <div class="sale_footer">
      <hr>
      <div id="time${saleStats.id}" class="${timeClass}">${timeText}</div>
      <a class="cardbutton sale-link" href="${saleLink}" target="_blank"><i class="fas fa-external-link"></i></a>
   </div>
</div>`;
                get("gempresale").appendChild(presaleCard);

                // Add click event to card
                $(document).ready(function () {
                    $('.card-click').click(function () {
                        pushUrl();
                    });
                });

                // Start countdown based on sale status
                if (saleStatus === "UPCOMING") {
                    countstart(`time${saleStats.id}`, saleDates.start, 1);
                } else if (saleStatus === "LIVE") {
                    countstart(`time${saleStats.id}`, saleDates.end, 2);
                }

                // Update UI states
                $("#waitingsale").hide();
                $("#loadsale").show();
                filterSale = false;
            } catch (error) {
                console.error('Error processing sale:', error);
                $("#gempresale").remove();
                $("#loadsale").hide();
                $("#waitingsale").hide();
                $("#nosalelist").hide();
                break;
            }
        }
    } catch (error) {
        try {
            $("#gempresale").remove();
            $("#loadsale").hide();
            $("#waitingsale").hide();
            $("#nosalelist").show();
            console.log(error); }
}
var saleCountdownTimer;

function initializeCountdown(elementId, targetTime, mode) {
    var element = get(elementId);

    saleCountdownTimer = setInterval(function () {
        try {
            // Calculate the remaining time in milliseconds
            var remainingTime = targetTime * 1000 - Date.now();
            
            if (remainingTime > 0) {
                // Create a new Date object
                var now = new Date();
                
                // Calculate the time differences
                var days = Math.floor(remainingTime / 86400000);
                var hours = Math.floor((remainingTime % 86400000) / 3600000);
                var minutes = Math.floor((remainingTime % 3600000) / 60000);
                var seconds = Math.floor((remainingTime % 60000) / 1000);

                // Format the time components
                var formattedHours = ("0" + hours).slice(-2);
                var formattedMinutes = ("0" + minutes).slice(-2);
                var formattedSeconds = ("0" + seconds).slice(-2);

                // Update the element's inner HTML based on the mode (1: Starts In, 2: Ends In)
                if (mode == 1) {
                    element.innerHTML = `Starts In: ${days}d ${formattedHours}h ${formattedMinutes}m ${formattedSeconds}s`;
                } else if (mode == 2) {
                    element.innerHTML = `Ends In: ${days}d ${formattedHours}h ${formattedMinutes}m ${formattedSeconds}s`;
                }
            }
        } catch (error) {
            // Clear the interval in case of an error
            clearInterval(saleCountdownTimer);
        }
    }, 1000);
}

async function getSaleSearch() {
    if (selectedAccount === null) {
        GemWarning('Please connect wallet');
        return false;
    }

    const tokenAddress = get("salesearch").value;

    try {
        // Check if the address is valid
        const isValidAddress = await web3.utils.isAddress(tokenAddress);
        if (!isValidAddress) {
            invalid.style.display = "block";
            obj("#invalid").textContent = "Wrong token address";
            return false;
        }

        // Check if the address is a contract
        const code = await web3.eth.getCode(tokenAddress);
        if (code === "0x") {
            invalid.style.display = "block";
            obj("#invalid").textContent = "Address is not a contract";
            return false;
        }

        // If both checks pass, hide the invalid message
        invalid.style.display = "none";
        return true;
    } catch (error) {
        console.error("Error during token address validation: ", error);
        return false;
    }
}

let searchSale = false;

// Function to initiate sale search
async function saleSearch() {
    if (!searchSale) {
        searchSale = true;
        await performSaleSearch();
    }
}

// Function to clear the sale search invalid message
function clearSaleSearch() {
    invalid.style.display = 'none';
}

async function performSaleSearch() {
    var check = await getSaleSearch();
    if (!check) {
        searchSale = false;
        return;
    }

    const chainId = await web3.eth.getChainId();
    const chainData = evmChains.getChain(chainId);
    const symbol = chainData.nativeCurrency.symbol;

    // Set chain code
    const chainCode = chainId === 97 ? "tBSC" : chainId === 3 ? "tETH" : chainData.chain;

    // Set saleDeploy based on chain ID
    switch (chainId) {
        case 97:
            saleDeploy = "0x18BbD41a2AB12638624cd87C41dfF9202Dd56307";
            break;
        case 56:
            saleDeploy = "bsc";
            break;
        case 1:
            saleDeploy = "eth";
            break;
        case 5:
            saleDeploy = "0x731b359d0f2fca6506097Bb6EbE8f43EB9404d0f";
            break;
        case 137:
            saleDeploy = "matic";
            break;
        case 250:
            saleDeploy = "ftm";
            break;
        case 43114:
            saleDeploy = "avax";
            break;
        default:
            console.error("Unsupported chain ID");
            return;
    }

    try {
        const salelist = new web3.eth.Contract(saleabi, saleDeploy);
        const searchValue = get('salesearch').value;
        console.log(searchValue);
        const checksumAddress = await web3.utils.toChecksumAddress(searchValue);
        const filterLength = await salelist.methods.filterLength(checksumAddress).call({ from: selectedAccount });
        if (filterLength === 0) {
            invalid.style.display = 'block';
            obj("#invalid").textContent = "No presale event found";
            console.log('No presale found');
            searchSale = false;
            return;
        }
        console.log('Presale event found');
        $('#gempresale').remove();
        $('#listsale').remove();
        $("#filtersale").remove();
        gemlist.style.display = "none";
        $("#filterlist").hide();
        searchsale.style.display = "block";
        $("#loadsale").hide();
        $("#waitingsale").show();

        if (!$('#listsale').length) {
            const presaleContainer = document.createElement("div");
            presaleContainer.className += "presale";
            presaleContainer.id = "listsale";
            get("searchsale").append(presaleContainer);
            searchSale = false;
        }

        const presaleList = get("listsale");
        for (let i = 0; i < filterLength; i++) {
            try {
                const filterSaleId = await salelist.methods.filterSale(checksumAddress, i).call({ from: selectedAccount });
                const saleStats = await salelist.methods.salestats(filterSaleId).call({ from: selectedAccount });
                const saleDates = await salelist.methods.saledates(filterSaleId).call({ from: selectedAccount });
                const auditStatus = await salelist.methods.auditextern(saleStats.token).call({ from: selectedAccount });
                const kycStatus = await salelist.methods.kyc(saleStats.token).call({ from: selectedAccount });
                const currentTime = Math.floor(Date.now() / 1000);

                const saleLink = `https://gemsale.app/?chain=${chainCode}&sale=${saleStats.id}&tk=${saleStats.name}#defi-presale`;

                const logoImage = await checkImage(saleDates.logo);

                const refundContract = new web3.eth.Contract(csaleabi, saleStats.acontract);
                const raisedAmount = await refundContract.methods.weiRaised().call({ from: selectedAccount });
                const saleStatus = await refundContract.methods.checkStatus().call({ from: selectedAccount });

                let isGemMint = false;
                try {
                    const auditContract = new web3.eth.Contract(tokabi, saleStats.token);
                    isGemMint = await auditContract.methods.GemMintDeploy().call({ from: selectedAccount });
                } catch (error) {
                    // Handle error silently
                }

                const auditColor = auditStatus.audit ? "#008cba" : "#9393931f";
                const kycColor = kycStatus.dox ? "#009688" : "#9393931f";

                const softCap = parseFloat(web3.utils.fromWei(saleStats.softcap, 'ether')).toFixed(1);
                const hardCap = parseFloat(web3.utils.fromWei(saleStats.hardcap, 'ether')).toFixed(1);
                const raisedEther = parseFloat(web3.utils.fromWei(raisedAmount, 'ether')).toFixed(2);
                const progress = parseFloat((Number(raisedAmount) / Number(saleStats.hardcap)) * 100).toFixed(0);

                const auditContent = auditStatus.audit ? "Audited Contract" : isGemMint ? "GemMint Contract" : "Unaudited Contract";
                const auditClass = auditStatus.audit ? "audit external" : isGemMint ? "audit gemmint" : "audit";

                const daysUntilUnlock = Math.round((saleDates.unlock - saleDates.start) / 86400);

                let statusContent, statusClass, timeText, timeClass;
                switch (saleStatus) {
                    case "FAILED":
                        statusContent = "✕ FAILED";
                        statusClass = "status inactive";
                        timeText = "Presale: Failed";
                        timeClass = "time time-inactive";
                        break;
                    case "SUCCESS":
                        statusContent = "✓ SUCCESS";
                        statusClass = "status success";
                        timeText = "Presale: Success";
                        timeClass = "time time-success";
                        break;
                    case "ENDED":
                        statusContent = "⦾ ENDED";
                        statusClass = "status end";
                        timeText = "Presale: Ended";
                        timeClass = "time time-ended";
                        break;
                    case "INACTIVE":
                        statusContent = "✕ INACTIVE";
                        statusClass = "status inactive";
                        timeText = "Presale: Inactive";
                        timeClass = "time time-inactive";
                        break;
                    case "UPCOMING":
                        statusContent = "△ UPCOMING";
                        statusClass = "status upcoming";
                        timeText = "Presale: Upcoming";
                        timeClass = "time time-upcoming";
                        break;
                    case "LIVE":
                        statusContent = "⦿ LIVE";
                        statusClass = "status live";
                        timeText = "Presale: Live";
                        timeClass = "time time-ongoing";
                        break;
                    default:
                        statusContent = "UNKNOWN";
                        statusClass = "status unknown";
                        timeText = "Presale: Unknown";
                        timeClass = "time time-unknown";
                }

                const presaleCard = document.createElement('div');
                presaleCard.id = `presale${saleStats.id}`;
                presaleCard.className = 'pre-sale new-sale';
                presaleCard.innerHTML = `
<div class="sale-card" data-link="${saleLink}">
   <div class="sale_header">
      <img class="logo lozad" data-src="${logoImage}" src="/static/images/imgloads.gif">
      <p id="status" class="${statusClass}">${statusContent}</p>
      <h3 class="name">${saleStats.name}</h3>
      <div class="price rate">
         <p>1 ${symbol} = ${saleStats.salerate} ${saleStats.symbol}</p>
      </div>
      <hr>
   </div>
   <div class="card-click">
      <i id="audit-card" style="color: ${auditColor};" class="fas fa-file-certificate gem-xlarge"></i><i id="kyc-card" style="color: ${kycColor};" class="fas fa-id-card-alt gem-xlarge"></i>
      <div class="soft-hard-cap">
         <p>Soft / Hard Cap:</p>
         <h5>${softCap} ${symbol} - ${hardCap} ${symbol}</h5>
      </div>
      <div class="buy-meter" id="buyt${saleStats.id}" role="progressbar" style="--value:${progress}"></div>
      <div class="airdrop-stats"><span class="raisedhardcap">Raised: ${raisedEther} ${symbol}</span><span>Hard Cap: ${hardCap} ${symbol}</span></div>
      <div class="audits">
         <p class="${auditClass}">${auditContent}</p>
      </div>
      <div class="liquidity"><span class="liq">Liquidity: ${saleDates.liquidityper}%</span></div>
      <div class="unlock"><span>Unlocks in: ${daysUntilUnlock} Days</span></div>
   </div>
   <div class="sale_footer">
      <hr>
      <div id="time${saleStats.id}" class="${timeClass}">${timeText}</div>
      <a class="cardbutton sale-link" href="${saleLink}" target="_blank"><i class="fas fa-external-link"></i></a>
   </div>
</div>`;
                presaleList.appendChild(presaleCard);

                $(document).ready(function () {
                    $('.card-click').click(function () {
                        pushUrl();
                    });
                });

                switch (saleStatus) {
					case "UPCOMING":
						initializeCountdown(settime, d.start, 1);
						break;
					case "LIVE":
						initializeCountdown(settime, d.end, 2)
				}

				$("#waitingsale").hide();
			} catch (e) {
				console.log(e)
				console.log('break');
				break;
			}

		}
	} catch (e) {
		try {
			console.log(e)
			searcSale = !1;
			$("#filterlist").hide();
			$("#searchsale").hide();
			$("#loadsale").hide();
			$("#waitingsale").hide();
			obj("#invalid").textContent = "No presale event found!";
			$("#invalid").hide();
		} catch (e) {}
	}
	try {
		searcSale = !1;

	} catch (e) {}


}
