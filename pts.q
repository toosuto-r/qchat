if[not `pts in key`.;pts:(users!()):\:10];
if[not `dnt in key`.;dnt:(users!()):\:8];
if[not `dvt in key`.;dvt:(users!()):\:3];
if[not `qbonus in key`.;qbonus:(users!()):\:1];
rtk:{pts+:(users!()):\:10;dnt+:(users!()):\:8;dvt::(users!()):\:3;qbonus::(users!()):\:1;`cron insert (00:00+1+.z.D;`rtk;`);}

if[not `rtk in cron`action;`cron insert (00:00+1+.z.D;`rtk;`)];

recorded:`$("\\o ";"\\mk";"\\uv";"\\dv")
if[not `quse in key`.;quse:([]time:0#.z.p;user:0#`;func:0#`)]

fchk:enlist[""]!enlist{[x;y;m]0b}
chatter:{if[not fchk[fchk?fchk l:3$"c"$r;.z.w;.z.u;r:dc[chatprikey;x]];
  if[(l:`$l) in recorded;`quse insert (.z.P;.z.u;l)];
  tf[tf?tf 3$"c"$r][r;.z.w;.z.u]];};

ptchk:{[x;y;z;m] if[r:z>pts[y];rc["\033[GInsufficient q";x;0]];r}
ptcst:{[x;y;z;m] if[r:z>pts[y];rc["\033[GInsufficient q";x;0]];@[`pts;y;-;not[r]*z];r}

cdt:{[x;y;m]
  c:1^"J"$@[m:" "vs trim "c"$3_m;1];
  if[qbonus[y]&c=dnt[y];@[`qbonus;y;:;0];@[`pts;y;+;5];rc["\033[GBonus awarded";x;0]]; //bonus on spending all votes
  if[c=0;rc["\033[GDang, yo cheap";x;0];:1b];           //call out cheapskates trying to 0 vote
  if[r:abs[c]>dnt[y];rc["\033[GInsufficient q";x;0]];r} //c points to donate/upvote
cdv:{[x;y;m]
  c:1^"J"$@[m:" "vs trim "c"$3_m;1];
  if[c=0;rc["\033[GCan't downvote by 0, noob";x;0];:1b]; //call out noobs trying to 0 vote
  if[r:abs[c]>dvt[y];rc["\033[GInsufficient q";x;0]];r}
cmk:ptcst[;;1] //1 point to markov
cot:ptcst[;;5] //5 points to ostracise
cpl:ptchk[;;1] //1 point to poll
csr:ptcst[;;1] //1 point per simpsons reference

upvt:{[x;y;z]c:1^"J"$@[x:" "vs trim "c"$3_x;1];
  x:string t:nu a?min a:lvn[x 0]'[string nu:users except z];
  if[c<0;@[`pts;z;+;c];@[`dnt;z;+;c];:bc uvol[key aw],\:"\033[G",ucn[z;string z],"tried to be sneaky, fined ",string abs c];
  @[`pts;t;+;c];@[`dnt;z;-;c];bc uvol[key aw],\:"\033[G",ucn[z;string z],"upvoted",ucn[t;x],$[1<c;"by ",string c;""];}
dnvt:{[x;y;z]c:1^"J"$@[x:" "vs trim "c"$3_x;1];
  x:string t:users a?min a:lvn[x 0]'[string users];
  if[c<0;@[`pts;z;+;c];@[`dvt;z;+;c];:bc uvol[key aw],\:"\033[G",ucn[z;string z],"tried to be sneaky, fined ",string abs c];
  @[`pts;t;-;c];@[`dvt;z;-;c];bc uvol[key aw],\:"\033[G",ucn[z;string z],"downvoted",ucn[t;x],$[1<c;"by ",string c;""];}
wllt:{[x;y;z]rc[;y;0] "\033[G",1_ucn[u;string u],"has ",string[pts u],"q, can give ",string[dnt u]," and downvote ",string dvt[u:z^`$"c"$3_x];}

wltb:{[x;y;z] bc uvol[key aw],\:"\033[G","hey",(-1_ucn[z;string z]),", current wallets for active users are:\n",atproc ssr[;"^";"  "].Q.s 1!@[;`user;{`$"@",/:string[x],\:"^"}]`points`donates xdesc flip`user`points`donates`downvotes!(::;pts;dnt;dvt)@\:key aw};

ptpl:{[x;y;z]
  x:trim "c"$3_x;
  t:update c:((`$("\\uv";"\\dv";"\\mk";"\\o"))!1 1 1 5)func from quse;
  if[not[x~""]&not count select from quse where func=`$("\\",x);
     :rc[;y;0]"\033[GInsufficient number of actions or invalid action - usage: \\wp [{func}] where {func} is one of dv,uv,o or mk, or blank for all funcs weighted by cost";
    ];
  if[x~"";t:update func:`$"\\" from t];                                                         /update table for selecting all results
  t:([] user:key[aw];c:count[key[aw]]#0) lj select sum c by user from t where func=`$("\\",x);    /produce plot
  p:.plot.autocbar[t;`user`c;1b;1b;trim ucol[t`user;0]];
  bc uvol[key aw],\:"\033[G","hey",(-1_ucn[z;string z]),", plot of q use ",$[x~"";"across all funcs";"by ",x],"\n","\n" sv p; /broadcast plot
 }

fchk,:("\\mk";"\\o ";"\\p ";"\\uv";"\\dv";"\\sr")!(cmk;cot;cpl;cdt;cdv;csr);

tf,:("\\uv";"\\dv";"\\w ";"\\wt";"\\wp")!(upvt;dnvt;wllt;wltb;ptpl)

labels,:getLabels`:config/pts_labels.csv;
