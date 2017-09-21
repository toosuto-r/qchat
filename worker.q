.z.pw:{[u;p]"b"$not count .z.W}

/ update default seed
system"S ",string"j"$.z.T;

/ load additional worker code
\l lfm_worker.q

/Powered by News API
/default BBC
news_key:first@[read0;`:news_key;""];
src:(),hsym`$"http://newsapi.org/v1/articles?source=",/:@[read0;`:sources.txt;enlist"bbc-news&sortBy=top"],\:"&apiKey=",news_key;

getheadline:{news:.j.k .Q.hg first 1?src;
  neg[.z.w](`worker;`news;raze"(",x,") "," - "sv(),/:"c"$enlist[news`source],first each?[1;news`articles]`title`description`url)}

dictlkup:{
  dictf:{$[2>count t:raze raze .j.k[.Q.hg `$"http://api.pearson.com/v2/dictionaries/ldoce5/entries?headword=",x,"&limit=1"][`results][`senses][0][`definition];"No Results Found";t]};
  :neg[.z.w](`worker;`defino;raze"The definition of ",x," is: ",@[dictf;x;"unable to be retrieved."])
 };

/ bitcoin
.btc.getprice:{
 if[y=`PLOT;:neg[.z.w](`worker;`bitcoin;"Hey ",x,", BTC price over last month:","\n" sv 1_read0`:/tmp/btc.txt)];
 j:.j.k .Q.hg`$":http://api.coindesk.com/v1/bpi/currentprice.json";
 d:`GBP`USD`EUR!("£";"$";"€");
 :neg[.z.w](`worker;`bitcoin;"Hey ",x,", bitcoin price is currently: ",d[y],j[`bpi][y][`rate]," (",string[y],")");
 }

