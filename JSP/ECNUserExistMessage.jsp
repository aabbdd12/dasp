<%@ page import="java.sql.* , java.io.* ,java.util.*, Mimap.DADUserForm " %>


<html>

<head>

<title>DAD</title>

</head>

<body lang=EN-US link=blue vlink=purple style='tab-interval:.5in'>




<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
style='font-family:Tahoma;color:blue'>DAD Information<o:p></o:p></span></b></p>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
style='font-family:Tahoma;color:black'><br>
</span><font size="2"><span
style='color:black'><font face="Verdana">You cannot create the user:</font></span></font></b></p>

<table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" width="50%">
  <tr>
    <td width="28%"><b><font size="2" face="Verdana" color="#0000FF">Firstname</font></b></td>
    <td width="72%"><b><font size="2" face="Verdana">: <%=(String)session.getAttribute("prenom")%>
    </font></b> </td>
  </tr>
  <tr>
    <td width="28%"><b><font size="2" face="Verdana" color="#0000FF">Lastname</font></b></td>
    <td width="72%"><b><font size="2" face="Verdana">: <%=(String)session.getAttribute("nom")%></font></b></td>
  </tr>
  <tr>
    <td width="28%"><b style='mso-bidi-font-weight:normal'><font size="2"><span
style='font-family:Tahoma;color:black'><font face="Verdana">
    <span
style='color:#0000FF'>registred email </span></font></span></font></b></td>
    <td width="72%"><b><font size="2" face="Verdana">: <%=(String)session.getAttribute("email")%></font></b></td>
  </tr>
</table>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><font size="2">
<span
style='font-family:Tahoma;color:black'><font face="Verdana"><span
style='color:black'>because the user already exists in the database.</span></font></span></font></b><b style='mso-bidi-font-weight:normal'><font size="2"><span
style='font-family:Tahoma;color:black'><font face="Verdana"><span
style='color:black'><br style='mso-special-character:line-break'>
<![if !supportLineBreakNewLine]><br style='mso-special-character:line-break'>
</span></font></span></font><span
style='font-family:Tahoma;color:black'><font face="Verdana">
<span
style='color:black'>
<![endif]></span></font><o:p></o:p></span></b></p>

<ul>
  <li>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'>
<span
style='font-family:Verdana;color:red'><font size="2">Remarks:</font></span></b><b style='mso-bidi-font-weight:
normal'><span style='font-family:Verdana;color:black'><font size="2"><br>
If you forgot your username and/or password, use the item &quot;Login&quot; and click on 
the item &quot;Forgot your password ?&quot; and then follow the instructions.</font></span></b></p>
  </li>
  <li>

<p class=MsoNormal><b style='mso-bidi-font-weight:
normal'><span style='font-family:Verdana;color:black'><font size="2">You can 
also contact the DAD-Administrator to receive your user name and password;<br>
<br>
Thank you.</font></span></b><b style='mso-bidi-font-weight:normal'><span
style='font-family:Tahoma'><o:p></o:p></span></b></p>
  </li>
</ul>
<p align="center">
<input type="button" value="  Back  " onClick="history.back()" style="float: left"> </p>


 </body>

</html>