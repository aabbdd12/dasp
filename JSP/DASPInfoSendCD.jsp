<html>

<head>
<meta http-equiv="Content-Language" content="fr-ca">
<meta name="GENERATOR" content="Microsoft FrontPage 5.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<title>DASP</title>
<style>
<!--
td{font-family:arial,helvetica,sans-serif;}
         .txt {font-size: 12px; font-family: arial, helvetica;}
         .txtcoul {font-size: 12px; font-family: arial, helvetica; color: #000000;}
-->
</style>
</head>



            <table  bordercolor="#F2FFF2" bgcolor="#FFFFCC">


                <form  method="post" action="DASPSendCD.jsp?userid2=<%=request.getParameter("userid2")%>">

              
                 <tr>
        
                <td height="1" style="font-family: arial, helvetica, sans-serif" width="350" colspan="2" bordercolor="#F2FFF2" bgcolor="#FFFFCC">
                <p align="left">
                <span style="font-family: Times New Roman; font-weight: 700; font-size: 9pt">
                Info for&nbsp; sending the CD</span></td>
             </table>
             <table bordercolor="#F2FFF2" bgcolor="#FFFFCC" width="357" border="0" style="border-collapse: collapse" cellpadding="0" cellspacing="0">
                            </tr>
                <tr>
        
               
                
                <td height="4" style="font-family: arial, helvetica, sans-serif" width="169" bordercolor="#F2FFF2" bgcolor="#FFFFCC">
                <span style="font-family: Verdana; font-size: 9pt">Sending date</span><span style="font-size: 9pt; font-family:Verdana"> </span></td>
                              </span>
        
               
               <span style="font-size: 12.0pt; font-family: Times New Roman">
                <td height="4" style="font-family: arial, helvetica, sans-serif" width="242" bordercolor="#F2FFF2" bgcolor="#FFFFCC">
                 
               
               <p align="left"><font size="2"><select class="formtext" name="month" required="Yes">
                      <option value="-" selected>Month</option>
                      <option value="01">January</option>
                      <option value="02">February</option>
                      <option value="03">March</option>
                      <option value="04">April</option>
                      <option value="05">May</option>
                      <option value="06">June</option>
                      <option value="07">July</option>
                      <option value="08">August</option>
                      <option value="09">September</option>
                      <option value="10">October</option>
                      <option value="11">November</option>
                      <option value="12">December</option>
                    </select> <select class="formtext" name="day" required="Yes">
                      <option value="-" selected>Day</option>
                      <option value="01">1</option>
                      <option value="02">2</option>
                      <option value="03">3</option>
                      <option value="04">4</option>
                      <option value="05">5</option>
                      <option value="06">6</option>
                      <option value="07">7</option>
                      <option value="08">8</option>
                      <option value="09">9</option>
                      <option value="10">10</option>
                      <option value="11">11</option>
                      <option value="12">12</option>
                      <option value="13">13</option>
                      <option value="14">14</option>
                      <option value="15">15</option>
                      <option value="16">16</option>
                      <option value="17">17</option>
                      <option value="18">18</option>
                      <option value="19">19</option>
                      <option value="20">20</option>
                      <option value="21">21</option>
                      <option value="22">22</option>
                      <option value="23">23</option>
                      <option value="24">24</option>
                      <option value="25">25</option>
                      <option value="26">26</option>
                      <option value="27">27</option>
                      <option value="28">28</option>
                      <option value="29">29</option>
                      <option value="30">30</option>
                      <option value="31">31</option>
                    </select>&nbsp; <select class="formtext" name="year" required="Yes">
                      <option value="0" selected>Year</option>
                      <option value="2010">2010</option>
                      <option value="2009">2009</option>
                      <option value="2008">2008</option>
                      <option value="2007">2007</option>
                      <option value="2006">2006</option>
                      <option value="2005">2005</option>
                      <option value="2004">2004</option>
                      <option value="2003">2003</option>
                      <option value="2002">2002</option>
                      <option value="2001">2001</option>
                      <option value="2000">2000</option>
                      <option value="1999">1999</option>
                      <option value="1998">1998</option>
                      <option value="1997">1997</option>
                      <option value="1996">1996</option>
                      <option value="1995">1995</option>
                      <option value="1994">1994</option>
                      <option value="1993">1993</option>
                      <option value="1992">1992</option>
                      <option value="1991">1991</option>
                      <option value="1990">1990</option>
                      <option value="1989">1989</option>
                      <option value="1988">1988</option>
                      <option value="1987">1987</option>
                      <option value="1986">1986</option>
                      <option value="1985">1985</option>
                      <option value="1984">1984</option>
                      <option value="1983">1983</option>
                      <option value="1982">1982</option>
                      <option value="1981">1981</option>
                      <option value="1980">1980</option>
                    </select></font></td>
                              </span>
                            </tr>
                            <tr>
        
               
                
                <td height="4" style="font-family: arial, helvetica, sans-serif" width="169" bordercolor="#F2FFF2" bgcolor="#FFFFCC">
                <span style="font-family: Verdana; font-size: 9pt">Confirmation 
                number</span><span style="font-size: 9pt; font-family: Verdana"> </span></td>
                <td height="4" style="font-family: arial, helvetica, sans-serif" width="174" bordercolor="#F2FFF2" bgcolor="#FFFFCC">
        
               
               <span style="font-size: 12.0pt; font-family: Times New Roman">
                <font face="Tahoma">
                <input maxlength="80" size="20" name="confnumber" /></font></span></td>
                            </tr>
                         
                            <tr>
        
               
              
                
                <td height="4" style="font-family: arial, helvetica, sans-serif" width="343" bgcolor="#FFFFCC" colspan="2">
                &nbsp;</td>
                            </tr>
                   </table>
                   <table  bordercolor="#F2FFF2" bgcolor="#FFFFCC" width="356" style="border-collapse: collapse" cellpadding="0" cellspacing="0">
                            <tr>
        
               
                <td height="3" style="font-family: arial, helvetica, sans-serif" width="136" bgcolor="#FFFFCC">
                <p align="center">
      </center></td>
        
               
                <td height="3" style="font-family: arial, helvetica, sans-serif" width="63" bgcolor="#FFFFCC">
      <input type="submit" value="Update" name="B1" style="font-size: 8pt; font-weight: bold; background-color: #9999FF; float:left"></td>
        
               
                <td height="3" style="font-family: arial, helvetica, sans-serif" width="147" bgcolor="#FFFFCC">
                &nbsp;</td>
                            </tr>
                      
        
               
              </table></form>
</body>

</html>