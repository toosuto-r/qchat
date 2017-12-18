\d .aoc

enabled:all `aoc_cookie`aoc_idmap`aoc_lbmap in key `:.;
if[enabled;
   cookie:first read0`:aoc_cookie;                                                                                 //cookie for AoC authentication
   idmap:exec id!name from ("*S";enlist",")0:`aoc_idmap;                                                           //map of AoC ID -> qchat username
   st:enlist[0N 0N]!enlist[flip `name`local_score`stars`global_score`id`last_star_ts`completion_day_level!()];     //state dict for states of each lb & year combo
   lbs:exec name!id from ("SJ";enlist",")0:`aoc_lbmap;                                                             //dict of leaderboards accessible
   yrlst:2015 2016 2017;                                                                                            //list of years that can be queried
   prstrs:enlist[0N]!enlist ([id:()] stars:());                                                                    //dict to mantain prev star totals

   / getlb: get a specific leader board for specific year /
   getlb:{[x;y] /x:leaderboard id,y:year
     / web request for lb JSON /
     j:`:http://adventofcode.com "GET /",string[y],"/leaderboard/private/view/",string[x],".json HTTP/1.1\r\n",
                                 "host:adventofcode.com\r\n",
                                 "Cookie:session=",cookie,"\r\n\r\n";
     t:`name`local_score`stars`global_score`id`last_star_ts`completion_day_level#/:value .j.k[first[j ss "{"]_j]`members;
     :update name:("anon",/:id) from t where 10h<>type each name;
    };

   / updst: update state dictionary of leaderboards & years /
   updst:{[x;y]
     st[(x;y)]:getlb[x;y];
    };

   / totstrs: get total stars per user for a given leaderboard across all years /
   totstrs:{[x] /x:leaderboard
     :delete name from update (`$name)^.aoc.idmap id,"j"$stars from 1!0!(pj/){2!select id,name,stars from x}'[st@(x cross yrlst)];
    };

   / newstrs: detect new stars for a any users in a given leaderboard (include all years) /
   newstrs:{[x] /x:leaderboard
     updst .' x cross yrlst;                                     //update state for all years on all boards
     u:(where not prstrs[x]~'totstrs x);
     u:(exec id from u) inter exec id from totstrs x where stars>0;
     if[count u;                                                   //alert & award points
        neg[key[.z.W]0](`worker;`aoc;"[",string[`minute$.z.T],"] The following users have received stars in the last 10 mins:\n",
                                      -1_.Q.s select from (totstrs[x]-prstrs[x]) where id in u);
        neg[key[.z.W]0]@/:`manageq,'flip raze get@'flip@'(key;get)@\:update stars*3 from totstrs[x]-prstrs x;
        prstrs[x]:totstrs x;                                       //update state of prev stars
      ];
     `cron insert (.z.P+"u"$10;`.aoc.newstrs;enlist x);                   //check again on this same leaderboard in 10 mins
    };

    / gtlb: get leaderboard for given lb & year /
    gtlb:{[x;y]
      t:select id,stars,local_score,global_score from (update .aoc.idmap id from .aoc.st[(x;y)]) where stars>0,not null id;
      :$[`;("User";"Stars";"Local Score";"Global Score")] xcol `local_score`stars xdesc t;
    };

    / aclb: API function for getting table from qchat /
    aclb:{[x;y;z]
      updst[.aoc.lbs`legacy;last .aoc.yrlst];
      :neg[.z.w](`worker;`aoc;"Hey ",x," here's the current AOC leaderboard for this year:\n",.Q.s gtlb[.aoc.lbs`legacy;last .aoc.yrlst]);
    };

  ];

\d .

if[.aoc.enabled;
  .aoc.updst .' a:.aoc.lbs[`legacy`openaccess] cross .aoc.yrlst;   //update state dict for both leaderboards across all three years
  @[`.aoc.prstrs;;:;]'[.aoc.lbs;.aoc.totstrs'[.aoc.lbs]];          //get the initial no. of stars for each user
  `cron insert (.z.P+"u"$10;`.aoc.newstrs;enlist .aoc.lbs`openaccess);        //insert cron job to update & detect new stars every 10 mins
  ];
