# Experimental BEC exchange by dexaran820@gmail.com



Everyone can set up own contract using this code than change the price as needed by calling change_price(PRICE) and donate_BEC(BEC) or donate_ETC() inside the contract then share its address to allow everyone buy/sell BEC from this contract at the given price.


The base version of contract includes self-made debug mode enabled by default. 
During the debug mode contract owner can withdraw ETC/BEC at any time it needs to be done. Turned off once debug couldnt be turned on again.


Every time someone sends ETC to the contract it will automatically trigger a trade at the given price. If you send more ETC than (price*BEC) is inside the contract your transaction will fail.


Accidental send of BEC will trigger nothing and BEC will stay at the contract untill its owner will take them.

To trigger a trade by sending BEC you need to choose the sell_my_BEC(BEC) function.
The person who wants to sell BEC intor ETC by using this contract MUST first allow the contract to take his BEC because exchange contract CAN'T do it by default. 
You need to call approve(exchange_addr, amount_BEC) function first on BEC contract itself (here on ETC mainnet: 0x085fb4f24031eaedbc2b611aa528f22343eb52db)



!ATTENTION!
price is set for 1 BEC in WEI.
it means if you want to sell/buy 1 BEC per 0.5 ETC you need to set price=50000000000000000.
If price=100000000000000000   (1 BEC = 1 ETC)
price=10000000000000000    (1 BEC = 0.1 ETC)
price=2000000000000000     (1 BEC = 0.02 ETC)
etc. 
