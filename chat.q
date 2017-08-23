system"t 1000";

banner:"Welcome to homerchat: discreet and discrete."
if[count n:raze .Q.opt[.z.x]`name;banner:"Chat Room: ",n];

aliases:1b;
challenge:0b;
persist:1b;
record:1b;

qloc:@[system;"which q";getenv[`HOME],"/q/l32/q"]
connectedusers:@[get;`:cu;0#`]

.z.exit:{shutdown`}
.z.pi:{if[.z.w;:neg[.z.w]"-1\"Forbidden - use a full q process.\""];.Q.s @[value;x;{'"nw"}]}
.z.ps:.z.po:.z.pm:.z.ph:.z.ws:.z.pp:.z.pg:{neg[.z.w]"-1\"oh no baby what is you doin\"";hclose[.z.w]}
.z.wo:{neg[x]"-1\"too sneaky for your own good tbh\"";hclose x}
admins:$[count a:.Q.opt[.z.x]`admin;`$a;`ryan]
users:raze .[0:;((enlist "S";",");chatfile:hsym`$raze string md5 banner);`$"-"vs $[count ul:first .Q.opt[.z.x]`users;ul;""]]
chatfile 0: string users;
hiddenusers:`
ckeys:$[`key in key`;2 cut .key.mk[5000][`nkey`pub`nkey`pri];(3233 17;3233 413)]
chatpubkey:ckeys 0
chatprikey:ckeys 1
cron:([]time:"p"$();action:`$())

.z.ts:{pi:exec i from cron where time<.z.P;if[count pi;r:exec action from cron where i in pi;delete from `cron where i in pi;value'[r]@\:`]}

tpks:aw:w:()!()
pks:@[get;`:pks;()!()]
ccache:@[get;`:ccache;()!()]
ucol:@[get;`:ucol;enlist[`]!enlist""]
lastmsg:0

fallowed:`checker`decider`getpubkey`testdec`testenc`checkphrase`chatter`finalcheck
.z.ps:{if[x[0] in fallowed;:value x];neg[.z.w]"-1\"Rude.\""}
.z.pw:{[u;p]u in users}
.z.pc:{.[`w;();_;w?x];if[x in aw;neg[value[hs]]@'0,'ccache[key[hs:aw _aw?x]]@\:string[aw?x]," has left";.[`aw;();_;aw?x]];}
.z.po:{
  if[not x in w;@[`w;.z.u;:;x]];
  neg[x](system;"p 0");
  neg[x](system;"c 25 1000");
  neg[x]({hclose each key[.z.W] except value x};`.z.w);
  if[all (not any null r;2=count r;7h=type r:pks .z.u);
    neg[x]"-1\"",banner,"\"";
    neg[x]"-1\"Existing verified public key found for ",string[.z.u]," - proceed (y) or reset (n)\"";
    :neg[x]({`.z.pi set {neg[x](`decider;y)}[value `.z.w]};`)];
  neg[x]"-1\"",banner," Press ENTER to continue\"";
    :neg[.z.w]({`.z.pi set {[x;e;d;u;y]neg[x](`checker;e;d;u;y)}[value `.z.w;@[value;`enc;`];@[value;`dec;`];first`$system"id -u -n"]};`);
  };

decider:{if[first[x]="y";
    neg[.z.w]({`.z.pi set y@value x}[`.z.w];nspk);
    neg[.z.w]({`enc set x};ec);
    neg[.z.w]({`dec set x};dc);
    @[`tpks;.z.u;:;pks .z.u];
    :neg[.z.w]"-1$[`pri in key hsym `$getenv[`HOME],\"/.homerchat\";\"Found local private key from last session - re-use(y/n)?\";\"Please enter PRIVATE KEY or text file containing only this key in format: n e, where n is the component shared between public and private keys:\"]"];
    /:neg[.z.w]"-1\"Please enter PRIVATE KEY or text file containing only this key in format: n e, where n is the component shared between public and private keys:\""];
  neg[.z.w]"-1\"Press ENTER to continue\"";
  :neg[.z.w]({`.z.pi set {[x;e;d;u;y]neg[x](`checker;e;d;u;y)}[value `.z.w;@[value;`enc;`];@[value;`dec;`];first`$system"id -u -n"]};`);
  }

checker:{[x;y;u;z]
  if[not[aliases] and not .z.u~u;:fail"No aliases allowed - try again with your real name - DISCONNECTING"];
  if[challenge;
    if[not count edf:edf where (not `~/:edf)and 99<type each edf:x,y;
      neg[.z.w]"-1\"WARNING - No dyadic encryption/decryption functions names 'enc' and 'dec' found.
                \\n Function should be dyadic and should take hey and message as args.
                \\n e.g. enc[3233 17;\\\"hello\\\"], dec[3233 413;2170 1313 745 745 2185]
                \\n DISCONNECTING\"";
      neg[.z.w](system;"x .z.pi");
      :neg[.z.w]"hclose value `.z.w"];
    if[not all 2=count'[get'[edf][;1]];:fail .Q.s "WARNING - enc and dec should be dyadic, taking to key components as a list, and the message to <en|de>crypt, e.g. enc[3233 17;\"hello\"] - DISCONNECTING"];];
  neg[.z.w]"-1\"Please enter PUBLIC KEY or text file containing only this key in format: n e, where n is the component shared between public and private keys:\"";
  neg[.z.w]({`.z.pi set {neg[x](`getpubkey;$[like[i:-1_y;"`:*"]; first @[read0;`$1_i;"wrong"];i])}[value `.z.w]};`);};

fail:{neg[.z.w]"-1\"",x,"\"";
  if[not challenge;
    neg[.z.w]({.[`.;();_;`dec]};`);
    neg[.z.w]({.[`.;();_;`enc]};`)];
  neg[.z.w](system;"x .z.pi");
  :neg[.z.w]"hclose value `.z.w";};

testphrase:"testphrase if you are reading this something has gone wrong TESTPHRASE$%£!$)(854&$!~@:<>?,/.;#']["

getpubkey:{
  if[not all x in .Q.n," ";:fail"WARNING - Incorrect Input - DISCONNECTING"];
  @[`tpks;.z.u;:;"J"$" "vs x];
  if[not all (not any null r;not 323 17~desc r;2=count r;7h=type r:tpks .z.u);:fail"WARNING - Incorrect Input - DISCONNECTING"];
  /neg[.z.w]"-1\"Please enter PRIVATE KEY or text file containing only this key in format: n e, where n is the component shared between public and private keys:\"";
  neg[.z.w]"-1$[`pri in key hsym `$getenv[`HOME],\"/.homerchat\";\"Found local private key from last session - re-use(y/n)?\";\"Please enter PRIVATE KEY or text file containing only this key in format: n e, where n is the component shared between public and private keys:\"]";
  neg[.z.w]({`.z.pi set y@value x}[`.z.w];nspk);};

nspk:{
    if[`pri in key hsym `$getenv[`HOME],"/.homerchat";
    if["y"~first y;
      `prikey set get hsym `$getenv[`HOME],"/.homerchat/pri";
      :neg[x](`testdec;`)];
    -1"Please enter PRIVATE KEY or text file containing only this key in format: n e, where n is the component shared between public and private keys:";
     y:,[read0 0;"\n"]];
  `prikey set r:"J"$" "vs $[like[i:-1_y;"`:*"];first @[read0;hsym`$1_i;"wrong"];i];
  if[not all (not any null r;2=count r;7h=type r);
    -1"WARNING - Input Incorrect - DISCONNECTING";
    system"x .z.pi";
    :hclose x];
  system"x .z.pi";
  neg[x](`testdec;`);}

testdec:{
  neg[.z.w]"-1\"Testing decryption - waiting on return message:\"";
  if[not challenge;
    neg[.z.w]({`enc set x};ec);
    neg[.z.w]({`dec set x};dc);];
  neg[.z.w]({neg[.z.w](`checkphrase;.[dec;(prikey;x);"FAILURE"])};(ec[tpks .z.u;testphrase]));
  neg[.z.w]({`.z.pi set {neg[x](`testenc;y)}[value `.z.w]};`);};

checkphrase:{if[c:testphrase~"c"$x;if[record;connectedusers,:.z.u;`:cu set connectedusers];neg[.z.w]"-1\"Test successful - Press ENTER to continue\""];
  if[not c;.[`tpks;();_;.z.u];:fail"WARNING - Incorrect Input - DISCONNECTING"];};

testenc:{
  neg[.z.w]"-1\"Testing encryption - waiting on return message:\"";
  neg[.z.w](set;`chatkey;chatpubkey);
  neg[.z.w]({neg[.z.w](`finalcheck;.[enc;(chatkey;x);"FAILURE"])};(testphrase));
  neg[.z.w]({`.z.pi set {neg[x](`chatter;enc[chatkey;-1_y]);-1"\033[F\r\033[0J\033[F\r";}[value `.z.w]};`);
  };

finalcheck:{if[c:testphrase~"c"$dc[chatprikey;x];
    @[`ccache;.z.u;:;ec[tpks .z.u;"c"$til 1000]];
    `:ccache set ccache;
    @[`aw;.z.u;:;.z.w];
    @[`pks;.z.u;:;tpks .z.u];
    `:pks set pks;
    neg[.z.w]"-1\"Test successful - Chat enabled. Type \\\\h for help.\""];
    neg[.z.w]"hsym[`$pkl:getenv[`HOME],\"/.homerchat/pri\"]set prikey;system \"chmod 600 \",pkl";
  if[not c;.[`tpks;();_;.z.u];:fail"WARNING - Incorrect Input - DISCONNECTING"];
  neg[.z.w](set;`.z.ps;{if[0=x 0;:-1@"c"$dec[prikey;1_x]];if[1=x 0;:value"c"$dec[prikey;1_x]]});
  neg[value[hs]]@'0,'ccache[key[hs:aw _ aw?.z.w]]@\:string[.z.u]," has joined";};


endost:{neg[value[hs]]@'0,'ccache[key[hs:aw]]@\:"\033[GEnded ostracism voting";
  @[`tf;"";:;chat];
  h:aw u:c?max c:1_count'[group raze ostd];
  if[not n:null h;
    neg[h]@0,ccache[u]"j"$"\033[GYou know what you did.";
    neg[h]@1,ccache[u]"j"$"exit 0";
    neg[value[aw]]@'0,'ccache[key[aw]]@\:"\033[G",string[u]," has been BANISHED"];
  if[n;neg[value[aw]]@'0,'ccache[key[aw]]@\:"\033[GInsufficient ill-will to kick."];
  `ostd set enlist[`]!enlist`;
  };

msgtime:{if[lastmsg within .z.P-"v"$60 30;neg[value[aw]]@'0,'ccache[key[aw]]@\:"\033[GLast message at: ",string lastmsg-"v"$30];
   `cron insert (.z.P+"v"$30;`msgtime);}
msgtime`

chatter:{tf[tf?tf 2$"c"$r][r:dc[chatprikey;x];.z.w;.z.u];};

coldict:(`default`black`red`green`yellow`blue`magenta`cyan`gray!(" \033[0m";" \033[1;30m";" \033[1;31m";" \033[1;32m";" \033[1;33m";" \033[1;34m";" \033[1;35m";" \033[1;36m";" \033[1;37m"));

chat:{[x;y;z]lastmsg::.z.P;neg[value[aw]]@'0,'ccache[key[aw]]@\:"\033[G",ucol[.z.u;0],"[",$[10;string z],"]:",ucol[.z.u;1],x;};
quit:{[x;y;z]neg[y]@1,ccache[aw?y]"j"$"exit 0"};
help:{[x;y;z]neg[y]@0,ccache[aw?y]"j"$"\033[GMessage typed without prefix are automatically broadcast to all logged in users.\nUseful functions are called with \\X or \\X input, where X is a lower case letter, e.g. '\\q' or '\\quit' to quit"};
clrs:{[x;y;z]if[not(`$3_"c"$x) in key coldict;:neg[y]@0,ccache[aw?y]"j"$"Incorrect colour"];
  @[`ucol;z;:;(coldict `$3_"c"$x;"\033[0m ")];
  `:ucol set ucol;
  :neg[y]@0,ccache[aw?y]"j"$"\033[Gcolour set. Fabulous."};

tf:("";"\\q";"\\h";"\\c")!(chat;quit;help;clrs);

shutdown:{quit["";;""]each value aw}

ec:{.[{{[x;y;M;n]$[y*c:mod[x*x;n];mod[M*c;n];c]}[;;z;x]/[1;r:?[a;1b]_a:0b vs y]};x]each "j"$y}
dc:{.[{{[x;y;C;n]$[y*m:mod[x*x;n];mod[C*m;n];m]}[;;z;x]/[1;r:?[a;1b]_a:0b vs y]};x]each y}
