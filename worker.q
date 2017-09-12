.z.pw:{[u;p]"b"$not count .z.W}

/Powered by News API
/default BBC
src:(),hsym`$@[read0;`:sources.txt;"http://newsapi.org/v1/articles?source=bbc-news&sortBy=top&apiKey=ed61d8472c6845e1b7467c11ac999f69"];

getheadline:{news:.j.k .Q.hg first 1?src;
  neg[.z.w](`worker;`news;raze"(",x,") "," - "sv(),/:"c"$enlist[news`source],first each?[1;news`articles]`title`description`url)}

/ last fm analysis
.lfm.key:first@[read0;`:lfm_key;{.lfm.enabled:0b;-1 x;""}];

.lfm.root:"http://ws.audioscrobbler.com/2.0/";
.lfm.post:"&api_key=",.lfm.key,"&format=json";

.lfm.req:{.j.k .Q.hg`$.lfm.root,"?method=",x,.lfm.post};

/ user functions
.lfm.getRecentTracks:{.lfm.req"user.getrecenttracks&user=",x};
.lfm.nowPlaying:{[x;y]                                                                          / [user;msg]
  .lfm.cache:@[get;`:lfm_cache;()!()];                                                          / cache lastfm usernames
  msg:.lfm.getRecentTracks .lfm.cache`$y;
  if[`error in key msg;:()];                                                                    / error
  if[0=count m:msg[`recenttracks]`track;:()];                                                   / no recent tracks
  if[not(`$"@attr")in key a:first m;:()];                                                       / not listening
  v:"'",a[`name],"' by ",a[`artist]`$"#text";
  :neg[.z.w](`worker;`music;x,": ",y," is listening to ",v);
 };
