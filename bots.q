labels,:("\\ne";"\\ml";"\\bc";"\\df")!("news";"music";"bitcoin";"defino");

.lfm.enabled:1b;

news:{[x;y;z]rc[;y;0]"\033[GGetting news";neg[wh](`getheadline;uct string z);}
define:{[x;y;z] neg[wh](`dictlkup;trim "c"$3_x);}
mulo:{[x;y;z]
  .lfm.cache:@[get;`:lfm_cache;()!()];                                                          / cache lastfm usernames
  msg:trim"c"$3_x;                                                                              / get user commands
  if[not[.lfm.enabled]or()~key`:lfm_key;:rc[;y;0]"\033[Gmusic lookup not enabled"];
  if[0=count msg;:rc[;y;0]"\033[Gmusic lookup from lastfm enabled, available options:\n* enter a username to attempt now playing lookup\n  users:",$[0=count k:key .lfm.cache;"()";", "sv trim'[ucn'[k;string k]]],"\n* enter 'user=<USERNAME>' to enter or update your own lastfm username\n* unset username by entering 'user='"];
  if[msg like"user=*";
    `:lfm_cache set $[0=count uname:(1+msg?"=")_msg;.z.u _.lfm.cache;.lfm.cache,enlist[.z.u]!enlist uname]; / update cache
    :rc[;y;0]"\033[GUpdated username";
  ];
  if[not(`$msg)in key .lfm.cache;:rc[;y;0]"\033[Guser not available"];
  rc[;y;0]"\033[GSending Request";
  neg[wh](`.lfm.nowPlaying;trim uct string z;.lfm.cache`$msg;trim ucn[`$msg;msg]);
 };
btcp:{[x;y;z]
 if[`~`$upper trim"c"$3_x;x:"xxxUSD"];
 if[not (c:`$upper trim"c"$3_x) in `USD`GBP`EUR`PLOT;:rc[;y;0]"\033[GUnsupported currency/option. Supported currencies: gbp,usd,eur. Options: plot"];
 rc[;y;0]"\033[GGetting BTC price";neg[wh](`.btc.getprice;trim uct string z;c);
 };

workernames,:`news`music`bitcoin`defino!"[",/:$[10;("NEWSBOT";"LASTFMBOT";"BTCBOT";"DICTBOT")],\:"]:"

tf,:("\\ne";"\\ml";"\\bc";"\\df")!(news;mulo;btcp;define);
