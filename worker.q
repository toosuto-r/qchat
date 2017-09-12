.z.pw:{[u;p]"b"$not count .z.W}

/Powered by News API
/default BBC
src:(),hsym`$@[read0;`:sources.txt;"http://newsapi.org/v1/articles?source=bbc-news&sortBy=top&apiKey=ed61d8472c6845e1b7467c11ac999f69"];

getheadline:{news:.j.k .Q.hg first 1?src;
  neg[.z.w](`worker;`news;raze"(",x,") "," - "sv(),/:"c"$enlist[news`source],first each?[1;news`articles]`title`description`url)}

/ last fm analysis
.lfm.key:first@[read0;`:lfm_key;""];

.lfm.root:"http://ws.audioscrobbler.com/2.0/";
.lfm.post:"&api_key=",.lfm.key,"&format=json";

.lfm.req:{.j.k .Q.hg`$.lfm.root,"?method=",x,.lfm.post};

/ user functions
.lfm.getRecentTracks:{.lfm.req"user.getrecenttracks&user=",x};
.lfm.nowPlaying:{[x;y;z]                                                                        / [user;lfm name;msg]
  msg:.lfm.getRecentTracks y;
  if[`error in key msg;:()];                                                                    / error
  if[0=count m:msg[`recenttracks]`track;:()];                                                   / no recent tracks
  if[not(`$"@attr")in key a:first m;:()];                                                       / not listening
  s:"'",a[`name],"' by ",a[`artist]`$"#text";
  :neg[.z.w](`worker;`music;"Hey ",x,", ",z," is listening to ",s);
 };

/ bitcoin
.btc.getprice:{
 j:.j.k .Q.hg`$":https://api.coindesk.com/v1/bpi/currentprice.json";
 :neg[.z.w](`worker;`bitcoin;"Hey ",x,", bitcoin price is currently: USD ",j[`bpi][`USD][`rate]);
 }
