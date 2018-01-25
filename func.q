/Basic functions
fallowed:fallowed union `nerw


usls:{[x;y;z]rc[;y;0]"j"$"\033[Gusers online: ",","sv -1_'ucn .' flip "S*"$\:string key[aw] except hiddenusers;};

info:{[x;y;z]rc[;y;0]"j"$"\033[G",banner,". Chat admins: ",", "sv string (),admins};

kick:{[x;y;z]if[not .z.u in admins;:rc[;y;0]"j"$"\033[GKicking is an admin-only action"];
  if[not in[t:`$3_"c"$x;users];:rc[;y;0]"j"$"\033[GNot a user"];
  nc[;key[aw]except y;0]"\033[G",string[t]," has been permanently banished";
  neg[aw t]@1,ccache[t]"j"$"exit 0";
  chatfile 0: string users except t}

addu:{[x;y;z]if[not .z.u in admins;:rc[;y;0]"j"$"\033[GAdding is an admin-only action"];
  if[not in[t:`$3_"c"$x;users];:rc[;y;0]"j"$"\033[GNot a user"];
  nc[;key[aw]except y;0]"\033[G",string[t]," has been added";
  chatfile 0: string users,t}


thum:{[x;y;z]t:"i"$"\033[G\n         _     \n        |)\\     \n        :  )    \n_____  /  /__   \n     |`  (____) \n     |   |(____)\n     |__.(____) \n_____|.__(___)";chat[;y;z]t}

/Ostracism
ostd:enlist[`]!enlist`
pold:()!()
popt:()!()

endfuncs:`ostv`polv!`endost`endpol

votr:{[x;y;z;f]if[gameon`vote;:rc[;y;0]"\033[GVoting is in progress";];
  if[`ostv=f;
    h:"\033[G",string[.z.u]," has initiated ostracism mode.\nYou have 10 seconds to vote for a current user who will be kicked.";];
  if[`polv=f;
    if[not[";"in "c"$x]or 4>count x;:rc[;y;0]"\033[GInput in the form of \"Topic;option1;option2;...";];
    `popt set {(1+til count x)!x}1_{#[count[x];x]}o:";"vs"c"$3_x;
    h::value[`atproc]"\n"sv enlist["Poll initialised. you have 10 seconds to enter a choice number:"],{@[string[til count x],\:"]. ";0;:;""],'x}o;];
  bc uvol[key aw],\:h;
  @[`gameon;`vote;:;1b];
  `cron insert (.z.P+"v"$10;endfuncs f;`);
  @[`tf;"";:;value f];};

ostv:{[x;y;z]x:users a?min a:lvn[x]'[string users];@[`ostd;.z.u;:;x]};
polv:{[x;y;z];@[`pold;.z.u;:;0|(first "J"$"c"$x)&max key popt]}

endost:{neg[value[aw]]@'0,'ccache[key[aw]]@\:"\033[GEnded ostracism voting";
  @[`tf;"";:;chat];
  h:aw u:c?max c:1_count'[group raze ostd];
  if[in[`pts;key`.] & -1>neg[first dc]^first 1_deltas dc:desc c;
    @[`pts;u;-;5]];
  if[not n:null h;
    neg[h]@0,ccache[u]"j"$"\033[GYou know what you did.";
    neg[h]@1,ccache[u]"j"$"exit 0";
    bc uvol[key aw],\:"\033[G",string[u]," has been BANISHED"];
  if[n;bc uvol[key aw],\:"\033[GInsufficient ill-will to kick."];
  `ostd set enlist[`]!enlist`;
  @[`gameon;`vote;:;0b]
  };

endpol:{bc uvol[key aw],\:"\033[GPoll Ended";
  @[`tf;"";:;chat];
  bc uvol[key aw],\:value[`atproc]"\n"sv (max[count'[a]]$a:value[popt]),'"| ",/:count'[group[value pold]key popt]#\:"#";
  @[`gameon;`vote;:;0b];
  `pold set ()!();
  `popt set ()!();
  }

/Game interfaces
gamd:()
games:`connect4`ghost!`c4`gh

gamr:{[x;y;z]if[not in[x:`$3_"c"$x;key games];:rc[;y;0]"j"$"\033[GNot a known game";];
  if[gameon games x;:bc uvol[key aw],\:"\033[GGame already in progress";gamd::()];
  bc uvol[key aw],\:"\033[G",string[.z.u]," has initiated a game of ",string[x],". Press enter within the next 10 seconds to join.";
  `cron insert (.z.P+"v"$10;`endgv;games x);
  @[`tf;"";:;gamv];}

gamv:{[x;y;z]if[null first "c"$x;gamd,:.z.u];}

endgv:{@[`tf;"";:;chat];
  neg[aw ul]@'0,'ccache[ul:key[aw]except pl:distinct gamd]@\:"\033[GEnded game voting";
  if[2>count pl;:bc uvol[key aw],\:"\033[GNot enough players";gamd::()];
  t:2 0N#neg[count pl]?pl;
  .[`plyr;(x;0);:;(),t 0];
  .[`plyr;(x;1);:;(),t 1];
  @[`gameon;x;:;1b];
  nc[;pl;0]"j"$"you're in team ",/:raze string 1+where each pl in/:\:t;
  nc[;pl;1]"j"$raze"`.z.pi set {neg[x](`chatter;enc[chatkey;-1_\"\\\\",string[x],"\",y]);-1\"\\033[F\\r\\033[0J\\033[F\\r\";}[value `.z.w]";
  nc[;pl;1]"j"$
  "`.z.ps set {
   if[0=x 0;:-1@raze\"\\033[\",(string y-1),\";1H\\033[0J\\033[F\\r\\033[2K\",\"c\"$dec[prikey;1_x];];
   if[1=x 0;:value\"c\"$dec[prikey;1_x]];
   if[2=x 0;:1@raze\"\\033[s\\033[;H\",(\"c\"$dec[prikey;1_x]),\"\\033[u\\033[\",(string y-1),\";1H\";]}[;\"J\"$system\"tput lines\"]";
  .[`gamd;();:;()];
  .c4.step[];
  `cron insert (.z.P+"v"$turnlengths x;`endturn;x);}

plyr:(``c4`gh!()):\:(();())
turn:(``c4`gh!()):\:0
gtvote:``c4`gh!(();();())
gameon:(``c4`gh`vote!()):\:0b
turnlengths:``c4`gh!0N 7 10

gtf:`c4`gh!(`.c4.play;{})

play:{
  value[gtf[y]]@x
  }

//TODO add a if[not gameon`c4;chat[x;y;z] thing
c4tn:{[x;y;z]
  if[not within[i:"J"$"c"$first 3_x;0 9];:tf[tf?tf 3$"c"$3_x][3_x;y;z]];
  if[not .z.u in plyr[`c4]turn[`c4]mod 2;
    :rc[;y;0]"j"$"Wait your turn!"];
  @[`gtvote;`c4;,;i];
  rc[;y;0]"j"$"Vote received";}

endturn:{
  if[not gameon x;:()];
  @[`turn;x;+;1];
  mv:first key desc count'[group (),$[0=count v:gtvote x;1?7;v]];
  @[`gtvote;x;:;()];
  play[;x] string mv;
  `cron insert (.z.P+"v"$turnlengths[x];`endturn;x);
  }

resetgame:{
  nc[;pl:raze plyr x;1]"j"$"`.z.pi set {neg[x](`chatter;enc[chatkey;-1_y]);-1\"\\033[F\\r\\033[0J\\033[F\\r\";}[value `.z.w]";
  nc[;pl;1]@\:"j"$"`.z.ps set {if[0=x 0;:-1@\"c\"$dec[prikey;1_x]];if[1=x 0;:value\"c\"$dec[prikey;1_x]]}";
  @[`plyr;x;:;(();())];
  @[`gameon;x;:;0b];}


/New chat functions
mkct:{[x;y;z] if[2>count r:r where 1&count'[r:" "vs "c"$3_x];:rc[;y;0]"j"$"\033[GPlease input in format CHATNAME USER1 USER2 USER3... to add users from scratch or CHATNAME -USER1 USER2... to make a new chat with all but the named users from this chat"];
  if[r[0]in ?\:[n;" "]#'n:raze each (6+n ss\:"-name ")_'(n:p where count each(p:system"ps -ef | grep chatter.q")ss\:"chatter.q");
    :rc[;y;0]"j"$"\033[GChat exists and is currently active - quitting chat creation"];
  if[(cn:$[`;raze string md5 "Chat Room: ",r 0]) in key`:.;
    rc[;y;0]"j"$"\033[GChat already exists - taking existing userlist";
    r:enlist[r 0],read0 hsym cn];

  flags:" -name ",first[r]," -admin ",string[.z.u]," -users ","-"sv nu:(),/:$["-"~r[1;0];string[.z.u, users]except 1_r;(1_r),enlist string .z.u];
  chatcmd:raze $[persist;"nohup ",qloc;"q"]," chatter.q -p ",string[np:{$[x~r:@[system;"lsof -i :",string x;x];x;x+1i]}/[system"p"]],flags,$[persist;" &";""];
  system chatcmd;
  nc[;inter[key aw;.z.u,`$nu];0]@\:"\033[G",string[.z.u]," has made a new chat on port: ",string[np],".";
  }

dlte:{[x;y;z]if[not .z.u in admins;:rc[y;0]"j"$"\033[GDeleting the chatroom is an admin-only action"];
  if[(not "confirm"~i)or  not count i:3_"c"$x;:rc[;y;0]"j"$"\033[Gtype \\d confirm"];
  shutdown`;
  exit 0;}

/Emojis
emdict:(!)."Sj"$flip {enlist[("";"Available: ",", "sv x[;0])],x}2 cut read0`:emojis

emji:{[x;y;z] if[not(`$3_"c"$x) in key emdict;:rc[;y;0]"j"$"\033[GUnknown emoji - meme deficiency detected."];
  if[null`$3_"c"$x;:rc[;y;0]emdict`];
  ccht[;y;z]emdict `$"c"$3_x;}

getLabels:{(!).@[;`command`label]("**";1#",")0:x};

labels:getLabels`:config/labels.csv;

words:@[read0;`:works;enlist"unknown"];
/ cache topic list in random order to ensure all topics have been used once before repeating
topcReturn:{[]
  if[0=count@[value;`topcCache;()];topcCache::neg[count a]?a:@[read0;`:topics;enlist"there are no topics"]];
  :last({topcCache::1_ x};first)@\:topcCache;
 };

topc:{[x;y;z]lastmsg::.z.P;bc uvol[key aw],\:"\033[GThe current topic is: ",topcReturn[];}

medo:{[x;y;z]lastmsg::.z.P;bc uvol[key aw],\:"\033[G",1_uct[string z],pcols atproc"c"$4_x;}

slps:{[x;y;z]bc uvol[key aw],\:"\033[G [SANTABOT  ]: Sleeps until...",", "sv("Santa: ";"AoC: ";"Party: "),'string-[;.z.d]24 0 8+`date$a+11-mod[a:`month$.z.d;12];}

/ music lookup from lastfm
func:{[x;y;z]rc[;y;0]"\n"sv key[labels],'" ",'value labels}

cemdict:"c"$emdict
pemji:{raze#[1;r],(cemdict`$td#'dr),'(td:?\:[dr;" "])_'dr:1_r:"//e "vs x}
pcols:{raze[#[1;r],(1_'coldict coldict?coldict`$td#'dr),'(1+td:?\:[dr;" "])_'dr:1_r:"//c "vs x],coldict`}
atproc:{#[a;x],$[count b:ucol`$t;1_first b;e=count[x];"";"@"],t,_[-1;(),last[ucol`$t::1_a _e#x]],_[e:count[x]^w?[(a:?[x;"@"])<w:where not x in .Q.an;1b];x]}/

htproc:{x,$["#"=x 0;" http://twitter.com/hashtag/",1_x except " ";""]}

proc:reverse distinct (htproc;atproc;pcols;pemji),$[`flist.tsv in key`:.;@[("S*";"\t")0:`:flist.tsv;1;value']1;()]

//md:()!()
//pm:{md+:{count''[group'[wl[2]group flip(wl:w til[count w:(iw where not (iw:" "vs x)like\:"\033*")]+/:0 1 2)0 1]]}x;x}
//ms:{" "sv r where 0<count each r:{(last x;sums[md x]binr rand sum md x:$[x in key md;x;rand key md])}\[x;rand key md][;0]}
//mrkv:{[x;y;z] bc uvol[key aw],\:"\033[G",uct["[",$[10;string z],"]:"],rr:ms "J"$"c"$4_x}
//proc:pm,proc

chat:{[x;y;z]lastmsg::.z.P;bc uvol[key aw],\:"\033[G",uct["[",$[10;string z],"]:"],('[;]/[proc])"c"$x;}

//clean chat - doesn't use proc
ccht:{[x;y;z]lastmsg::.z.P;bc uvol[key aw],\:"\033[G",uct["[",$[10;string z],"]:"],"c"$x;}

publ:{[x;y;z]bc uvol[key aw],\:"\033[G",uct[z],x;};

boks:{[x;y;z]ccht[;y;z]'["j"$("╔",((3*1+2*count x)#"═"),"╗";"║",(raze " ",'upper x)," ║";"╚",((3*1+2*count x:"c"$3_x)#"═"),"╝")];}
biggerbox:{"\n" vs "╔",(a#"═"),"╗\n",c,"║",(raze " ",'upper y)," ║\n",(c:raze x#enlist "║",(b#" "),"║\n"),"╚",((a:3*b:1+2*count y)#"═"),"╝"}
bbks:{[x;y;z]ccht[;y;z]'["j"$biggerbox . {(0|5&1^"J"$x[1];" " sv 2_x)} " " vs "c"$3_x];}

workernames:enlist[`]!enlist"[",$[10;"BLANK"],"]";

worker:{publ[atproc y;0;n:workernames x]}
errw:rc[;;0]                                / rc projection used for returning errors from workers
nerw:nc[;;0]

tf[""]:chat

tf,:("\\  ";"\\u ";"\\i ";"\\k ";"\\o ";"\\p ";"\\y ";"\\a ";"\\n ";"\\d ";"\\e ";"\\g ";"\\c4";"\\b ";"\\bb";"\\t ";"\\me";"\\sl")!(func;usls;info;kick;votr[;;;`ostv];votr[;;;`polv];thum;addu;mkct;dlte;emji;gamr;c4tn;boks;bbks;topc;medo;slps);
