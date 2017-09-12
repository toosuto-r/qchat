/ last fm analysis tool

.lfm.key:first@[read0;`:lfm_key;{.lfm.enabled:0b;-1 x;""}];

.lfm.root:"http://ws.audioscrobbler.com/2.0/";
.lfm.post:"&api_key=",.lfm.key,"&format=json";

.lfm.req:{.j.k .Q.hg`$.lfm.root,"?method=",x,.lfm.post};

/ user functions
.user.getRecentTracks:{.lfm.req"user.getrecenttracks&user=",x};

.user.nowPlaying:{
  msg:.user.getRecentTracks x;
  if[`error in key msg;:(0b;msg`message)];
  if[0=count m:msg[`recenttracks]`track;:(0b;"user has no recent tracks")];
  if[not(`$"@attr")in key a:first m;:(0b;"user is not currently playing a track")];
  :(1b;"'",a[`name],"' by ",a[`artist]`$"#text");
 };
