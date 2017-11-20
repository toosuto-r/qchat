if[not `pts in key`.;pts:(users!()):\:10];
if[not `dnt in key`.;dnt:(users!()):\:8];
if[not `qbonus in key`.;qbonus:(users!()):\:1b];
rtk:{pts+:(users!()):\:10;dnt+:(users!()):\:8;qbonus:(users!()):\:1b}

`cron insert (00:00+1+.z.D;`rtk;`)

fchk:enlist[""]!enlist{[x;y]0b}
chatter:{if[not fchk[fchk?fchk 3$"c"$r:dc[chatprikey;x];.z.w;.z.u];tf[tf?tf 3$"c"$r][r;.z.w;.z.u]];};

ptchk:{[x;y;z] if[r:z>pts[y];rc["\033[GInsufficient q";x;0]];r}
ptcst:{[x;y;z] if[r:z>pts[y];rc["\033[GInsufficient q";x;0]];@[`pts;y;-;not[r]*z];r}

cdt:{[x;y] 
  if[qbonus[y]&2>dnt[y];@[`qbonus;y;:;0b];@[`pts;y;+;5];rc["\033[GBonus awarded";x;0]]; //bonus on spending all votes
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

fchk,:("\\mk";"\\o ";"\\p ";"\\uv";"\\dv")!(cmk;cot;cpl;cdt;cdv)

tf,:("\\uv";"\\dv";"\\w ")!(upvt;dnvt;wllt)

labels,:("\\uv";"\\dv";"\\w ")!("upvote";"downvote";"wallet")
