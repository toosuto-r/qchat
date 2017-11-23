if[not `pts in key`.;pts:(users!()):\:10];
if[not `dnt in key`.;dnt:(users!()):\:8];
if[not `qbonus in key`.;qbonus:(users!()):\:1];
rtk:{pts+:(users!()):\:10;dnt+:(users!()):\:8;qbonus:(users!()):\:1;`cron insert (00:00+1+.z.D;`rtk;`);}

if[not `rtk in cron`action;`cron insert (00:00+1+.z.D;`rtk;`)];

recorded:`$("\\o ";"\\mk";"\\uv";"\\dv")
if[not `quse in key`.;quse:([]time:0#.z.p;user:0#`;func:0#`)]

fchk:enlist[""]!enlist{[x;y]0b}
chatter:{if[not fchk[fchk?fchk l:3$"c"$r:dc[chatprikey;x];.z.w;.z.u];
  if[(l:`$l) in recorded;`quse insert (.z.P;.z.u;l)];
  tf[tf?tf 3$"c"$r][r;.z.w;.z.u]];};

ptchk:{[x;y;z] if[r:z>pts[y];rc["\033[GInsufficient q";x;0]];r}
ptcst:{[x;y;z] if[r:z>pts[y];rc["\033[GInsufficient q";x;0]];@[`pts;y;-;not[r]*z];r}

cdt:{[x;y] 
  if[qbonus[y]&2>dnt[y];@[`qbonus;y;:;0];@[`pts;y;+;5];rc["\033[GBonus awarded";x;0]]; //bonus on spending all votes
  if[r:1>dnt[y];rc["\033[GInsufficient q";x;0]];r} //1 point to donate/upvote
cmk:ptcst[;;1] //1 point to markov
cot:ptcst[;;5] //5 points to ostracise
cpl:ptchk[;;1] //1 point to poll
cdv:ptchk[;;1] //1 point to downvote

upvt:{[x;y;z]x:string t:nu a?min a:lvn["c"$3_x]'[string nu:users except z];
  @[`pts;t;+;1];@[`dnt;z;-;1];bc uvol[key aw],\:"\033[G",1_ucn[z;string z],"upvoted",ucn[t;x];}
dnvt:{[x;y;z]x:string t:users a?min a:lvn["c"$3_x]'[string users];
  @[`pts;;-;1]'[z,t];bc uvol[key aw],\:"\033[G",1_ucn[z;string z],"downvoted",ucn[t;x];}
wllt:{[x;y;z]rc[;y;0] "\033[G",1_ucn[u;string u],"has ",string[pts u],"q, and can give ",string dnt[u:z^`$"c"$3_x];}

wltb:{[x;y;z] bc uvol[key aw],\:"\033[G","hey",(-1_ucn[z;string z]),", current wallets for active users are:\n",.Q.s !/:[`points`donates;flip key[aw]#/:(pts;dnt)]}

ptpl:{[x;y;z]
  x:trim "c"$3_x;
  t:update c:((`$("\\uv";"\\dv";"\\mk";"\\o"))!1 1 1 5)func from quse;
  if[not[x~""] & not count select from quse where func=`$("\\",x);
     :rc[;y;0]"\033[GInsufficient number of actions or invalid action - usage: \\wp [{func}] where {func} is one of dv,uv,o or mk, or blank for all funcs weighted by cost";
    ];
  if[x~"";t:update func:`$"\\" from t];                                                         /update table for selecting all results
  t:([] user:key[aw];c:count[key[aw]]#0) lj select sum c by user from t where func=`$("\\",x);    /produce plot
  p:.plot.cp[`blue] .plot.auto[t;`user`c;`boxes;1b];
  bc uvol[key aw],\:"\033[G","hey",(-1_ucn[z;string z]),", plot of q use ",$[x~"";"across all funcs";"by ",x],"\n","\n" sv p; /broadcast plot
 }

fchk,:("\\mk";"\\o ";"\\p ";"\\uv";"\\dv")!(cmk;cot;cpl;cdt;cdv)

tf,:("\\uv";"\\dv";"\\w ";"\\wt";"\\wp")!(upvt;dnvt;wllt;wltb;ptpl)

labels,:("\\uv";"\\dv";"\\w ";"\\wt";"\\wp")!("upvote";"downvote";"wallet";"wallettable";"walletplot")
