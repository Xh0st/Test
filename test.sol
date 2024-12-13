let saleDeploy;
let r, k, h, g;

async function loadSale() {
	try {
                filterSale = !0;
		get("saleloadmore").addEventListener("click", preSale);
		get("salesearch").addEventListener("click", clearSaleSearch);
		get("saleview").addEventListener("click", saleSearch);
		$('.sale-filter').on('click', function () {
			$('.sale-filter').removeClass('selected');
			$(this).addClass('selected');
		});
	} catch (e) {}

	try {
		$("#waitingsale").show(), $("#loadsale").hide(), $("#nosalelist").hide(), null != selectedAccount ? ($("#gempresale").remove(), r = null, preSale()) : setTimeout(function () {
			loadSale()
		}, 2e3)
	} catch (e) {}
}

async function preSale() {
	if (selectedAccount) try {
		switch (await web3.eth.getChainId()) {
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
				saleDeploy = "avax"
		}
		console.log(r);
		const a = saleDeploy;
		var s = new web3.eth.Contract(saleabi, a);
		var e = await s.methods.saleCount().call({
			from: selectedAccount
		});
		null == r ? e < 4 ? (r = e, k = 0, allSales(r, k)) : (r = e, k = e - 4, allSales(r, k)) : k > 4 ? (r = h = r - 4, k = g = k - 4, allSales(r, k)) : k > 0 ? (r = h = r - 4, k = g = k - k, allSales(r, k)) : get("saleloadmore").disabled = !0
	} catch (e) {
		console.log(e)

		try {
			console.log('No presale events');
			$("#gemlist").hide();
			$("#loadsale").hide();
			$("#waitingsale").hide();
			$("#nosalelist").show();
		} catch (e) {}

	} else setTimeout(function () {
		loadSale();
	}, 2000)
}

async function allSales(o, p) {

	if (o == 0) {
		console.log('No presale events');
		$("#gemlist").hide();
		$("#loadsale").hide();
		$("#waitingsale").hide();
		$("#nosalelist").show();
		return;
	}

	try {
		$("#nosalelist").hide();
		get("saleloadmore").disabled = !0;
		console.log('Loading presale events');
		$("#filterlist").hide();
		$("#searchsale").hide();
                
		chainId = await web3.eth.getChainId();
		chainData = evmChains.getChain(chainId);
		symbol = chainData.nativeCurrency.symbol;

		97==chainId?chainC="tBSC":3==chainId?chainC="tETH":chainC=chainData.chain;

		const af = saleDeploy;
		const salelist = new web3.eth.Contract(saleabi, af);

		if (!$('#gempresale').length) {
			const L = cre("div");
			L.className += "presale";
			L.id = "gempresale";
			get("gemlist").append(L);
		}

		for (var i = o; i > p; i--) {
			try {
				var q = await salelist.methods.salestats(i).call({
					from: selectedAccount
				});
				var d = await salelist.methods.saledates(i).call({
					from: selectedAccount
				});
				var xa = await salelist.methods.auditextern(q.token).call({
					from: selectedAccount
				});
				var ka = await salelist.methods.kyc(q.token).call({
					from: selectedAccount
				});
				var ts = Math.round((new Date()).getTime() / 1000);

				var link = "https://gemsale.app/?chain=" + chainC + "&sale=" + q.id + "&tk=" + q.name + "#defi-presale";

				resimg = await checkImage(d.logo);

				crefund = q.acontract;
				checksale = new web3.eth.Contract(csaleabi, crefund);

				const raised = await checksale.methods.weiRaised().call({
					from: selectedAccount
				});
				const checkstat = await checksale.methods.checkStatus().call({
					from: selectedAccount
				});

				var gemmint = false;
				try {
					caudit = new web3.eth.Contract(tokabi, q.token);
					var gemmint = await caudit.methods.GemMintDeploy().call({
						from: selectedAccount
					});
				} catch (e) {} finally {}

				1 == xa.audit ? color_aud = "#008cba" : color_aud = "#9393931f";

				1 == ka.dox ? color_kyc = "#009688" : color_kyc = "#9393931f";

				var scap = web3.utils.fromWei(q.softcap, 'ether');
				var scap = parseFloat(scap).toFixed(1);
				var hcap = web3.utils.fromWei(q.hardcap, 'ether');
				var hcap = parseFloat(hcap).toFixed(1);

				var tkc = web3.utils.fromWei(raised, 'ether');
				var tkc = parseFloat(tkc).toFixed(2);

				var buyts = (Number(raised) / Number(q.hardcap)) * 100;
				var buyt = parseFloat(buyts).toFixed(0);

				if (xa.audit == true) {
					audit_content = "Audited Contract";
					audit_class = "audit external";
				} else if (gemmint == true) {
					audit_content = "GemMint Contract";
					audit_class = "audit gemmint";
				} else {
					audit_content = "Unaudited Contract";
					audit_class = "audit";
				}

				var difference = d.unlock - d.start;
				var daysD = Math.round(difference / 86400);
				var settime = "time" + q.id;

				switch (checkstat) {
					case "FAILED":
						status_content = "✕ FAILED", status_class = "status inactive", time_text = "Presale: Failed", time_class = "time time-inactiv";
						break;
					case "SUCCESS":
						status_content = "✓ SUCCESS", status_class = "status success", time_text = "Presale: Success", time_class = "time time-success";
						break;
					case "ENDED":
						status_content = "⦾ ENDED", status_class = "status end", time_text = "Presale: Ended", time_class = "time time-ended";
						break;
					case "INACTIVE":
						status_content = "✕ INACTIVE", status_class = "status inactive", time_text = "Presale: Inactive", time_class = "time time-inactiv";
						break;
					case "UPCOMING":
						status_content = "△ UPCOMING", status_class = "status upcoming", time_text = "Presale: Upcoming", time_class = "time time-upcoming";
						break;
					case "LIVE":
						status_content = "⦿ LIVE", status_class = "status live", time_text = "Presale: Live", time_class = "time time-ongoing"
				}
                                const GemSale = get("gempresale");
				const C = document.createElement('div');
				C.id = 'presale' + q.id;
				C.className += 'pre-sale new-sale';
				C.innerHTML = `
<div class="sale-card" data-link="${link}">
   <div class="sale_header">
      <img class="logo lozad" data-src="${resimg}" src="/static/images/imgloads.gif">
      <p id="status" class="${status_class}">${status_content}</p>
      <h3 class="name">${q.name}</h3>
      <div class="price rate">
         <p>1 ${symbol} = ${q.salerate} ${q.symbol}</p>
      </div>
      <hr>
   </div>
   <div class="card-click">
      <i id="audit-card" style="color: ${color_aud};" class="fas fa-file-certificate gem-xlarge"></i><i id="kyc-card" style="color: ${color_kyc};" class="fas fa-id-card-alt gem-xlarge"></i>
      <div class="soft-hard-cap">
         <p>Soft / Hard Cap:</p>
         <h5>${scap} ${symbol} - ${hcap} ${symbol}</h5>
      </div>
      <div class="buy-meter" id="buyt${q.id}" role="progressbar" style="--value:${buyt}"></div>
      <div class="airdrop-stats"><span class="raisedhardcap">Raised: ${tkc} ${symbol}</span><span>Hard Cap: ${hcap} ${symbol}</span></div>
      <div class="audits">
         <p class="${audit_class}">${audit_content}</p>
      </div>
      <div class="liquidity"><span class="liq">Liquidity: ${d.liquidityper}%</span></div>
      <div class="unlock"><span>Unlocks in: ${daysD} Days</span></div>
   </div>
   <div class="sale_footer">
      <hr>
      <div id="time${q.id}" class="${time_class}">${time_text}</div>
      <a class="cardbutton sale-link" href="${link}" target="_blank"><i class="fas fa-external-link"></i></a>
   </div>
</div>`
				GemSale.appendChild(C);

				$(document).ready(function () {
					$('.card-click').click(function () {
						pushUrl();
					});
				});
				switch (checkstat) {
					case "UPCOMING":
						countstart(settime, d.start, 1);
						break;
					case "LIVE":
						countstart(settime, d.end, 2)
				}

				$("#waitingsale").hide();
				$("#loadsale").show();
                                filterSale = !1;
			} catch (e) {
				console.log('break');
				$("#gempresale").remove();
				$("#loadsale").hide();
				$("#waitingsale").hide();
				$("#nosalelist").hide();
				break;
			}
		}
	} catch (e) {
		try {
			$("#gempresale").remove();
			$("#loadsale").hide();
			$("#waitingsale").hide();
			$("#nosalelist").show();
			console.log(e);
		} catch (e) {}
	}
	try {
               if(p > 0) {get("saleloadmore").disabled = !1};
	} catch (e) {}
}
var countsalet;

function countstart(e, t, z) {

	var n = get(e);
	countsalet = setInterval(function () {
		try {
			var e = 1e3 * t - Date.now();
			if (e > 0) {
				var o = new Date,
					d = (o.getTime(), o.getTimezoneOffset(), Math.floor(e / 864e5)),
					f = Math.floor(e % 864e5 / 36e5),
					i = Math.floor(e % 36e5 / 6e4),
					l = Math.floor(e % 6e4 / 1e3),
					h = ("0" + f).slice(-2),
					m = ("0" + i).slice(-2),
					s = ("0" + l).slice(-2);
				if (z == 1) {
					n.innerHTML = "Starts In: " + d + "d " + h + "h " + m + "m " + s + "s"
				} else if (z == 2) {
					n.innerHTML = "Ends In: " + d + "d " + h + "h " + m + "m " + s + "s"
				}
			}
		} catch (e) {
			clearInterval(countsalet);
		}
	}, 1e3)

}


async function getSaleSearch() {
	if (null == selectedAccount) return GemWarning('Please connect wallet');
	const t = get("salesearch").value;
	if (0 == await web3.utils.isAddress(t)) {
		invalid.style.display = "block";
		obj("#invalid").textContent = "Wrong token address";
		return false;
	} else if ("0x" == await web3.eth.getCode(t)) {
		invalid.style.display = "block";
		obj("#invalid").textContent = "Address is not contract";
		return false;
	} else {
		invalid.style.display = "none";
		return true;
	}
}

let searcSale = !1;
async function saleSearch() {
	searcSale || (searcSale = !0, saleS())
}

function clearSaleSearch() {
	invalid.style.display = 'none';
}

async function saleS() {
	var check = await getSaleSearch();
	if (check == false) {
		searcSale = !1;
		return;
	}
	chainId = await web3.eth.getChainId();
	chainData = evmChains.getChain(chainId);
	symbol = chainData.nativeCurrency.symbol;

	97 == chainId ? chainC = "tBSC" : 3 == chainId ? chainC = "tETH" : chainC = chainData.chain;
	switch (await web3.eth.getChainId()) {
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
			saleDeploy = "avax"
	}
	const af = saleDeploy;
	try {
		const salelist = new web3.eth.Contract(saleabi, af);
		const searchs = get('salesearch').value;
		console.log(searchs)
		const schecsum = await web3.utils.toChecksumAddress(searchs);
		const x = await salelist.methods.filterLength(schecsum).call({
			from: selectedAccount
		});
		if (x == 0) {
			invalid.style.display = 'block';
			obj("#invalid").textContent = "No presale event found";
			console.log('No presale found')
			searcSale = !1;
			return;
		}
		console.log('Presale event found')
		$('#gempresale').remove();
		$('#listsale').remove();
		$("#filtersale").remove();
		gemlist.style.display = "none";
		$("#filterlist").hide();
		searchsale.style.display = "block";
		$("#loadsale").hide();
		$("#waitingsale").show();
		if (!$('#listsale').length) {
			const L = cre("div");
			L.className += "presale";
			L.id = "listsale";
			get("searchsale").append(L);
			searcSale = !1;
		}
		const G = get("listsale");
		for (var i = 0; i < x; i++) {
			try {
				var N = await salelist.methods.filterSale(schecsum, i).call({
					from: selectedAccount
				});
				var q = await salelist.methods.salestats(N).call({
					from: selectedAccount
				});
				let d = await salelist.methods.saledates(N).call({
					from: selectedAccount
				});
				xa = await salelist.methods.auditextern(q.token).call({
					from: selectedAccount
				});
				ka = await salelist.methods.kyc(q.token).call({
					from: selectedAccount
				});
				var ts = Math.round((new Date()).getTime() / 1000);

				var link = "https://gemsale.app/?chain=" + chainC + "&sale=" + q.id + "&tk=" + q.name + "#defi-presale";

                                resimg = await checkImage(d.logo);

				crefund = q.acontract;
				checksale = new web3.eth.Contract(csaleabi, crefund);

				const raised = await checksale.methods.weiRaised().call({
					from: selectedAccount
				});
				const checkstat = await checksale.methods.checkStatus().call({
					from: selectedAccount
				});

				var gemmint = false;
				try {
					caudit = new web3.eth.Contract(tokabi, q.token);
					var gemmint = await caudit.methods.GemMintDeploy().call({
						from: selectedAccount
					});
				} catch (e) {} finally {}

				1 == xa.audit ? color_aud = "#008cba" : color_aud = "#9393931f";

				1 == ka.dox ? color_kyc = "#009688" : color_kyc = "#9393931f";

				var scap = web3.utils.fromWei(q.softcap, 'ether');
				var scap = parseFloat(scap).toFixed(1);
				var hcap = web3.utils.fromWei(q.hardcap, 'ether');
				var hcap = parseFloat(hcap).toFixed(1);

				var tkc = web3.utils.fromWei(raised, 'ether');
				var tkc = parseFloat(tkc).toFixed(2);

				var buyts = (Number(raised) / Number(q.hardcap)) * 100;
				var buyt = parseFloat(buyts).toFixed(0);

				if (xa.audit == true) {
					audit_content = "Audited Contract";
					audit_class = "audit external";
				} else if (gemmint == true) {
					audit_content = "GemMint Contract";
					audit_class = "audit gemmint";
				} else {
					audit_content = "Unaudited Contract";
					audit_class = "audit";
				}

				var difference = d.unlock - d.start;
				var daysD = Math.round(difference / 86400);
				var settime = "time" + q.id;


				switch (checkstat) {
					case "FAILED":
						status_content = "✕ FAILED", status_class = "status inactive", time_text = "Presale: Failed", time_class = "time time-inactiv";
						break;
					case "SUCCESS":
						status_content = "✓ SUCCESS", status_class = "status success", time_text = "Presale: Success", time_class = "time time-success";
						break;
					case "ENDED":
						status_content = "⦾ ENDED", status_class = "status end", time_text = "Presale: Ended", time_class = "time time-ended";
						break;
					case "INACTIVE":
						status_content = "✕ INACTIVE", status_class = "status inactive", time_text = "Presale: Inactive", time_class = "time time-inactiv";
						break;
					case "UPCOMING":
						status_content = "△ UPCOMING", status_class = "status upcoming", time_text = "Presale: Upcoming", time_class = "time time-upcoming";
						break;
					case "LIVE":
						status_content = "⦿ LIVE", status_class = "status live", time_text = "Presale: Live", time_class = "time time-ongoing"
				}

				const D = document.createElement('div');
				D.id = 'presale' + q.id;
				D.className = 'pre-sale new-sale';
				D.innerHTML = `
<div class="sale-card" data-link="${link}">
   <div class="sale_header">
      <img class="logo lozad" data-src="${resimg}" src="/static/images/imgloads.gif">
      <p id="status" class="${status_class}">${status_content}</p>
      <h3 class="name">${q.name}</h3>
      <div class="price rate">
         <p>1 ${symbol} = ${q.salerate} ${q.symbol}</p>
      </div>
      <hr>
   </div>
   <div class="card-click">
      <i id="audit-card" style="color: ${color_aud};" class="fas fa-file-certificate gem-xlarge"></i><i id="kyc-card" style="color: ${color_kyc};" class="fas fa-id-card-alt gem-xlarge"></i>
      <div class="soft-hard-cap">
         <p>Soft / Hard Cap:</p>
         <h5>${scap} ${symbol} - ${hcap} ${symbol}</h5>
      </div>
      <div class="buy-meter" id="buyt${q.id}" role="progressbar" style="--value:${buyt}"></div>
      <div class="airdrop-stats"><span class="raisedhardcap">Raised: ${tkc} ${symbol}</span><span>Hard Cap: ${hcap} ${symbol}</span></div>
      <div class="audits">
         <p class="${audit_class}">${audit_content}</p>
      </div>
      <div class="liquidity"><span class="liq">Liquidity: ${d.liquidityper}%</span></div>
      <div class="unlock"><span>Unlocks in: ${daysD} Days</span></div>
   </div>
   <div class="sale_footer">
      <hr>
      <div id="time${q.id}" class="${time_class}">${time_text}</div>
      <a class="cardbutton sale-link" href="${link}" target="_blank"><i class="fas fa-external-link"></i></a>
   </div>
</div>`
				G.appendChild(D);

				$(document).ready(function () {
					$('.card-click').click(function () {
						pushUrl();
					});
				});
				switch (checkstat) {
					case "UPCOMING":
						countstart(settime, d.start, 1);
						break;
					case "LIVE":
						countstart(settime, d.end, 2)
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
