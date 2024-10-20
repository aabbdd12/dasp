<%@ page import="java.sql.* , java.io.* ,java.util.*, Mimap.ECNUser " %> 
<jsp:useBean id="query3"  class="Mimap.ECNUser" />

<!doctype html public "-//w3c//dtd html 4.0 transitional//en">

<html>
<head>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <meta name="Author" content="Araar Abdelkrim">
   <meta name="GENERATOR" content="Microsoft FrontPage 5.0">
  <title>PEP-NET.org</title>
</head>
<body>

<p align="left"><font face="Tahoma" color="#0000FF"><b>Recall the user by sending password again ...</b></font></p>
</p>

<center>

<%!
    ResultSet rs10=null;
                            %><font size="2" face="Times New Roman">

                            <%
   
    rs10= query3.queryAllUser();
    if (rs10 != null)
    {      
	%> </font>


  

    <%
    	int count = 0;
    	int nombre =0;
        
       
        while (rs10.next())
        {
         String id = rs10.getString("USERID");
         String firstname = rs10.getString("FIRSTNAME");
         String lastname = rs10.getString("LASTNAME");
         String username = rs10.getString("USERNAME");
         String pwd = rs10.getString("PASSWORD");
         String email = rs10.getString("EMAIL");
         String phone = rs10.getString("PHONE");
	     String organisation = rs10.getString("ORGANISATION");
         String institution = rs10.getString("INSTITUTION");
         String country = rs10.getString("COUNTRY");
         

         if (count ==0)
         {
     %>
<div align="left">
     





<table COLS=3 WIDTH="600" BGCOLOR="#6699FF" style="border-collapse: collapse" bordercolor="#111111" cellpadding="0" cellspacing="0" height="33" >
<tr>

<%! String attribute; %>

<% attribute = (String)application.getAttribute("stringToQuery"); %>
<input TYPE="hidden" NAME="Group[0]" VALUE="list-pmma-group@ecn.ulaval.ca" >
<input TYPE="hidden" NAME="Count"    VALUE="1" >
<!--td width="326" height="33" bordercolor="#D7E3FF" bgcolor="#D7E3FF">
<form ACTION="mailto:<%=attribute%>@ecn.ulaval.ca" METHOD="post">
<center>
  <input TYPE="submit" VALUE="Recall the whole group" style="font-size: 8pt; font-weight: bold; background-color: #6666FF">
</center>
</td>
</form-->


<form ACTION="../archive.phtml" METHOD="post">
<td width="21" height="33" bgcolor="#D7E3FF">
<center>
&nbsp;</center>
</td>
</form>
<form ACTION="/PEP/servlet/ECNSendMail?action=RECALLUSER" METHOD="post"-->

<!--form ACTION="ECNRecallSelectMember.jsp" METHOD="post"-->
<td width="383" height="33" bgcolor="#D7E3FF">
<center>
<input TYPE="submit" border="0" VALUE="Recall a participant" style="font-size: 8pt; font-weight: bold; background-color: #6666FF">
</center>
</td>

</tr>
</table>

</div>

</center>

&nbsp;<center>
<div align="left">
<table COLS=1 WIDTH="600" BGCOLOR="#CCCCFF" style="border-collapse: collapse" bordercolor="#111111" cellpadding="0" cellspacing="0"  bordercolorlight="#8080FF" bordercolordark="#8080FF" >

<tr>

  <td bgcolor="#CCCCFF" height="20" width="200" style="border-style:solid; border-width:1; ">
  <font color="#6699FF" size="2" face="Tahoma">&nbsp;</font><b><font size="2" face="Tahoma">First 
  and Lastname</font></b></td>
  <td bgcolor="#CCCCFF" height="20" width="58" style="border-style:solid; border-width:1; ">
  <b><font face="Tahoma" size="2">Username</font></b></td>
  <td bgcolor="#CCCCFF" height="20" width="42" style="border-style:solid; border-width:1; ">
  <b><font face="Tahoma" size="2">Password</font></b></td>
  <td bgcolor="#CCCCFF" height="20" width="200" style="border-style:solid; border-width:1; ">
  <b><font face="Tahoma" size="2">Registred email</font></b></td>

 <tr>
<%} count ++;
if (nombre==1){
%>

<% nombre =0;}%>
 <TR>
  <td bgcolor="#DFDFFF" height="20" width="200" style="border-style:solid; border-width:1; "><b><font size="1" face="Tahoma"><input TYPE="checkbox" NAME="<%=id%>" VALUE="<%=email%>" >&nbsp;&nbsp;</font><font face="Tahoma"><font size="1"><%= lastname+","+firstname%></font></a></font></b></td>
  <td bgcolor="#CCEEFF" height="20" width="50" style="border-style:solid; border-width:1; "><b><font size="1" face="Tahoma">&nbsp;&nbsp;</font><font face="Tahoma"><font size="1"><%=username%></font></a></font></b></td>
  <td bgcolor="#FFDFDF" height="20" width="50" style="border-style:solid; border-width:1; "><b><font size="1" face="Tahoma">&nbsp;&nbsp;</font><font face="Tahoma"><font size="1"><%=pwd%></font></a></font></b></td>
  <td bgcolor="#FFFFDD" height="20" width="200" style="border-style:solid; border-width:1; "><b><font size="1" face="Tahoma">&nbsp;&nbsp;</font><font face="Tahoma"><font size="1"><%= email%></font></a></font></b></td>
 </TR>
 <%
nombre++;

        } 
        
   }

    %>
    <input TYPE="hidden" NAME="Count" VALUE="70" >
<center>

<p>&nbsp;</center>

</FORM>
</div>
</body>
</html>
