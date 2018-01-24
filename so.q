// STACK OVERFLOW BOT
/  Download latest set of KDB tagged questions on timer
/  Check for new questions
/  Display link to any new questions

.stack.url:"https://api.stackexchange.com/2.2/questions?order=desc&sort=creation&tagged=kdb&site=stackoverflow"
.stack.ldt:.z.z                                                         //set last date to current datetime, only display new questions
.stack.col:enlist[`]!enlist{[x;y] "\033[",string[x],"m",y,"\033[0m"}    //dictionary for colorising functions
.stack.col[`title]:.stack.col[`][33]                                    //33 - yellow
.stack.col[`link]:.stack.col[`][35]                                     //35 - purple
.stack.fix:ssr[;;{"c"$"I"$x except "&#;"}]/[;("&#??;";"&#???;")];       //function to replace HTML encoded special chars e.g. &#39; -> '
.stack.trm:{x til last ss[x;"/"]}                                       //trim link to remove unnecessary stating of question in URL

.stack.get:{
  /`:/tmp/so.json 0: enlist .Q.hg .stack.url;                           //doesn't appear to work correctly, needs further investigation
  system"wget -o /dev/null -O /tmp/so.json \"",.stack.url,"\"";         //download silently with wget & save to /tmp
  so:.j.k raze system"cat /tmp/so.json | gzip -d";                      //decompress return with gzip & parse as JSON
  hdel `:/tmp/so.json;                                                  //remove tmp file
  :so;                                                                  //return parsed JSON
 }

.stack.dt:{
  :1970.01.01+x%24*3600;                                                //calculate datetime based on seconds since UNIX epoch
 }

.stack.chk:{
  so:.stack.get[];                                                      //get latest JSON
  d:.stack.dt so[`items;;`creation_date];                               //get creation dates
  nq:so[`items] where d > .stack.ldt;                                   //get list of new questions
  .stack.ldt:d[0];                                                      //update last date
  :nq;                                                                  //return list of new questions, empty if none
 }

.stack.fmt:{[x]                                                         //take one question as input
  u:x[`owner][`display_name];                                           //extract username
  t:.stack.col.title .stack.fix x`title;                                //extract & colour title
  l:.stack.col.link .stack.trm x`link;                                  //extract & colour link
  :u," asked a question titled: ",t,"\nLink: ",l;                       //return complete string for this question
 };

if[`cron in key`.;
   /insert to cron
   .stack.cron:{
     nq:.stack.chk[];                                                   //check for new questions
     if[0<count nq;                                                     //if new questions, alert
        neg[key[.z.W]0](`worker;`stack;
                        "New question(s) on StackOverflow:\n",
                        "\n" sv .stack.fmt@'nq);                        //colourise questions & links
       ];
     `cron insert (.z.P+"u"$5;`.stack.cron;1#`);                        //check again in 5 mins
    };
   `cron insert (.z.P+"u"$5;`.stack.cron;1#`);                          //insert check for 5 mins after startup
  ];

if[not `cron in key`.;
   /use .z.ts for standalone outside of qchat
   .z.ts:{
     nq:.stack.chk[];                                                   //check for new questions
     if[0<count nq;-1 "\033[G",/:.stack.fmt@'nq];                       //reset cursor to 0 to overwrite q), output all new questions if any
    };
   system"t 300000";                                                    //set timer to 5 minutes
  ];
