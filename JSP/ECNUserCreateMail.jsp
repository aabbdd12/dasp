<%@ page import="java.sql.* , javax.mail.internet.*, javax.mail.*, java.io.* ,java.util.*, java.net.*, Mimap.DADUser " %> 
<jsp:useBean id="query3"  class="Mimap.DADUser" />

<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<%if (request.getParameter("new")!=null)
    query3.setResultSet(null);
%>
<html>
<head>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <meta name="Author" content="Araar Abdelkrim">
   <meta name="GENERATOR" content="Microsoft FrontPage 5.0">
  <title>DAD</title>
</head>
<body>

<%if (request.getParameter("new")!=null)
    query3.setResultSet(null);
%>
<table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" width="600" id="AutoNumber1">
  <tr>
    <td width="100%" bgcolor="#D7E3FF" height="15"><font face="Tahoma" size="2"><b>DAD Member's Mail</b></font></td>
  </tr>
</table>

  <table style="border-collapse: collapse" bordercolor="#111111" cellspacing="10" cellpadding="0" width="604" border="0">

      <tr>
        <td width="227" align="right"><font size="2" color="#0000FF">
        <span style="font-family: Tahoma; font-weight: 700">Edit the selected 
        g<span lang="en-ca">roup</span></span></font></td>
		<form method="POST" action="ECNSearchUserMail.jsp?ATTRIBUTE=MAILLIST">

        <td width="217" align="center"> <span lang="en-ca">
        <font face="Tahoma" size="2">
        <select style="BACKGROUND: #ffffff; font-size:8pt" name="STRINGTOSEARCH">
            <option value="SELECT GROUP    " name="STRINGTOSEARCH" selected>SELECT A GROUP</option>
            <option value="ON" name="STRINGTOSEARCH">SUBCRIBED USER</option>
          
            
          </select></font></td>
        <td align="left" width="120"><span lang="en-ca">
        
        <font face="Tahoma">
        <input style="border:1px solid #000000; FONT-WEIGHT: bold; COLOR: #000000; BACKGROUND-COLOR: #ccccff; font-size:8pt" type="submit" value="Go" name="B3"></font></span></td>
        </form>
      </tr>
     
  </table>

<p><br>
<center>

<%!
    ResultSet rs10=null;
                            %><font size="2" face="Times New Roman">

                            <%
    String emailstring="";
    rs10= query3.getResultSet();
     if (rs10 != null)
{
    while (rs10.next())
        {
        String email = rs10.getString("EMAIL");
         emailstring=emailstring+email+",";
         }
    //emailstring=URLEncoder.encode(emailstring);
    //String to = request.getParameter("to");
    Address[] toAddresses = InternetAddress.parse(emailstring);
    session.setAttribute("to",toAddresses);
    
	
    rs10.beforeFirst();
 }  
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
         String email = rs10.getString("EMAIL");
         String phone = rs10.getString("PHONE");
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
<td width="600" height="15" bordercolor="#D7E3FF" bgcolor="#D7E3FF">
<form method="post" action="ECNSendMailForm.jsp">
<center>
  
<input TYPE="submit" VALUE="Contact the whole group" style="font-size: 8pt; font-weight: bold; background-color: #6666FF; color:#FFFFFF">
</center>
</form>
</td>



</tr>
<tr>
<form ACTION="ECNContactSelectMember.jsp?ATTRIBUTE=<%=attribute%>" METHOD="post">
<td width="600" height="15" bgcolor="#D7E3FF">
<center>
<input TYPE="submit" border="0" VALUE="Contact the selected participants" style="font-size: 8pt; font-weight: bold; background-color: #6666FF; color:#FFFFFF">
</center>
</td>

</tr>
</table>

</div>

</center>

<br>&nbsp;


<center>
<div align="left">
<table COLS=3 WIDTH="600" BGCOLOR="#CCCCFF" style="border-collapse: collapse" bordercolor="#111111" cellpadding="0" cellspacing="0"  bordercolorlight="#8080FF" bordercolordark="#8080FF" >
<TR>
<%} count ++;
if (nombre==3){
%>
<tr>
<% nombre =0;}%>

  <td bgcolor="#CCCCFF" height="15" width="200"><b><font size="1" face="Tahoma"><input TYPE="checkbox" NAME="<%=id%>" VALUE="<%=email%>" >&nbsp;&nbsp;</font><font face="Tahoma"><a href="mailto:<%=email%>"><font size="1"><%=lastname+","+firstname %></font></a></font></b></td>
  
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
