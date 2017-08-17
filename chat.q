system"c 23 1000"
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
.z.pi:{if[0<>.z.w;:neg[.z.w]"-1\"Forbidden - use a full q process.\""];.Q.s @[value;x;{'"nw"}]}
.z.ps:.z.po:.z.pm:.z.ph:.z.ws:.z.pp:.z.pg:{neg[.z.w]"-1\"oh no baby what is you doin\"";hclose[.z.w]}
.z.wo:{neg[x]"-1\"too sneaky for your own good tbh\"";hclose x}
admins:$[count a:.Q.opt[.z.x]`admin;`$a;`ryan]
users:raze .[0:;((enlist "S";",");chatfile:hsym`$raze string md5 banner);`$"-"vs $[count ul:first .Q.opt[.z.x]`users;ul;""]]
chatfile 0: string users;
hiddenusers:`
chatpubkey:3233 17
chatprikey:3233 413

cron:([]time:"p"$();action:`$())

.z.ts:{pi:exec i from cron where time<.z.P;if[count pi;r:exec action from cron where i=pi;delete from `cron where i=pi;value'[r]@\:`]}

tpks:aw:w:()!()
pks:@[get;`:pks;()!()]
ccache:@[get;`:ccache;()!()]
ucol:enlist[`]!enlist""

fallowed:`checker`decider`getpubkey`testdec`testenc`checkphrase`chatter`finalcheck
.z.ps:{if[x[0] in fallowed;:value x];neg[.z.w]"-1\"Rude.\""}
.z.pw:{[u;p]u in users}
.z.pc:{.[`w;();_;w?x];if[x in aw;.[`aw;();_;aw?x]];};
.z.po:{
  if[not x in w;@[`w;.z.u;:;x]];
  neg[x](system;"p 0");
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
    :neg[.z.w]"-1\"Please enter PRIVATE KEY or text file containing only this key in format: n e, where n is the component shared between public and private keys:\""];
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
      /neg[.z.w]"-1\"WARNING - enc and dec should be dyadic, taking to key components as a list, and the message to <en|de>crypt, e.g. enc[3233 17;\\\"hello\\\"] - DISCONNECTING\"";
      /:neg[.z.w]"hclose value `.z.w"];
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
  if[not all (not any null r;not 3233 17~desc r;2=count r;7h=type r:tpks .z.u);:fail"WARNING - Incorrect Input - DISCONNECTING"];
  neg[.z.w]"-1\"Please enter PRIVATE KEY or text file containing only this key in format: n e, where n is the component shared between public and private keys:\"";
  neg[.z.w]({`.z.pi set y@value x}[`.z.w];nspk);};

nspk:{`prikey set r:"J"$" "vs $[like[i:-1_y;"`:*"];first @[read0;hsym`$1_i;"wrong"];i];
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
  neg[.z.w]({`.z.pi set {neg[x](`chatter;enc[chatkey;-1_y])}[value `.z.w]};`);
  };

finalcheck:{if[c:testphrase~"c"$dc[chatprikey;x];
    @[`ccache;.z.u;:;ec[tpks .z.u;"c"$til 255]];
    `:ccache set ccache;
    @[`aw;.z.u;:;.z.w];
    @[`pks;.z.u;:;tpks .z.u];
    `:pks set pks;
    neg[.z.w]"-1\"Test successful - Chat enabled. Type \\\\h for help.\""];
  if[not c;.[`tpks;();_;.z.u];:fail"WARNING - Incorrect Input - DISCONNECTING"];
  neg[.z.w](set;`.z.ps;{if[0=x 0;:-1@"c"$dec[prikey;1_x]];if[1=x 0;:value"c"$dec[prikey;1_x]]});
  neg[value[hs]]@'0,'ccache[key[hs:aw _ aw?.z.w]]@\:string[.z.u]," has joined";};


endost:{neg[value[hs]]@'0,'ccache[key[hs:aw]]@\:"Ended ostracism voting";
  @[`tf;"";:;chat];
  h:aw u:c?max c:1_count'[group raze ostd];
  if[not n:null h;
    neg[h]@0,ccache[u]"j"$"You know what you did.";
    neg[h]@1,ccache[u]"j"$"exit 0";
    neg[value[hs]]@'0,'ccache[key[hs:aw]]@\:string[u]," has been BANISHED"];
  if[n;neg[value[hs]]@'0,'ccache[key[hs:aw]]@\:"Insufficient ill-will to kick."];
  `ostd set enlist[`]!enlist`;
  };

chatter:{tf[tf?tf 2$"c"$r][r:dc[chatprikey;x];.z.w;.z.u];};

chat:{[x;y;z]neg[value[hs]]@'0,'ccache[key[hs:aw _aw?y]]@\:ucol[.z.u;0],"[",$[10;string z],"]:",ucol[.z.u;1],x;};
quit:{[x;y;z]neg[value[hs]]@'0,'ccache[key[hs:aw _aw?y]]@\:string[.z.u]," has left";neg[y]@1,ccache[aw?y]"j"$"exit 0"};

tf:("";"\\q")!(chat;quit);

shutdown:{quit["";;""]each value aw}

p:{{(1+y 0;y[1] except s+a*til 0|1+div[x-s:a*a;a:y[1]y 0])}[x]/[{x[0]<count[x 1]div 2};(0;2+til x-1)]1}

/coprimes jg
c:{where not til[x] in raze 1,a*'til@'x div a:{x where 1=sum x=/:x*'x div/:x}i[w],d w:where x=i*d:x div i:1_1+til floor sqrt x}

/euclid gcd
eu:{first{last[x],(mod). x}/[{0<>last x};desc x,y]}

/congruence (ext Euclid)
cg:{$[0>t:{x[;1],'x[;0]-x[;1]*(div). last x}/[{0<>x[1;1]};(0 1;y,x)][0;0];t+y;t]}

/general ext. Euclid
ex:{{(x[1];(x[0]-x[1]*q:(div). x[;0]))}/[{0<x[1;0]};(x,y),'(1 0;0 1)]}
cg1:{{$[0>x[0;2];sum x[;2];x[1;2]]}ex . desc x,y}

/NOTE limit primes to 10000?
sk:{`pub`pri`nkey set'e,cg[e:1?c t;t:div[prd pq-1;eu . pq-1]],prd pq:2?p x}
mk:{`pub`pri`nkey!e,cg[e:1?1c t;t:div[prd pq-1;eu . pq-1]],prd pq:2?p x}

ec:{.[{{[x;y;M;n]$[y*c:mod[x*x;n];mod[M*c;n];c]}[;;z;x]/[1;r:?[a;1b]_a:0b vs y]};x]each "j"$y}
dc:{.[{{[x;y;C;n]$[y*m:mod[x*x;n];mod[C*m;n];m]}[;;z;x]/[1;r:?[a;1b]_a:0b vs y]};x]each y}
