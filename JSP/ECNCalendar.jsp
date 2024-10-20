<html>
<head>

<script LANGUAGE="JavaScript">
function montharray(m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11)
{
   this[0] = m0;
   this[1] = m1;
   this[2] = m2;
   this[3] = m3;
   this[4] = m4;
   this[5] = m5;
   this[6] = m6;
   this[7] = m7;
   this[8] = m8;
   this[9] = m9;
   this[10] = m10;
   this[11] = m11;
}

function MakeArray(n) {this.length = n; return this;}
  var Days = new MakeArray(7);
  var Months = new MakeArray(12);
  Days[1]="Sunday"; Days[2]="Monday"; Days[3]="Tuesday";   Days[4]="Wednesday";
  Days[5]="Thursday"; Days[6]="Friday"; Days[7]="Saturday";
  Months[1]="January"; Months[2]="February"; Months[3]="March";   Months[4]="April"; 
  Months[5]="May"; Months[6]="June"; Months[7]="July";   Months[8]="August"; 
  Months[9]="September"; Months[10]="October"; Months[11]="November"; 
  Months[12]="December";

  function getNiceDate(theDate) {
  return Days[theDate.getDay()+1] + " " + theDate.getDate() + " " +
  Months[theDate.getMonth()+1] + " " + theDate.getYear(); }


function calendar()
{
   today = new Date();
   var thisDay;
   var monthNames = "JanFebMarAprMayJunJulAugSepOctNovDec";
   var monthNames2 = " 1 2 3 4 5 6 7 8 9101112";
   var monthDays = new montharray(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
   year = today.getFullYear();
   if(year<2000)year+=1900;
   thisDay = today.getDate();
   if (((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0))
      monthDays[1] = 29;
   nDays = monthDays[today.getMonth()];
   firstDay = today;
   firstDay.setDate(1);
   var lastMod = new Date();
   startDay = firstDay.getDay();
   document.write("<TABLE BORDER=\"5\" CELLPADDING=\"5\">");
   document.write("<TR><TH COLSPAN=7>");
   document.write(getNiceDate(lastMod));
   document.write("<TR><TH>Sun<TH>Mon<TH>Tue<TH>Wed<TH>Thu<TH>Fri<TH>Sat");
   document.write("<TR>");
   column = 0;
   for (i=0; i<startDay; i++)
   {
      document.write("<TD>");
      document.write("<CENTER>");
      document.write("&nbsp");
      column++;
   }
   for (i=1; i<=nDays; i++)
   {
      document.write("<TD>");
      if (column == 0) 
         document.write("<FONT COLOR=\"#FF0000\">");
      if (column == 6) 
         document.write("<FONT COLOR=\"#0000FF\">");               
      if (i == thisDay)
         document.write("<FONT COLOR=\"#000000\"><b>");
      document.write("<CENTER>");
      document.write(i);
      document.write("</CENTER>");
      if (i == thisDay)
         document.write("</b>")
      if (column == 7||column == 0||i == thisDay) 
         document.write("</FONT>")
      column++;
      if (column == 7)
      {
         document.write("<TR>");
         column = 0;
      }
   }
   document.write("</TABLE>");
}
</script>

</head>
<body>
 <table height="17" cellSpacing="0" cellPadding="0" width="100%" border="0">
        <tr>
          <td align="left" width="100%" bgColor="#e4e9ff" height="2">
          <a style="TEXT-DECORATION: none" href="project.jsp?projid=">
          <font size="2"><span style="FONT-FAMILY: Tahoma">&nbsp;</span></font></a><font size="2"><span style="FONT-FAMILY: Tahoma"><b>Calendar </b></span></font></td>
        </tr>
        <tr>
      <td vAlign="top" width="100%" height="1">
      <p align="left">&nbsp;</td>
    </tr>
    <tr>
      <td vAlign="top" width="396" height="1">&nbsp;</td>
    </tr>
      </table>
     

<script LANGUAGE="JavaScript">
calendar();
</script>

</body>
</html>

