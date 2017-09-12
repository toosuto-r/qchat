.z.pw:{[u;p]"b"$not count .z.W}

/Powered by News API
/default BBC
src:(),hsym`$@[read0;`:sources.txt;"http://newsapi.org/v1/articles?source=bbc-news&sortBy=top&apiKey=ed61d8472c6845e1b7467c11ac999f69"];

getheadline:{news:.j.k .Q.hg first 1?src;
  neg[.z.w](`worker;`news;"(",x,") "," - "sv(),/:"c"$enlist[news`source],first each?[1;news`articles]`title`description`url)}

