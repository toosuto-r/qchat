\d .aoc

cookie:first read0`:aoc_cookie;                                                                                 //cookie for AoC authentication
idmap:exec id!name from ("*S";enlist",")0:`aoc_idmap;                                                           //map of AoC ID -> qchat username
st:enlist[0N 0N]!enlist[flip `name`local_score`stars`global_score`id`last_star_ts`completion_day_level!()];     //state dict for states of each lb & year combo
lbs:exec name!id from ("SJ";enlist",")0:`aoc_lbmap;                                                             //dict of leaderboards accessible
yrlst:2015 2016 2017                                                                                            //list of years that can be queried
prstrs:enlist[0N]!enlist ([id:()] stars:());                                                                    //dict to mantain prev star totals

/ getlb: get a specific leader board for specific year /
getlb:{[x;y] /x:leaderboard id,y:year
  / web request for lb JSON /
  j:`:http://adventofcode.com "GET /",string[y],"/leaderboard/private/view/",string[x],".json HTTP/1.1\r\n",
                              "host:adventofcode.com\r\n",
                              "Cookie:session=",cookie,"\r\n\r\n";
  :`name`local_score`stars`global_score`id`last_star_ts`completion_day_level#/:value .j.k[first[j ss "{"]_j]`members;
 }

/ updst: update state dictionary of leaderboards & years /
updst:{[x;y]
  st[(x;y)]:getlb[x;y];
 }

/ totstrs: get total stars per user for a given leaderboard across all years /
totstrs:{[x] /x:leaderboard
  :update .aoc.idmap id,"j"$stars from (pj/) {1!select id,stars from x where id in key .aoc.idmap}'[st@(x cross yrlst)];
 }

/ newstrs: detect new stars for a any users in a given leaderboard (include all years) /
newstrs:{[x] /x:leaderboard
  updst .' x cross yrlst;                                       //update state for all years on this board
  u:where not prstrs[x]~'totstrs x;
  u:exec id from u;
  if[count u;                                                   //alert & award points
     neg[key[.z.W]0](`worker;`aoc;"[",string[`minute$.z.T],"] The following users have received stars in the last 10 mins: ",", "sv string u);
     neg[key[.z.W]0]@/:`manageq,'flip raze get@'flip@'(key;get)@\:update stars:3*stars from totstrs[x]-prstrs x;
     prstrs[x]:totstrs x;                                       //update state of prev stars
   ];
  `cron insert (.z.P+"u"$10;`.aoc.newstrs;x);                   //check again on this same leaderboard in 10 mins
 }

\d .

.aoc.updst .' a:.aoc.lbs[`legacy`openaccess] cross .aoc.yrlst;   //update state dict for both leaderboards across all three years
@[`.aoc.prstrs;;:;]'[.aoc.lbs;.aoc.totstrs'[.aoc.lbs]];          //get the initial no. of stars for each user
`cron insert (.z.P+"u"$10;`.aoc.newstrs;.aoc.lbs`legacy);        //insert cron job to update & detect new stars every 10 mins